import 'package:dexdo/core/theme/theme_provider.dart';
import 'package:dexdo/features/home/presentation/widgets/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('AnimatedSplashScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AnimatedSplashScreen(),
        ),
      ),
    );

    // Initial pump and a few frames for animation
    await tester.pumpAndSettle();

    expect(find.byType(AnimatedSplashScreen), findsOneWidget);
    // Find Image or logo
    expect(find.byType(Image), findsWidgets);
    expect(find.text('DexDo'), findsWidgets);
  });
}
