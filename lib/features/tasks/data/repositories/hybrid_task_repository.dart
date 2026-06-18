import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dexdo/core/services/data_migration_service.dart';
import 'package:dexdo/core/utils/logger.dart';
import 'package:dexdo/features/auth/presentation/providers/auth_provider.dart';
import 'package:dexdo/features/tasks/data/repositories/firebase_task_repository.dart';
import 'package:dexdo/features/tasks/data/repositories/isar_task_repository.dart';
import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:dexdo/features/tasks/domain/repositories/task_repository.dart';
import 'package:dexdo/features/tasks/presentation/providers/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HybridTaskRepository implements TaskRepository {
  HybridTaskRepository(this._ref);

  final FirebaseTaskRepository _firebase = FirebaseTaskRepository();
  final IsarTaskRepository _local = IsarTaskRepository();
  final Ref _ref;

  DateTime? _lastSyncTime;
  bool _isSyncing = false;

  bool get _isLoggedIn => _ref.read(authStateChangesProvider).value != null;

  @override
  Future<void> init() async {
    await _local.init();
    await _firebase.init();
    await migrate();
  }

  Future<void> migrate() async {
    if (_isLoggedIn) {
      await DataMigrationService.performMigrationIfNeeded(_firebase);
      _triggerSync();
    }
  }

  TaskRepository get _legacyRepo => _isLoggedIn ? _firebase : _local;

  @override
  Future<List<Task>> loadTasks() async {
    // 1. Immediately return local tasks, filtering out Tombstones
    final allLocal = await _local.loadTasks();
    final activeLocal = allLocal.where((t) => !t.isDeleted).toList();

    // 2. Trigger background sync if logged in
    if (_isLoggedIn) {
      unawaited(_triggerSync());
    }

    return activeLocal;
  }

  Future<void> _triggerSync() async {
    if (_isSyncing) return;
    
    // [Android 16] Check connectivity first to avoid dead-radio wakeups
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return; // Halt completely if offline
      }
    } catch (_) {}

    final now = DateTime.now();
    // 5-minute debounce
    if (_lastSyncTime != null && now.difference(_lastSyncTime!).inMinutes < 5) {
      return;
    }
    
    _isSyncing = true;
    _syncFromCloud().whenComplete(() {
      _isSyncing = false;
      _lastSyncTime = DateTime.now();
    });
  }

  Future<void> _syncFromCloud() async {
    try {
      // 1. Push pending local tombstones
      final allLocal = await _local.loadTasks();
      final pendingDeletes = allLocal.where((t) => t.isDeleted).toList();
      
      for (final t in pendingDeletes) {
        await _firebase.deleteTask(t.id).catchError((_) {});
      }
      
      if (pendingDeletes.isNotEmpty) {
        await _local.batchDeleteTasks(pendingDeletes.map((t) => t.id).toList());
      }
      
      // 2. Fetch remote tasks
      final remoteTasks = await _firebase.loadTasks();
      
      // Merge remote tasks into Isar
      await _local.saveTasks(remoteTasks);
      
      // 3. Silently update UI
      final newLocal = await _local.loadTasks();
      final activeTasks = newLocal.where((t) => !t.isDeleted).toList();
      
      try {
        _ref.read(taskProvider.notifier).silentUpdate(activeTasks);
      } catch (e) {
        // Ignored
      }
    } catch (e, stack) {
      AppLogger.e('Background Sync Error', e, stack);
    }
  }

  @override
  Future<void> saveTask(Task task) async {
    final updatedTask = task.copyWith(updatedAt: DateTime.now());
    await _local.saveTask(updatedTask);
    if (_isLoggedIn) {
      _firebase.saveTask(updatedTask).catchError((_) {});
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      final tasks = await _local.loadTasks();
      final task = tasks.firstWhere((t) => t.id == taskId);
      
      final tombstone = task.copyWith(
        isDeleted: true, 
        updatedAt: DateTime.now(),
      );
      
      await _local.saveTask(tombstone);
      
      if (_isLoggedIn) {
        _firebase.deleteTask(taskId).then((_) {
          _local.deleteTask(taskId);
        }).catchError((_) {});
      }
    } catch (e) {
      // Task not found locally, ignore
    }
  }

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    final updated = tasks.map((t) => t.copyWith(updatedAt: DateTime.now())).toList();
    await _local.saveTasks(updated);
    if (_isLoggedIn) {
      _firebase.saveTasks(updated).catchError((_) {});
    }
  }

  @override
  Future<void> batchUpdateTasks(List<Task> tasks) async {
    final updated = tasks.map((t) => t.copyWith(updatedAt: DateTime.now())).toList();
    await _local.batchUpdateTasks(updated);
    if (_isLoggedIn) {
      _firebase.batchUpdateTasks(updated).catchError((_) {});
    }
  }

  @override
  Future<void> batchDeleteTasks(List<String> taskIds) async {
    for (final id in taskIds) {
      await deleteTask(id);
    }
  }

  @override
  Future<List<String>> loadCategories() => _legacyRepo.loadCategories();

  @override
  Future<void> saveCategories(List<String> categories) => _legacyRepo.saveCategories(categories);

  @override
  Future<Map<String, IconData>> loadCategoryIcons() => _legacyRepo.loadCategoryIcons();

  @override
  Future<void> saveCategoryIcons(Map<String, IconData> icons) => _legacyRepo.saveCategoryIcons(icons);

  @override
  Future<Map<String, Color>> loadCategoryColors() => _legacyRepo.loadCategoryColors();

  @override
  Future<void> saveCategoryColors(Map<String, Color> colors) => _legacyRepo.saveCategoryColors(colors);
}
