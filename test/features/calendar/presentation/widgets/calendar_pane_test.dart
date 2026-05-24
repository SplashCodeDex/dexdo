import 'package:dexdo/core/services/notification_service.dart';
import 'package:dexdo/features/calendar/presentation/widgets/calendar_pane.dart';
import 'package:dexdo/features/tasks/data/repositories/task_repository_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../mocks.dart';

void main() {
  testWidgets('CalendarPane displays calendar components', (WidgetTester tester) async {
    // Set a larger surface size to prevent overflow in headless test environment
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWithValue(MockTaskRepository()),
          notificationServiceProvider.overrideWithValue(MockNotificationService()),
        ],
        child: const MaterialApp(
          home: Scaffold(body: CalendarPane()),
        ),
      ),
    );

    // Let the animations run
    await tester.pumpAndSettle();

    expect(find.byType(CalendarPane), findsOneWidget);
    
    // Reset view size
    addTearDown(tester.view.resetPhysicalSize);
  });
}
