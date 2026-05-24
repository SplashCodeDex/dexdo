import 'package:dexdo/features/auth/presentation/providers/auth_provider.dart';
import 'package:dexdo/features/settings/presentation/widgets/settings_pane.dart';
import 'package:dexdo/features/tasks/data/repositories/task_repository_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../mocks.dart';

void main() {
  testWidgets('SettingsPane displays basic settings options', (WidgetTester tester) async {
    final mockAuthRepo = MockAuthRepository();
    mockAuthRepo.simulateUser(MockUser(isAnonymous: true));

    final mockTaskRepo = MockTaskRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepo),
          taskRepositoryProvider.overrideWithValue(mockTaskRepo),
        ],
        child: const MaterialApp(
          home: Scaffold(body: SettingsPane()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(SettingsPane), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
