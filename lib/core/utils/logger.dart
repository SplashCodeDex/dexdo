import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// A professional logging utility that wraps the 'logger' package and
/// integrates with Firebase Crashlytics.
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// Log a message at level [Level.debug].
  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log a message at level [Level.info].
  static void i(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log a message at level [Level.warning].
  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
    
    // Also record warnings to Crashlytics as non-fatal
    _recordToCrashlytics(message, error, stackTrace, fatal: false);
  }

  /// Log a message at level [Level.error].
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    
    // Also record errors to Crashlytics as fatal if it's a critical error
    _recordToCrashlytics(message, error, stackTrace, fatal: true);
  }

  /// Internal helper to record errors to Firebase Crashlytics.
  static void _recordToCrashlytics(
    String message,
    dynamic error,
    StackTrace? stackTrace, {
    required bool fatal,
  }) {
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.log(message);
      if (error != null) {
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: message,
          fatal: fatal,
        );
      }
    }
  }
}
