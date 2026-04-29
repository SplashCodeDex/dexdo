import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';
import '../../../../core/services/isar_service.dart';

class IsarTaskRepository implements TaskRepository {
  Future<Isar> get _db => IsarService.instance;

  @override
  Future<void> init() async {
    await _db;
  }

  @override
  Future<List<Task>> loadTasks() async {
    final isar = await _db;
    final models = await isar.taskModels.where().findAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      for (var task in tasks) {
        final model = TaskModel.fromEntity(task);
        final existing = await isar.taskModels.filter().idEqualTo(task.id).findFirst();
        if (existing != null) model.isarId = existing.isarId;
        await isar.taskModels.put(model);
      }
    });
  }

  @override
  Future<void> saveTask(Task task) async {
    final isar = await _db;
    final model = TaskModel.fromEntity(task);
    final existing = await isar.taskModels.filter().idEqualTo(task.id).findFirst();
    if (existing != null) model.isarId = existing.isarId;
    await isar.writeTxn(() async {
      await isar.taskModels.put(model);
    });
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.taskModels.filter().idEqualTo(taskId).deleteAll();
    });
  }

  @override
  Future<void> batchUpdateTasks(List<Task> tasks) async {
    await saveTasks(tasks);
  }

  @override
  Future<void> batchDeleteTasks(List<String> taskIds) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      for (var id in taskIds) {
        await isar.taskModels.filter().idEqualTo(id).deleteAll();
      }
    });
  }

  @override
  Future<List<String>> loadCategories() async {
    final isar = await _db;
    final models = await isar.categoryModels.where().findAll();
    return models.map((m) => m.name).toList();
  }

  @override
  Future<void> saveCategories(List<String> categories) async {
    // Note: This logic is a bit simple, it doesn't handle deletions well if we just 'put'
    // But for categories, we usually replace the whole list or handle individually.
  }

  @override
  Future<Map<String, IconData>> loadCategoryIcons() async {
    final isar = await _db;
    final models = await isar.categoryModels.where().findAll();
    return {
      for (var m in models) m.name: IconData(m.iconCodePoint, fontFamily: 'MaterialIcons')
    };
  }

  @override
  Future<void> saveCategoryIcons(Map<String, IconData> icons) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      for (var entry in icons.entries) {
        final existing = await isar.categoryModels.filter().nameEqualTo(entry.key).findFirst();
        final model = existing ?? CategoryModel()..name = entry.key;
        model.iconCodePoint = entry.value.codePoint;
        await isar.categoryModels.put(model);
      }
    });
  }

  @override
  Future<Map<String, Color>> loadCategoryColors() async {
    final isar = await _db;
    final models = await isar.categoryModels.where().findAll();
    return {
      for (var m in models) m.name: Color(m.colorValue)
    };
  }

  @override
  Future<void> saveCategoryColors(Map<String, Color> colors) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      for (var entry in colors.entries) {
        final existing = await isar.categoryModels.filter().nameEqualTo(entry.key).findFirst();
        final model = existing ?? CategoryModel()..name = entry.key;
        model.colorValue = entry.value.toARGB32();
        await isar.categoryModels.put(model);
      }
    });
  }
}
