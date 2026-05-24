import 'package:dexdo/core/services/notification_service.dart';
import 'package:dexdo/features/tasks/data/repositories/task_repository_provider.dart';
import 'package:dexdo/features/tasks/presentation/providers/task_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
