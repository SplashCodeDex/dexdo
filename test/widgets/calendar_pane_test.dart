import 'package:dexdo/models/task.dart' as dexdo_task;
import 'package:dexdo/providers/task_provider.dart';
import 'package:dexdo/providers/theme_provider.dart';
import 'package:dexdo/widgets/calendar_pane.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dexdo/repositories/task_repository.dart';

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
    final taskProvider = TaskProvider(repository: FakeTaskRepository());
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<TaskProvider>.value(value: taskProvider),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
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
