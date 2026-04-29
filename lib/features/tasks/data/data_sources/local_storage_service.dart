import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

class LocalStorageService implements TaskRepository {
  late SharedPreferences _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<List<Task>> loadTasks() async {
    final String? tasksJson = _prefs.getString('tasks');
    if (tasksJson == null) return [];
    try {
      final List<dynamic> decoded = json.decode(tasksJson);
      return decoded.map((item) {
        try {
          return Task.fromJson(item);
        } catch (e) {
          debugPrint('Error parsing individual task: $e');
          return null;
        }
      }).whereType<Task>().toList();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      return [];
    }
  }

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    final String encoded = json.encode(tasks.map((t) => t.toJson()).toList());
    await _prefs.setString('tasks', encoded);
  }

  @override
  Future<void> saveTask(Task task) async {
    final tasks = await loadTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      tasks[index] = task;
    } else {
      tasks.add(task);
    }
    await saveTasks(tasks);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final tasks = await loadTasks();
    tasks.removeWhere((t) => t.id == taskId);
    await saveTasks(tasks);
  }

  @override
  Future<void> batchUpdateTasks(List<Task> updatedTasks) async {
    final tasks = await loadTasks();
    for (var task in updatedTasks) {
      final index = tasks.indexWhere((t) => t.id == task.id);
      if (index >= 0) {
        tasks[index] = task;
      }
    }
    await saveTasks(tasks);
  }

  @override
  Future<void> batchDeleteTasks(List<String> taskIds) async {
    final tasks = await loadTasks();
    tasks.removeWhere((t) => taskIds.contains(t.id));
    await saveTasks(tasks);
  }

  @override
  Future<List<String>> loadCategories() async {
    return _prefs.getStringList('categories') ?? [];
  }

  @override
  Future<void> saveCategories(List<String> categories) async {
    await _prefs.setStringList('categories', categories);
  }

  @override
  Future<Map<String, IconData>> loadCategoryIcons() async {
    final String? iconsJson = _prefs.getString('category_icons');
    if (iconsJson == null) return {};
    try {
      final Map<String, dynamic> decoded = json.decode(iconsJson);
      final Map<String, IconData> result = {};
      decoded.forEach((key, value) {
        result[key] = IconData(value, fontFamily: 'MaterialIcons');
      });
      return result;
    } catch (e) {
      debugPrint('Error loading category icons: $e');
      return {};
    }
  }

  @override
  Future<void> saveCategoryIcons(Map<String, IconData> icons) async {
    final Map<String, int> iconMap = {};
    icons.forEach((key, value) => iconMap[key] = value.codePoint);
    await _prefs.setString('category_icons', json.encode(iconMap));
  }

  @override
  Future<Map<String, Color>> loadCategoryColors() async {
    final String? colorsJson = _prefs.getString('category_colors');
    if (colorsJson == null) return {};
    try {
      final Map<String, dynamic> decoded = json.decode(colorsJson);
      final Map<String, Color> result = {};
      decoded.forEach((key, value) {
        result[key] = Color(value);
      });
      return result;
    } catch (e) {
      debugPrint('Error loading category colors: $e');
      return {};
    }
  }

  @override
  Future<void> saveCategoryColors(Map<String, Color> colors) async {
    final Map<String, int> colorMap = {};
    colors.forEach((key, value) => colorMap[key] = value.toARGB32());
    await _prefs.setString('category_colors', json.encode(colorMap));
  }
}
