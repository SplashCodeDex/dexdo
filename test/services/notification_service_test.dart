import 'package:dexdo/core/services/notification_service.dart';
import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// A fake plugin that overrides only the methods we care about testing,
/// using proper Dart named-parameter syntax.
class FakeFlutterLocalNotificationsPlugin extends Fake
    implements FlutterLocalNotificationsPlugin {
  int cancelCount = 0;
  int scheduleCount = 0;

  @override
  Future<void> cancel({required int id, String? tag}) async {
    cancelCount++;
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    String? title,
    String? body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    scheduleCount++;
  }
}

void main() {
  group('NotificationService Unit Tests', () {
    late NotificationService service;
    late FakeFlutterLocalNotificationsPlugin fakePlugin;

    setUp(() {
      tz.initializeTimeZones();
      fakePlugin = FakeFlutterLocalNotificationsPlugin();
      service = NotificationService();
      service.setPlugin(fakePlugin);
    });

    test('scheduleTaskReminder ignores task without dueDate', () async {
      const task = Task(id: '1', title: 'Task no due date');
      await service.scheduleTaskReminder(task);
      expect(fakePlugin.scheduleCount, 0);
    });

    test('scheduleTaskReminder ignores completed task', () async {
      final task = Task(
        id: '2',
        title: 'Task completed',
        isCompleted: true,
        dueDate: DateTime.now().add(const Duration(hours: 1)),
      );
      await service.scheduleTaskReminder(task);
      expect(fakePlugin.scheduleCount, 0);
    });

    test('scheduleTaskReminder ignores task whose reminder time is in the past', () async {
      // Reminder fires 30 min before due — if due in 10 min, reminder is already past
      final task = Task(
        id: '3',
        title: 'Task due soon',
        dueDate: DateTime.now().add(const Duration(minutes: 10)),
      );
      await service.scheduleTaskReminder(task);
      expect(fakePlugin.scheduleCount, 0);
    });

    test('scheduleTaskReminder schedules if due date is far enough ahead', () async {
      final task = Task(
        id: '4',
        title: 'Task due later',
        dueDate: DateTime.now().add(const Duration(hours: 2)),
      );
      await service.scheduleTaskReminder(task);
      expect(fakePlugin.scheduleCount, 1);
    });

    test('cancelTaskReminder calls cancel with the hashed id', () async {
      await service.cancelTaskReminder('task_xyz');
      expect(fakePlugin.cancelCount, 1);
    });
  });
}
