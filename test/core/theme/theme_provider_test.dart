import 'package:dexdo/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial theme defaults to ThemeMode.system', () {
      final theme = container.read(themeNotifierProvider);
      expect(theme, ThemeMode.system);
    });

    test('toggleTheme(true) switches to dark mode and saves to SharedPreferences', () async {
      final notifier = container.read(themeNotifierProvider.notifier);

      await notifier.toggleTheme(true);

      expect(container.read(themeNotifierProvider), ThemeMode.dark);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('themeMode'), ThemeMode.dark.index);
    });

    test('toggleTheme(false) switches to light mode', () async {
      final notifier = container.read(themeNotifierProvider.notifier);

      await notifier.toggleTheme(false);

      expect(container.read(themeNotifierProvider), ThemeMode.light);
    });
  });
}
