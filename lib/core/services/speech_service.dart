import 'package:dexdo/core/services/toast_service.dart';
import 'package:dexdo/core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechState {
  SpeechState({
    this.isListening = false,
    this.lastWords = '',
    this.soundLevel = 0.0,
    this.isAvailable = false,
    this.error = '',
  });

  final bool isListening;
  final String lastWords;
  final double soundLevel;
  final bool isAvailable;
  final String error;

  SpeechState copyWith({
    bool? isListening,
    String? lastWords,
    double? soundLevel,
    bool? isAvailable,
    String? error,
  }) {
    return SpeechState(
      isListening: isListening ?? this.isListening,
      lastWords: lastWords ?? this.lastWords,
      soundLevel: soundLevel ?? this.soundLevel,
      isAvailable: isAvailable ?? this.isAvailable,
      error: error ?? this.error,
    );
  }
}

class SpeechNotifier extends Notifier<SpeechState> {
  final SpeechToText _speech = SpeechToText();

  @override
  SpeechState build() {
    return SpeechState();
  }

  Future<bool> init() async {
    if (state.isAvailable) return true;
    try {
      final available = await _speech.initialize(
        onError: (val) {
          AppLogger.e('SpeechToText onError: ${val.errorMsg}');
          state = state.copyWith(error: val.errorMsg, isListening: false);
        },
        onStatus: (val) {
          AppLogger.d('SpeechToText onStatus: $val');
          if (val == 'listening') {
            state = state.copyWith(isListening: true);
          } else if (val == 'notListening' || val == 'done') {
            state = state.copyWith(isListening: false);
          }
        },
      );
      state = state.copyWith(isAvailable: available);
      return available;
    } catch (e, stack) {
      AppLogger.e('SpeechToText exception in init', e, stack);
      state = state.copyWith(error: e.toString(), isAvailable: false);
      return false;
    }
  }

  Future<void> startListening() async {
    final available = await init();
    if (!available) {
      AppLogger.w('SpeechToText initialization failed. Error: ${state.error}');
      state = state.copyWith(error: 'Speech recognition not available: ${state.error}');
      try {
        ref.read(toastProvider.notifier).showWarning(
          'Speech recognition not available: ${state.error}',
          title: 'Speech Error',
        );
      } catch (e, stack) {
        AppLogger.e('Error showing speech warning toast', e, stack);
      }
      return;
    }

    state = state.copyWith(lastWords: '', error: '');
    await _speech.listen(
      onResult: (val) {
        state = state.copyWith(lastWords: val.recognizedWords);
      },
      onSoundLevelChange: (level) {
        state = state.copyWith(soundLevel: level);
      },
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        cancelOnError: false,
        partialResults: true,
      ),
    );
    state = state.copyWith(isListening: true);
  }

  Future<void> stopListening() async {
    await _speech.stop();
    state = state.copyWith(isListening: false, soundLevel: 0.0);
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
    state = state.copyWith(isListening: false, lastWords: '', soundLevel: 0.0);
  }
}

final speechProvider = NotifierProvider<SpeechNotifier, SpeechState>(() {
  return SpeechNotifier();
});
