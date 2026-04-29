import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/task.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  /// Supports dependency injection for testing
  void setPlugin(FlutterLocalNotificationsPlugin plugin) {
    flutterLocalNotificationsPlugin = plugin;
  }

  Future<void> init() async {
    tz.initializeTimeZones();

    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );
  }

  Future<void> scheduleTaskReminder(Task task) async {
    if (task.dueDate == null || task.isCompleted) return;
    
    // Example: Remind 30 minutes before due date
    final scheduledTime = task.dueDate!.subtract(const Duration(minutes: 30));
    if (scheduledTime.isBefore(DateTime.now())) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: task.id.hashCode,
      title: 'Task Reminder: ${task.title}',
      body: 'Due in 30 minutes. Tap to view.',
      scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Notifications for upcoming task deadlines',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelTaskReminder(String taskId) async {
    await flutterLocalNotificationsPlugin.cancel(id: taskId.hashCode);
  }
}
