import 'package:flutter/material.dart';
import '../../features/tasks/domain/entities/task.dart';

abstract class StorageService {
  Future<void> init();
  
  // Tasks
  Future<List<Task>> loadTasks();
  Future<void> saveTasks(List<Task> tasks);
  
  // Categories
  Future<List<String>> loadCategories();
  Future<void> saveCategories(List<String> categories);
  
  Future<Map<String, IconData>> loadCategoryIcons();
  Future<void> saveCategoryIcons(Map<String, IconData> icons);
  
  Future<Map<String, Color>> loadCategoryColors();
  Future<void> saveCategoryColors(Map<String, Color> colors);
}
