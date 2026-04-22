import 'package:dexdo/models/task.dart';
import 'package:dexdo/providers/task_provider.dart';
import 'package:dexdo/repositories/task_repository.dart';
import 'package:dexdo/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Manual Mock for TaskRepository
class MockTaskRepository implements TaskRepository {
  List<Task> memoryTasks = [];
  
  @override
  Future<void> init() async {}
  
  @override
  Future<List<Task>> loadTasks() async => memoryTasks;

  @override
  Future<void> saveTask(Task task) async {
    final index = memoryTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      memoryTasks[index] = task;
    } else {
      memoryTasks.add(task);
    }
  }

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    memoryTasks = List.from(tasks);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    memoryTasks.removeWhere((t) => t.id == taskId);
  }

  @override
  Future<void> batchDeleteTasks(List<String> taskIds) async {
    memoryTasks.removeWhere((t) => taskIds.contains(t.id));
  }

  @override
  Future<void> batchUpdateTasks(List<Task> tasks) async {
    for (var task in tasks) {
      await saveTask(task);
    }
  }

  @override
  Future<List<String>> loadCategories() async => [];
  
  @override
  Future<void> saveCategories(List<String> categories) async {}
  
  @override
  Future<Map<String, Color>> loadCategoryColors() async => {};
  
  @override
  Future<Map<String, IconData>> loadCategoryIcons() async => {};
  
  @override
  Future<void> saveCategoryColors(Map<String, Color> colors) async {}
  
  @override
  Future<void> saveCategoryIcons(Map<String, IconData> icons) async {}
}

// Manual Mock for NotificationService to bypass Platform channels
class MockNotificationService implements NotificationService {
  @override
  Never get flutterLocalNotificationsPlugin => throw UnimplementedError();

  @override
  Future<void> init() async {}

  @override
  Future<void> scheduleTaskReminder(Task task) async {}

  @override
  Future<void> cancelTaskReminder(String taskId) async {}
}

void main() {
  group('TaskProvider Logic Tests via Dependency Injection', () {
    late TaskProvider provider;
    late MockTaskRepository mockRepo;
    late MockNotificationService mockNotifications;

    setUp(() {
      mockRepo = MockTaskRepository();
      mockNotifications = MockNotificationService();
      provider = TaskProvider(
        repository: mockRepo,
        notifications: mockNotifications,
      );
    });

    test('Initial state uses empty list', () async {
      await provider.reloadFromStorage();
      expect(provider.tasks, isEmpty);
      expect(provider.activeTasks, isEmpty);
    });

    test('AddTask increments task list natively', () async {
      await provider.addTask();
      expect(provider.tasks.length, 1);
      expect(provider.tasks.first.category, 'Personal'); // Defaults to Personal if "All" is selected
      expect(provider.selectedTask, provider.tasks.first);
    });

    test('Selecting Category filters tasks properly', () async {
      await provider.addTask();
      final task = provider.tasks.first;
      
      await provider.addCategory('Testing', Icons.bug_report, Colors.green);
      await provider.updateCategory(task, 'Testing');

      expect(provider.activeTasks.where((t) => t.category == 'Testing').length, 1);

      provider.setCategory('Testing');
      expect(provider.tasks.length, 1);

      provider.setCategory('Work');
      expect(provider.tasks.length, 0); // Should be filtered out
    });

    test('Completing task moves it to completed array', () async {
      await provider.addTask();
      final task = provider.tasks.first;
      
      expect(provider.activeTasks.length, 1);
      expect(provider.completedTasks.length, 0);

      await provider.toggleTask(task);

      expect(provider.activeTasks.length, 0);
      expect(provider.completedTasks.length, 1);
    });
  });
}
