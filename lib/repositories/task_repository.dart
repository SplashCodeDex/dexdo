import 'package:flutter/material.dart';
import '../models/task.dart';

abstract class TaskRepository {
  Future<void> init();
  
  // Tasks
  Future<List<Task>> loadTasks();
  Future<void> saveTasks(List<Task> tasks);
  Future<void> saveTask(Task task);
  Future<void> deleteTask(String taskId);
  
  // Categories (Settings)
  Future<List<String>> loadCategories();
  Future<void> saveCategories(List<String> categories);
  
  Future<Map<String, IconData>> loadCategoryIcons();
  Future<void> saveCategoryIcons(Map<String, IconData> icons);
  
  Future<Map<String, Color>> loadCategoryColors();
  Future<void> saveCategoryColors(Map<String, Color> colors);
}
