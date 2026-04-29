import 'package:dexdo/models/task.dart';
import 'package:dexdo/services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class FakeFlutterLocalNotificationsPlugin extends Fake implements FlutterLocalNotificationsPlugin {
  int cancelCount = 0;
  int scheduleCount = 0;

  @override
  Future<void> cancel(id: int, {String? tag}) async {
    cancelCount++;
  }

  @override
  Future<void> zonedSchedule(
    id: int,
    title: String?,
    body: String?,
    scheduledDate: tz.TZDateTime,
    notificationDetails: NotificationDetails, {
    String? payload,
    AndroidScheduleMode? androidScheduleMode,
    DateTimeComponents? matchDateTimeComponents,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation? uiLocalNotificationDateInterpretation,
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
      final task = Task(id: '1', title: 'Task no due date');
      await service.scheduleTaskReminder(task);
      expect(fakePlugin.scheduleCount, 0);
    });

    test('scheduleTaskReminder ignores completed task', () async {
      final task = Task(id: '2', title: 'Task completed', isCompleted: true, dueDate: DateTime.now().add(const Duration(hours: 1)));
      await service.scheduleTaskReminder(task);
      expect(fakePlugin.scheduleCount, 0);
    });

    test('scheduleTaskReminder ignores task whose reminder time is in the past', () async {
      final task = Task(id: '3', title: 'Task due soon', dueDate: DateTime.now().add(const Duration(minutes: 10)));
      await service.scheduleTaskReminder(task);
      expect(fakePlugin.scheduleCount, 0);
    });

    test('scheduleTaskReminder schedules if valid', () async {
      final task = Task(id: '4', title: 'Task due later', dueDate: DateTime.now().add(const Duration(hours: 2)));
      await service.scheduleTaskReminder(task);
      expect(fakePlugin.scheduleCount, 1);
    });

    test('cancelTaskReminder calls cancel', () async {
      await service.cancelTaskReminder('task_xyz');
      expect(fakePlugin.cancelCount, 1);
    });
  });
}
