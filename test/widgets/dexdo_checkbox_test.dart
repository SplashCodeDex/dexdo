import 'package:dexdo/shared/widgets/dexdo_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DexDoCheckBox toggles state on tap', (WidgetTester tester) async {
    bool value = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DexDoCheckBox(
            value: value,
            onChanged: (newValue) {
              value = newValue;
            },
          ),
        ),
      ),
    );

    // Initial state: not completed
    expect(value, isFalse);

    // Tap the checkbox
    await tester.tap(find.byType(DexDoCheckBox));
    await tester.pumpAndSettle();

    // Check if value changed
    expect(value, isTrue);
  });

  testWidgets('DexDoCheckBox shows progress ring when progress is provided', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DexDoCheckBox(
            value: false,
            progress: 0.5,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
