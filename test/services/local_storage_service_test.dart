import 'package:dexdo/models/task.dart';
import 'package:dexdo/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  group('LocalStorageService Unit Tests', () {
    late LocalStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = LocalStorageService();
      await storage.init();
    });

    test('loadTasks returns empty list when no data', () async {
      final tasks = await storage.loadTasks();
      expect(tasks, isEmpty);
    });

    test('saveTask and loadTasks round trip', () async {
      final task = Task(id: 't1', title: 'Test Task');
      await storage.saveTask(task);

      final loaded = await storage.loadTasks();
      expect(loaded.length, 1);
      expect(loaded[0].id, 't1');
      expect(loaded[0].title, 'Test Task');
    });

    test('deleteTask removes task', () async {
      final task = Task(id: 't2', title: 'Task to delete');
      await storage.saveTask(task);
      expect((await storage.loadTasks()).length, 1);

      await storage.deleteTask('t2');
      expect((await storage.loadTasks()), isEmpty);
    });

    test('saveCategories and loadCategories match', () async {
      await storage.saveCategories(['Work', 'Personal']);
      final loaded = await storage.loadCategories();
      expect(loaded.length, 2);
      expect(loaded[0], 'Work');
    });

    test('batchUpdateTasks updates existing tasks', () async {
      final task1 = Task(id: '1', title: 'Old1');
      final task2 = Task(id: '2', title: 'Old2');
      await storage.saveTasks([task1, task2]);

      final updatedTask1 = task1.copyWith(title: 'New1');
      await storage.batchUpdateTasks([updatedTask1]);

      final res = await storage.loadTasks();
      expect(res.firstWhere((t) => t.id == '1').title, 'New1');
      expect(res.firstWhere((t) => t.id == '2').title, 'Old2');
    });
  });
}
