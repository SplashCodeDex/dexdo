import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/tasks/domain/entities/task.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';

class LocalStorageService implements TaskRepository {
  late SharedPreferences _prefs;
  
  static const String _tasksKey = 'tasks';
  static const String _categoriesKey = 'categories';
  static const String _categoryIconsKey = 'category_icons';
  static const String _categoryColorsKey = 'category_colors';

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<List<Task>> loadTasks() async {
    final String? tasksJson = _prefs.getString(_tasksKey);
    if (tasksJson == null) return [];
    
    try {
      final List<dynamic> decoded = jsonDecode(tasksJson);
      return decoded.map((item) {
        try {
          return Task.fromJson(item as Map<String, dynamic>);
        } catch (e) {
          debugPrint('Error parsing individual task: $e');
          return null;
        }
      }).whereType<Task>().toList();
    } catch (e) {
      debugPrint('Error loading tasks from SharedPreferences: $e');
      return [];
    }
  }

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    final String tasksJson = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await _prefs.setString(_tasksKey, tasksJson);
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
    return _prefs.getStringList(_categoriesKey) ?? ['All', 'Personal', 'Work', 'Shopping', 'Health'];
  }

  @override
  Future<void> saveCategories(List<String> categories) async {
    await _prefs.setStringList(_categoriesKey, categories);
  }

  @override
  Future<Map<String, IconData>> loadCategoryIcons() async {
    final String? iconsJson = _prefs.getString(_categoryIconsKey);
    if (iconsJson == null) return {};
    
    try {
      final Map<String, dynamic> decoded = jsonDecode(iconsJson);
      return decoded.map((key, value) => MapEntry(key, IconData(value as int, fontFamily: 'MaterialIcons')));
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> saveCategoryIcons(Map<String, IconData> icons) async {
    final Map<String, int> iconsData = icons.map((key, value) => MapEntry(key, value.codePoint));
    await _prefs.setString(_categoryIconsKey, jsonEncode(iconsData));
  }

  @override
  Future<Map<String, Color>> loadCategoryColors() async {
    final String? colorsJson = _prefs.getString(_categoryColorsKey);
    if (colorsJson == null) return {};
    
    try {
      final Map<String, dynamic> decoded = jsonDecode(colorsJson);
      return decoded.map((key, value) => MapEntry(key, Color(value as int)));
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> saveCategoryColors(Map<String, Color> colors) async {
    final Map<String, int> colorsData = colors.map((key, value) => MapEntry(key, value.toARGB32()));
    await _prefs.setString(_categoryColorsKey, jsonEncode(colorsData));
  }
}
