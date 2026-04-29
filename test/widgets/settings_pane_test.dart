import 'package:dexdo/providers/theme_provider.dart';
import 'package:dexdo/widgets/settings_pane.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('SettingsPane displays basic settings options', (WidgetTester tester) async {
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ],
        child: const MaterialApp(
          home: Scaffold(body: SettingsPane()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(SettingsPane), findsOneWidget);
    expect(find.text('Application Settings'), findsOneWidget);
  });
}
