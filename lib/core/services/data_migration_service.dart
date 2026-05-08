import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/tasks/data/repositories/firebase_task_repository.dart';
import '../services/local_storage_service.dart';

import '../utils/logger.dart';

class DataMigrationService {
  static const String _migrationKey = 'migrated_to_firebase';

  static Future<void> performMigrationIfNeeded(FirebaseTaskRepository firebaseStorage) async {
    final prefs = await SharedPreferences.getInstance();
    final hasMigrated = prefs.getBool(_migrationKey) ?? false;

    if (!hasMigrated) {
      AppLogger.i('Starting one-time migration from Local -> Firebase...');
      try {
        final localService = LocalStorageService();
        await localService.init();

        final tasks = await localService.loadTasks();
        if (tasks.isNotEmpty) {
          await firebaseStorage.saveTasks(tasks);
        }

        final categories = await localService.loadCategories();
        if (categories.isNotEmpty) {
          await firebaseStorage.saveCategories(categories);
        }

        // We mark it as migrated even if lists are empty so we don't repeat this.
        await prefs.setBool(_migrationKey, true);
        AppLogger.i('Migration complete.');
      } catch (e, stack) {
        AppLogger.e('Migration failed', e, stack);
      }
    }
  }
}
