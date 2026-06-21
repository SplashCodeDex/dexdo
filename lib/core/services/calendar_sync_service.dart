import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:dexdo/core/utils/logger.dart';
import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarSyncService {
  final DeviceCalendar _calendar = DeviceCalendar.instance;

  Future<bool> _requestPermissions() async {
    var status = await _calendar.hasPermissions();
    if (status == CalendarPermissionStatus.notDetermined) {
      status = await _calendar.requestPermissions();
    }
    return status == CalendarPermissionStatus.granted;
  }

  Future<String?> _getWritableCalendarId() async {
    final hasPermission = await _requestPermissions();
    if (!hasPermission) return null;

    final calendars = await _calendar.listCalendars();
    if (calendars.isEmpty) return null;

    // Try to find a writable calendar (isReadOnly == false)
    for (var calendar in calendars) {
      if (!calendar.readOnly) {
        return calendar.id;
      }
    }

    return calendars.first.id;
  }

  Future<void> syncTaskToCalendar(Task task) async {
    if (task.dueDate == null) return;

    try {
      final calendarId = await _getWritableCalendarId();
      if (calendarId == null) {
        AppLogger.e('Calendar Sync: No writable calendar found or permissions denied');
        return;
      }

      // Check if event already exists so we can update it
      final existingEventId = await _findEventId(calendarId, task.id);

      final start = task.dueDate!;
      final end = start.add(const Duration(hours: 1));

      if (existingEventId != null) {
        // Update existing event
        await _calendar.updateEvent(
          eventId: existingEventId,
          title: task.title,
          description: Patch.set('${task.description}\n\n[DeXDo ID: ${task.id}]'),
          startDate: start,
          endDate: end,
        );
        AppLogger.d('Calendar Sync: Updated event $existingEventId for task ${task.id}');
      } else {
        // Create new event
        final eventId = await _calendar.createEvent(
          calendarId: calendarId,
          title: task.title,
          description: '${task.description}\n\n[DeXDo ID: ${task.id}]',
          startDate: start,
          endDate: end,
        );
        AppLogger.d('Calendar Sync: Created event $eventId for task ${task.id}');
      }
    } catch (e, stack) {
      AppLogger.e('Calendar Sync: Error syncing task to calendar', e, stack);
    }
  }

  Future<void> deleteTaskFromCalendar(Task task) async {
    try {
      final calendarId = await _getWritableCalendarId();
      if (calendarId == null) return;

      final existingEventId = await _findEventId(calendarId, task.id);
      if (existingEventId != null) {
        await _calendar.deleteEvent(eventId: existingEventId);
        AppLogger.d('Calendar Sync: Deleted event $existingEventId for task ${task.id}');
      }
    } catch (e, stack) {
      AppLogger.e('Calendar Sync: Error deleting event from calendar', e, stack);
    }
  }

  Future<String?> _findEventId(String calendarId, String taskId) async {
    final now = DateTime.now();
    final startSearch = now.subtract(const Duration(days: 30));
    final endSearch = now.add(const Duration(days: 90));

    try {
      final events = await _calendar.listEvents(
        startSearch,
        endSearch,
        calendarIds: [calendarId],
      );

      for (var event in events) {
        if (event.description != null && event.description!.contains('[DeXDo ID: $taskId]')) {
          return event.eventId;
        }
      }
    } catch (e) {
      AppLogger.e('Calendar Sync: Error searching for existing event', e);
    }
    return null;
  }
}

final calendarSyncServiceProvider = Provider<CalendarSyncService>((ref) {
  return CalendarSyncService();
});
