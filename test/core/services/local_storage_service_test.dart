import 'package:dexdo/core/services/local_storage_service.dart';
import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      const task = Task(id: 't1', title: 'Test Task');
      await storage.saveTask(task);

      final loaded = await storage.loadTasks();
      expect(loaded.length, 1);
      expect(loaded[0].id, 't1');
      expect(loaded[0].title, 'Test Task');
    });

    test('deleteTask removes task', () async {
      const task = Task(id: 't2', title: 'Task to delete');
      await storage.saveTask(task);
      expect((await storage.loadTasks()).length, 1);

      await storage.deleteTask('t2');
      expect(await storage.loadTasks(), isEmpty);
    });

    test('saveCategories and loadCategories match', () async {
      await storage.saveCategories(['Work', 'Personal']);
      final loaded = await storage.loadCategories();
      expect(loaded.length, 2);
      expect(loaded[0], 'Work');
    });

    test('batchUpdateTasks updates existing tasks', () async {
      const task1 = Task(id: '1', title: 'Old1');
      const task2 = Task(id: '2', title: 'Old2');
      await storage.saveTasks([task1, task2]);

      final updatedTask1 = task1.copyWith(title: 'New1');
      await storage.batchUpdateTasks([updatedTask1]);

      final res = await storage.loadTasks();
      expect(res.firstWhere((t) => t.id == '1').title, 'New1');
      expect(res.firstWhere((t) => t.id == '2').title, 'Old2');
    });
  });
}
