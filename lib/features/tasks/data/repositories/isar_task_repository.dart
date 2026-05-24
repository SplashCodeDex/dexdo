import 'package:dexdo/core/services/isar_service.dart';
import 'package:dexdo/core/utils/logger.dart';
import 'package:dexdo/features/tasks/data/models/task_model.dart';
import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:dexdo/features/tasks/domain/repositories/task_repository.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

class IsarTaskRepository implements TaskRepository {
  Future<Isar> get _db => IsarService.instance;

  @override
  Future<void> init() async {
    try {
      await _db;
    } catch (e, stack) {
      AppLogger.e('Isar initialization failed', e, stack);
    }
  }

  @override
  Future<List<Task>> loadTasks() async {
    final isar = await _db;
    return isar.readAsync((isar) {
      final models = isar.taskModels.where().findAll();
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    final isar = await _db;
    await isar.writeAsync((isar) {
      for (var task in tasks) {
        final model = TaskModel.fromEntity(task);
        final existing = isar.taskModels.where().taskIdEqualTo(task.id).findFirst();
        if (existing != null) model.isarId = existing.isarId;
        isar.taskModels.put(model);
      }
    });
  }

  @override
  Future<void> saveTask(Task task) async {
    final isar = await _db;
    final model = TaskModel.fromEntity(task);
    await isar.writeAsync((isar) {
      final existing = isar.taskModels.where().taskIdEqualTo(task.id).findFirst();
      if (existing != null) model.isarId = existing.isarId;
      isar.taskModels.put(model);
    });
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final isar = await _db;
    await isar.writeAsync((isar) {
      isar.taskModels.where().taskIdEqualTo(taskId).deleteAll();
    });
  }

  @override
  Future<void> batchUpdateTasks(List<Task> tasks) async {
    await saveTasks(tasks);
  }

  @override
  Future<void> batchDeleteTasks(List<String> taskIds) async {
    final isar = await _db;
    await isar.writeAsync((isar) {
      for (var id in taskIds) {
        isar.taskModels.where().taskIdEqualTo(id).deleteAll();
      }
    });
  }

  @override
  Future<List<String>> loadCategories() async {
    final isar = await _db;
    return isar.readAsync((isar) {
      final models = isar.categoryModels.where().findAll();
      return models.map((m) => m.name).toList();
    });
  }

  @override
  Future<void> saveCategories(List<String> categories) async {
    // Note: This logic is a bit simple, it doesn't handle deletions well if we just 'put'
    // But for categories, we usually replace the whole list or handle individually.
  }

  @override
  Future<Map<String, IconData>> loadCategoryIcons() async {
    final isar = await _db;
    return isar.readAsync((isar) {
      final models = isar.categoryModels.where().findAll();
      return {
        for (var m in models) m.name: IconData(m.iconCodePoint, fontFamily: 'MaterialIcons')
      };
    });
  }

  @override
  Future<void> saveCategoryIcons(Map<String, IconData> icons) async {
    final isar = await _db;
    await isar.writeAsync((isar) {
      for (var entry in icons.entries) {
        final existing = isar.categoryModels.where().nameEqualTo(entry.key).findFirst();
        final model = existing ?? (CategoryModel()..name = entry.key);
        model.iconCodePoint = entry.value.codePoint;
        isar.categoryModels.put(model);
      }
    });
  }

  @override
  Future<Map<String, Color>> loadCategoryColors() async {
    final isar = await _db;
    return isar.readAsync((isar) {
      final models = isar.categoryModels.where().findAll();
      return {
        for (var m in models) m.name: Color(m.colorValue)
      };
    });
  }

  @override
  Future<void> saveCategoryColors(Map<String, Color> colors) async {
    final isar = await _db;
    await isar.writeAsync((isar) {
      for (var entry in colors.entries) {
        final existing = isar.categoryModels.where().nameEqualTo(entry.key).findFirst();
        final model = existing ?? (CategoryModel()..name = entry.key);
        model.colorValue = entry.value.toARGB32();
        isar.categoryModels.put(model);
      }
    });
  }
}
