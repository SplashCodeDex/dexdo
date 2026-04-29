import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:dexdo/features/tasks/presentation/providers/task_provider.dart';
import 'package:dexdo/features/tasks/domain/repositories/task_repository.dart';
import 'package:dexdo/features/tasks/data/repositories/task_repository_provider.dart';
import 'package:dexdo/core/services/notification_service.dart';

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
  get flutterLocalNotificationsPlugin => throw UnimplementedError();

  @override
  Future<void> init() async {}

  @override
  Future<void> scheduleTaskReminder(Task task) async {}

  @override
  Future<void> cancelTaskReminder(String taskId) async {}
}

void main() {
  group('TaskProvider (Riverpod) Logic Tests', () {
    late ProviderContainer container;
    late MockTaskRepository mockRepo;
    late MockNotificationService mockNotifications;

    setUp(() {
      mockRepo = MockTaskRepository();
      mockNotifications = MockNotificationService();
      
      container = ProviderContainer(
        overrides: [
          taskRepositoryProvider.overrideWithValue(mockRepo),
          notificationServiceProvider.overrideWithValue(mockNotifications),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state uses empty list', () async {
      await container.read(taskProvider.notifier).reloadFromStorage();
      final state = container.read(taskProvider);
      expect(state.tasks, isEmpty);
      expect(state.activeTasks, isEmpty);
    });

    test('AddTask increments task list natively', () async {
      await container.read(taskProvider.notifier).addTask();
      final state = container.read(taskProvider);
      expect(state.allTasks.length, 1);
      expect(state.allTasks.first.category, 'Personal'); // Defaults to Personal if "All" is selected
      expect(state.selectedTask, state.allTasks.first);
    });

    test('Selecting Category filters tasks properly', () async {
      final notifier = container.read(taskProvider.notifier);
      await notifier.addTask();
      
      final stateAfterAdd = container.read(taskProvider);
      final task = stateAfterAdd.allTasks.first;
      
      await notifier.addCategory('Testing', Icons.bug_report, Colors.green);
      await notifier.updateCategory(task, 'Testing');

      final stateAfterCat = container.read(taskProvider);
      expect(stateAfterCat.tasks.where((t) => t.category == 'Testing').length, 1);

      notifier.setCategory('Testing');
      final stateTesting = container.read(taskProvider);
      expect(stateTesting.tasks.length, 1);

      notifier.setCategory('Work');
      final stateWork = container.read(taskProvider);
      expect(stateWork.tasks.length, 0); // Should be filtered out
    });

    test('Completing task moves it to completed array', () async {
      final notifier = container.read(taskProvider.notifier);
      await notifier.addTask();
      
      final stateAfterAdd = container.read(taskProvider);
      final task = stateAfterAdd.allTasks.first;
      
      expect(stateAfterAdd.activeTasks.length, 1);
      expect(stateAfterAdd.completedTasks.length, 0);

      await notifier.toggleTask(task);
      
      final stateAfterToggle = container.read(taskProvider);
      expect(stateAfterToggle.activeTasks.length, 0);
      expect(stateAfterToggle.completedTasks.length, 1);
    });
  });
}
