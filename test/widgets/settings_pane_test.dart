import 'package:dexdo/core/theme/theme_provider.dart';
import 'package:dexdo/features/settings/presentation/widgets/settings_pane.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('SettingsPane displays basic settings options', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: SettingsPane()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(SettingsPane), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget); // Fixed the text check based on HomePane/SettingsPane actual title
  });
}
