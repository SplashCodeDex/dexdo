import 'package:dexdo/providers/theme_provider.dart';
import 'package:dexdo/widgets/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('AnimatedSplashScreen renders correctly', (WidgetTester tester) async {
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ],
        child: const MaterialApp(
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
