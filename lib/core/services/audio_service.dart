import 'package:dexdo/core/utils/logger.dart';
import 'package:flutter/services.dart';

class AudioService {
  static const _channel = MethodChannel('com.dexify.dexdo/audio');

  /// Play a warm synthesized audio chime natively on Android.
  static Future<void> playVoiceTriggerSound() async {
    try {
      await _channel.invokeMethod('playVoiceTrigger');
    } catch (e, stack) {
      AppLogger.e('AudioService MethodChannel error', e, stack);
    }
  }

  /// Temporarily mute streams to silence the default Android SpeechRecognizer beep.
  static Future<void> muteSpeechRecognizerBeep() async {
    try {
      await _channel.invokeMethod('muteSpeechRecognizerBeep');
    } catch (e, stack) {
      AppLogger.e('AudioService mute error', e, stack);
    }
  }

  /// Restore audio streams to their original volume.
  static Future<void> unmuteSpeechRecognizerBeep() async {
    try {
      await _channel.invokeMethod('unmuteSpeechRecognizerBeep');
    } catch (e, stack) {
      AppLogger.e('AudioService unmute error', e, stack);
    }
  }
}
