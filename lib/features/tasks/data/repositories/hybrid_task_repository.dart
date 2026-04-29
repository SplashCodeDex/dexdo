import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import 'firebase_task_repository.dart';
import 'isar_task_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/data_migration_service.dart';

class HybridTaskRepository implements TaskRepository {
  final FirebaseTaskRepository _firebase = FirebaseTaskRepository();
  final IsarTaskRepository _local = IsarTaskRepository();
  final Ref _ref;

  HybridTaskRepository(this._ref);

  TaskRepository get _currentRepo => 
      _ref.read(authStateChangesProvider).value == null ? _local : _firebase;

  Future<void> migrate() async {
    if (_ref.read(authStateChangesProvider).value != null) {
      await DataMigrationService.performMigrationIfNeeded(_firebase);
    }
  }

  @override
  Future<void> init() async {
    await _local.init();
    await _firebase.init();
    await migrate();
  }

  // Then delegate all methods to _currentRepo
  @override
  Future<List<Task>> loadTasks() => _currentRepo.loadTasks();

  @override
  Future<void> saveTasks(List<Task> tasks) => _currentRepo.saveTasks(tasks);

  @override
  Future<void> saveTask(Task task) => _currentRepo.saveTask(task);

  @override
  Future<void> deleteTask(String taskId) => _currentRepo.deleteTask(taskId);

  @override
  Future<void> batchUpdateTasks(List<Task> tasks) => _currentRepo.batchUpdateTasks(tasks);

  @override
  Future<void> batchDeleteTasks(List<String> taskIds) => _currentRepo.batchDeleteTasks(taskIds);

  @override
  Future<List<String>> loadCategories() => _currentRepo.loadCategories();

  @override
  Future<void> saveCategories(List<String> categories) => _currentRepo.saveCategories(categories);

  @override
  Future<Map<String, IconData>> loadCategoryIcons() => _currentRepo.loadCategoryIcons();

  @override
  Future<void> saveCategoryIcons(Map<String, IconData> icons) => _currentRepo.saveCategoryIcons(icons);

  @override
  Future<Map<String, Color>> loadCategoryColors() => _currentRepo.loadCategoryColors();

  @override
  Future<void> saveCategoryColors(Map<String, Color> colors) => _currentRepo.saveCategoryColors(colors);
}
