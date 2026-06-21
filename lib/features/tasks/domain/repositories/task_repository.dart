import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:dexdo/features/tasks/domain/entities/task_templates.dart';
import 'package:flutter/material.dart';

abstract class TaskRepository {
  Future<void> init();
  
  // Tasks
  Future<List<Task>> loadTasks();
  Future<void> saveTasks(List<Task> tasks);
  Future<void> saveTask(Task task);
  Future<void> deleteTask(String taskId);
  Future<void> batchUpdateTasks(List<Task> tasks);
  Future<void> batchDeleteTasks(List<String> taskIds);
  
  // Categories (Settings)
  Future<List<String>> loadCategories();
  Future<void> saveCategories(List<String> categories);
  
  Future<Map<String, IconData>> loadCategoryIcons();
  Future<void> saveCategoryIcons(Map<String, IconData> icons);
  
  Future<Map<String, Color>> loadCategoryColors();
  Future<void> saveCategoryColors(Map<String, Color> colors);

  // Templates
  Future<List<TaskTemplate>> loadTemplates();
  Future<void> saveTemplate(TaskTemplate template);
  Future<void> deleteTemplate(String id);
}
