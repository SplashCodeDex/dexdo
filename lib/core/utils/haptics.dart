import 'package:flutter/services.dart';

/// A professional utility class for managing device haptic feedback.
class AppHaptics {
  /// Provides feedback for successful short actions (e.g., button press).
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Provides feedback for significant actions (e.g., completing a task).
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Provides feedback for heavy/critical actions (e.g., deletion).
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Provides a standard success feedback pattern.
  static Future<void> success() async {
    await HapticFeedback.vibrate();
  }
}
