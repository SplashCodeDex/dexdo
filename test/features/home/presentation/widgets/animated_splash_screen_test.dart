import 'package:dexdo/features/home/presentation/widgets/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AnimatedSplashScreen renders and calls onComplete', (WidgetTester tester) async {
    bool completed = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: AnimatedSplashScreen(
            onComplete: () => completed = true,
          ),
        ),
      ),
    );

    // Pump through the entire animation (total ~1500ms of staged animation)
    await tester.pump(const Duration(milliseconds: 2000));

    expect(find.byType(AnimatedSplashScreen), findsOneWidget);
    expect(completed, true);
  });
}
