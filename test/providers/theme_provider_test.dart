import 'package:dexdo/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial theme is Light/System depending on SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'isDarkMode': false});
      final provider = ThemeProvider();
      await Future.delayed(Duration.zero); // allow constructor async to finish (if any)
      expect(provider.isDarkMode, false);
      expect(provider.themeMode, ThemeMode.light);
    });

    test('Toggle theme updates mode and saves to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'isDarkMode': false});
      final provider = ThemeProvider();
      
      await provider.toggleTheme();
      
      expect(provider.isDarkMode, true);
      expect(provider.themeMode, ThemeMode.dark);
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('isDarkMode'), true);
    });
  });
}
