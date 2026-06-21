import 'dart:convert';

import 'package:dexdo/core/constants/app_icons.dart';
import 'package:dexdo/core/utils/logger.dart';
import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:dexdo/features/tasks/domain/entities/task_templates.dart';
import 'package:dexdo/features/tasks/domain/repositories/task_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        } catch (e, stack) {
          AppLogger.e('Error parsing individual task', e, stack);
          return null;
        }
      }).whereType<Task>().toList();
    } catch (e, stack) {
      AppLogger.e('Error loading tasks from SharedPreferences', e, stack);
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
      return decoded.map((key, value) {
        if (value is String) {
          return MapEntry(key, AppIcons.fromString(value));
        } else if (value is int) {
          return MapEntry(key, AppIcons.fromLegacyCodePoint(value));
        }
        return MapEntry(key, AppIcons.defaultIcon);
      });
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> saveCategoryIcons(Map<String, IconData> icons) async {
    final Map<String, dynamic> iconsData = icons.map((key, value) => MapEntry(key, AppIcons.toStringKey(value)));
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

  // ── Templates ──────────────────────────────────────────────────────────

  static const String _templatesKey = 'templates';

  @override
  Future<List<TaskTemplate>> loadTemplates() async {
    final String? templatesJson = _prefs.getString(_templatesKey);
    if (templatesJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(templatesJson);
      return decoded.map((item) {
        final map = item as Map<String, dynamic>;
        final int codePoint = map['iconCodePoint'] as int;
        return TaskTemplate(
          id: map['id'] as String,
          name: map['name'] as String,
          // ignore: non_const_argument_for_const_parameter
          icon: IconData(codePoint, fontFamily: 'MaterialIcons'),
          category: map['category'] as String,
          subtaskTitles: List<String>.from(map['subtaskTitles'] as List),
        );
      }).toList();
    } catch (e, stack) {
      AppLogger.e('Error loading templates from SharedPreferences', e, stack);
      return [];
    }
  }

  @override
  Future<void> saveTemplate(TaskTemplate template) async {
    final templates = await loadTemplates();
    final index = templates.indexWhere((t) => t.id == template.id);
    if (index >= 0) {
      templates[index] = template;
    } else {
      templates.add(template);
    }
    await _saveAllTemplates(templates);
  }

  @override
  Future<void> deleteTemplate(String id) async {
    final templates = await loadTemplates();
    templates.removeWhere((t) => t.id == id);
    await _saveAllTemplates(templates);
  }

  Future<void> _saveAllTemplates(List<TaskTemplate> templates) async {
    final List<Map<String, dynamic>> encoded = templates.map((t) => {
      'id': t.id,
      'name': t.name,
      'iconCodePoint': t.icon.codePoint,
      'category': t.category,
      'subtaskTitles': t.subtaskTitles,
    }).toList();
    await _prefs.setString(_templatesKey, jsonEncode(encoded));
  }
}
