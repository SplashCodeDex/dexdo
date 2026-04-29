import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.system;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final int? themeIndex = prefs.getInt('themeMode');
    if (themeIndex != null) {
      state = ThemeMode.values[themeIndex];
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', state.index);
  }

  bool isDarkMode(BuildContext context) {
    if (state == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return state == ThemeMode.dark;
  }
}
