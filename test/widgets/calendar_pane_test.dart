import 'package:dexdo/features/tasks/domain/entities/task.dart' as dexdo_task;
import 'package:dexdo/features/tasks/presentation/providers/task_provider.dart';
import 'package:dexdo/features/calendar/presentation/widgets/calendar_pane.dart';
import 'package:dexdo/features/tasks/domain/repositories/task_repository.dart';
import 'package:dexdo/features/tasks/data/repositories/task_repository_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Very basic manual fake
class FakeTaskRepository extends Fake implements TaskRepository {
  @override
  Future<void> init() async {}
  @override
  Future<List<String>> loadCategories() async => [];
  @override
  Future<Map<String, Color>> loadCategoryColors() async => {};
  @override
  Future<Map<String, IconData>> loadCategoryIcons() async => {};
  @override
  Future<List<dexdo_task.Task>> loadTasks() async => [];
}

void main() {
  testWidgets('CalendarPane displays calendar components', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
        ],
        child: const MaterialApp(
          home: Scaffold(body: CalendarPane()),
        ),
      ),
    );

    // Let the animations run
    await tester.pumpAndSettle();

    expect(find.byType(CalendarPane), findsOneWidget);
  });
}
