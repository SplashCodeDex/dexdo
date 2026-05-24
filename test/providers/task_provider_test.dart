import 'package:dexdo/core/services/notification_service.dart';
import 'package:dexdo/features/tasks/data/repositories/task_repository_provider.dart';
import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:dexdo/features/tasks/domain/repositories/task_repository.dart';
import 'package:dexdo/features/tasks/presentation/providers/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// Manual Mock for NotificationService to bypass Platform channels.
// NotificationService is a concrete class — we implement all its public members.
class MockNotificationService implements NotificationService {
  @override
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void setPlugin(FlutterLocalNotificationsPlugin plugin) {
    flutterLocalNotificationsPlugin = plugin;
  }

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

    setUp(() {
      mockRepo = MockTaskRepository();

      container = ProviderContainer(
        overrides: [
          taskRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state uses empty task list', () async {
      await container.read(taskProvider.notifier).reloadFromStorage();
      final state = container.read(taskProvider);
      // tasks list is the raw store; filteredTasks is the view
      expect(state.tasks, isEmpty);
      expect(state.activeTasks, isEmpty);
    });

    test('AddTask increments task list', () async {
      await container.read(taskProvider.notifier).addTask();
      final state = container.read(taskProvider);
      // `tasks` is the raw list, `filteredTasks` is the filtered/sorted view
      expect(state.tasks.length, 1);
      // Defaults to 'Personal' when selected category is 'All'
      expect(state.tasks.first.category, 'Personal');
      expect(state.selectedTask, state.tasks.first);
    });

    test('Selecting Category filters filteredTasks properly', () async {
      final notifier = container.read(taskProvider.notifier);
      // Add a task (defaults to 'Personal')
      await notifier.addTask();

      final stateAfterAdd = container.read(taskProvider);
      final task = stateAfterAdd.tasks.first;

      // Update to 'Work' category directly via updateCategory
      await notifier.updateCategory(task, 'Work');

      notifier.setCategory('Work');
      final stateWork = container.read(taskProvider);
      expect(stateWork.filteredTasks.where((t) => t.category == 'Work').length, 1);

      notifier.setCategory('Finance');
      final stateFinance = container.read(taskProvider);
      expect(stateFinance.filteredTasks.length, 0); // Nothing in Finance
    });

    test('Completing task moves it to completedTasks', () async {
      final notifier = container.read(taskProvider.notifier);
      await notifier.addTask();

      final stateAfterAdd = container.read(taskProvider);
      final task = stateAfterAdd.tasks.first;

      expect(stateAfterAdd.activeTasks.length, 1);
      expect(stateAfterAdd.completedTasks.length, 0);

      await notifier.toggleTask(task);

      final stateAfterToggle = container.read(taskProvider);
      expect(stateAfterToggle.activeTasks.length, 0);
      expect(stateAfterToggle.completedTasks.length, 1);
    });
  });
}
