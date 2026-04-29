import 'package:dexdo/models/task.dart';
import 'package:dexdo/repositories/firebase_task_repository.dart';
import 'package:dexdo/services/data_migration_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FakeFirebaseTaskRepository extends Fake implements FirebaseTaskRepository {
  List<Task> savedTasks = [];
  List<String> savedCategories = [];

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    savedTasks.addAll(tasks);
  }

  @override
  Future<void> saveCategories(List<String> categories) async {
    savedCategories.addAll(categories);
  }
}

void main() {
  group('DataMigrationService Unit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Migrates local data to firebase if not migrated', () async {
      final task = Task(id: 'migration1', title: 'To transfer');
      SharedPreferences.setMockInitialValues({
        'tasks': json.encode([task.toJson()]),
        'categories': ['School', 'Personal'],
        'migrated_to_firebase': false,
      });

      final fakeFirebase = FakeFirebaseTaskRepository();
      await DataMigrationService.performMigrationIfNeeded(fakeFirebase);

      expect(fakeFirebase.savedTasks.length, 1);
      expect(fakeFirebase.savedTasks[0].id, 'migration1');
      expect(fakeFirebase.savedCategories.length, 2);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('migrated_to_firebase'), true);
    });

    test('Does not migrate if already migrated', () async {
      SharedPreferences.setMockInitialValues({
        'tasks': json.encode([Task(id: 'x', title: 'x').toJson()]),
        'migrated_to_firebase': true,
      });

      final fakeFirebase = FakeFirebaseTaskRepository();
      await DataMigrationService.performMigrationIfNeeded(fakeFirebase);

      expect(fakeFirebase.savedTasks.length, 0);
    });
  });
}
