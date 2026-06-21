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
}
