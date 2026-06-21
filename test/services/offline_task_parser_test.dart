import 'package:dexdo/core/services/offline_task_parser.dart';
import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:dexdo/features/tasks/domain/entities/task_templates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OfflineTaskParser Tests', () {
    final categories = ['Personal', 'Work', 'Shopping', 'Fitness'];

    test('Basic parsing - title only', () {
      final parsed = OfflineTaskParser.parse('Buy milk', categories);
      expect(parsed.title, equals('Buy milk'));
      expect(parsed.description, isNull);
      expect(parsed.dueDate, isNull);
      expect(parsed.category, isNull);
      expect(parsed.priority, isNull);
      expect(parsed.recurrence, equals('none'));
      expect(parsed.subtasks, isNull);
    });

    test('Capitalization and cleaning of title', () {
      final parsed = OfflineTaskParser.parse('   - for buy groceries:   ', categories);
      expect(parsed.title, equals('Buy groceries'));
    });

    test('Date parsing - relative keywords', () {
      final today = DateTime.now();
      
      final parsedToday = OfflineTaskParser.parse('Meeting today', categories);
      expect(parsedToday.dueDate!.year, equals(today.year));
      expect(parsedToday.dueDate!.month, equals(today.month));
      expect(parsedToday.dueDate!.day, equals(today.day));
      expect(parsedToday.title, equals('Meeting'));

      final parsedTomorrow = OfflineTaskParser.parse('buy groceries tomorrow', categories);
      final tomorrow = today.add(const Duration(days: 1));
      expect(parsedTomorrow.dueDate!.year, equals(tomorrow.year));
      expect(parsedTomorrow.dueDate!.month, equals(tomorrow.month));
      expect(parsedTomorrow.dueDate!.day, equals(tomorrow.day));
      expect(parsedTomorrow.title, equals('Buy groceries'));

      final parsedNextWeek = OfflineTaskParser.parse('trip next week', categories);
      final nextWeek = today.add(const Duration(days: 7));
      expect(parsedNextWeek.dueDate!.year, equals(nextWeek.year));
      expect(parsedNextWeek.dueDate!.month, equals(nextWeek.month));
      expect(parsedNextWeek.dueDate!.day, equals(nextWeek.day));
      expect(parsedNextWeek.title, equals('Trip'));
    });

    test('Date parsing - weekdays', () {
      final today = DateTime.now();
      
      final parsedFriday = OfflineTaskParser.parse('Call client on Friday', categories);
      expect(parsedFriday.dueDate, isNotNull);
      expect(parsedFriday.dueDate!.weekday, equals(DateTime.friday));
      expect(parsedFriday.title, equals('Call client'));
      
      // Verification that the date is indeed in the future
      expect(parsedFriday.dueDate!.isAfter(DateTime(today.year, today.month, today.day).subtract(const Duration(seconds: 1))), isTrue);
    });

    test('Date parsing - explicit date formats', () {
      final today = DateTime.now();

      final parsedExplicit1 = OfflineTaskParser.parse('Trip on June 25', categories);
      expect(parsedExplicit1.dueDate!.month, equals(6));
      expect(parsedExplicit1.dueDate!.day, equals(25));
      expect(parsedExplicit1.dueDate!.year, equals(today.year));

      final parsedExplicit2 = OfflineTaskParser.parse('Task due 12/25/2026', categories);
      expect(parsedExplicit2.dueDate!.month, equals(12));
      expect(parsedExplicit2.dueDate!.day, equals(25));
      expect(parsedExplicit2.dueDate!.year, equals(2026));
    });

    test('Time parsing', () {
      final today = DateTime.now();
      
      final parsedTime1 = OfflineTaskParser.parse('Meeting at 5:30 pm', categories);
      expect(parsedTime1.dueDate!.hour, equals(17));
      expect(parsedTime1.dueDate!.minute, equals(30));
      
      final parsedTime2 = OfflineTaskParser.parse('Meeting at 10am today', categories);
      expect(parsedTime2.dueDate!.hour, equals(10));
      expect(parsedTime2.dueDate!.minute, equals(0));
      expect(parsedTime2.dueDate!.day, equals(today.day));
    });

    test('Priority parsing', () {
      final parsedUrgent = OfflineTaskParser.parse('Urgent task to review code', categories);
      expect(parsedUrgent.priority, equals(TaskPriority.urgent));
      expect(parsedUrgent.title, equals('Task to review code'));

      final parsedHigh = OfflineTaskParser.parse('Important feedback from client priority high', categories);
      expect(parsedHigh.priority, equals(TaskPriority.high));
      expect(parsedHigh.title, equals('Important feedback from client'));

      final parsedLow = OfflineTaskParser.parse('clean workspace priority low', categories);
      expect(parsedLow.priority, equals(TaskPriority.low));
      expect(parsedLow.title, equals('Clean workspace'));
    });

    test('Recurrence parsing', () {
      final parsedDaily = OfflineTaskParser.parse('Water plants every day', categories);
      expect(parsedDaily.recurrence, equals('daily'));
      expect(parsedDaily.title, equals('Water plants'));

      final parsedWeekly = OfflineTaskParser.parse('Team sync each week', categories);
      expect(parsedWeekly.recurrence, equals('weekly'));
      expect(parsedWeekly.title, equals('Team sync'));
    });

    test('Category matching', () {
      final parsedShopping = OfflineTaskParser.parse('Buy bread category Shopping', categories);
      expect(parsedShopping.category, equals('Shopping'));
      expect(parsedShopping.title, equals('Buy bread'));

      final parsedWork = OfflineTaskParser.parse('Write design doc work', categories);
      expect(parsedWork.category, equals('Work'));
      expect(parsedWork.title, equals('Write design doc'));
    });

    test('Subtasks parsing', () {
      final parsedSubtasks = OfflineTaskParser.parse(
        'Go to supermarket with subtasks bread, milk and cheese',
        categories,
      );
      expect(parsedSubtasks.title, equals('Go to supermarket'));
      expect(parsedSubtasks.subtasks, equals(['Bread', 'Milk', 'Cheese']));
    });

    test('Description parsing', () {
      final parsedDesc = OfflineTaskParser.parse(
        'Call bank description speak to loan manager details inside note',
        categories,
      );
      expect(parsedDesc.title, equals('Call bank'));
      expect(parsedDesc.description, equals('speak to loan manager details inside note'));
    });

    test('Complex parsing composite command', () {
      final parsed = OfflineTaskParser.parse(
        'buy milk tomorrow at 5pm category Shopping priority high every day with subtasks whole milk, organic butter',
        categories,
      );
      expect(parsed.title, equals('Buy milk'));
      expect(parsed.category, equals('Shopping'));
      expect(parsed.priority, equals(TaskPriority.high));
      expect(parsed.recurrence, equals('daily'));
      expect(parsed.subtasks, equals(['Whole milk', 'Organic butter']));
      expect(parsed.dueDate, isNotNull);
      expect(parsed.dueDate!.hour, equals(17));
      expect(parsed.dueDate!.minute, equals(0));
    });

    test('Template matching - Morning Routine', () {
      final templates = TaskTemplate.defaultTemplates;
      final parsed = OfflineTaskParser.parse(
        'apply morning routine template tomorrow priority high',
        categories,
        templates,
      );
      
      expect(parsed.title, equals('Morning Routine'));
      expect(parsed.category, equals('Personal')); // default from template
      expect(parsed.priority, equals(TaskPriority.high));
      expect(parsed.subtasks, equals([
        'Drink a glass of water',
        '10-minute meditation',
        'Stretching/Exercise',
        'Eat healthy breakfast',
        'Plan today\'s tasks'
      ]));
      expect(parsed.dueDate, isNotNull);
    });

    test('Template matching - Grocery list with custom category override', () {
      final templates = TaskTemplate.defaultTemplates;
      final parsed = OfflineTaskParser.parse(
        'create grocery list category Work',
        categories,
        templates,
      );
      
      expect(parsed.title, equals('Grocery List'));
      expect(parsed.category, equals('Work')); // override category
      expect(parsed.subtasks, equals([
        'Fruits & Vegetables',
        'Milk & Dairy',
        'Bread & Bakery',
        'Protein/Meat',
        'Pantry Essentials'
      ]));
    });
  });
}
