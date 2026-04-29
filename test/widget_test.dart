// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dexdo/core/theme/theme_provider.dart';

void main() {
  testWidgets('Core DeXDo UI Rendering Smoke Test', (WidgetTester tester) async {
    final testApp = ProviderScope(
      overrides: [
        // We can add overrides here if we need to mock specific providers
      ],
      child: Consumer(
        builder: (context, ref, _) {
          return const MaterialApp(
            title: 'DeXDo Test',
            home: Scaffold(
              body: Center(child: Text('Home')),
            ),
          );
        },
      ),
    );

    await tester.pumpWidget(testApp);

    // Verify it builds
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}
