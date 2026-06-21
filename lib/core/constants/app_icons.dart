import 'package:flutter/material.dart';

class AppIcons {
  static const Map<String, IconData> availableIcons = {
    'work': Icons.work_rounded,
    'wallet': Icons.account_balance_wallet_rounded,
    'fitness': Icons.fitness_center_rounded,
    'home': Icons.home_rounded,
    'person': Icons.person_rounded,
    'shopping': Icons.shopping_cart_rounded,
    'book': Icons.book_rounded,
    'movie': Icons.movie_rounded,
    'restaurant': Icons.restaurant_rounded,
    'flight': Icons.flight_rounded,
    'code': Icons.code_rounded,
    'brush': Icons.brush_rounded,
    'task_alt': Icons.task_alt,
    'category': Icons.category_rounded,
  };

  /// Fallback icon if none is found.
  static const IconData defaultIcon = Icons.task_alt;

  /// Looks up an icon by its string key. Returns [defaultIcon] if not found.
  static IconData fromString(String name) => availableIcons[name] ?? defaultIcon;

  /// Returns the string key for a given icon. Returns 'task_alt' if not found.
  static String toStringKey(IconData icon) {
    for (final entry in availableIcons.entries) {
      if (entry.value == icon) return entry.key;
    }
    return 'task_alt';
  }

  /// Safely resolves legacy integer code points to a const IconData.
  /// If the code point is not found in the predefined list, it returns [defaultIcon].
  static IconData fromLegacyCodePoint(int codePoint) {
    for (final icon in availableIcons.values) {
      if (icon.codePoint == codePoint) return icon;
    }
    return defaultIcon;
  }
}
