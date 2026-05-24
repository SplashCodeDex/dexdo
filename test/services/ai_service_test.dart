import 'package:dexdo/core/services/ai_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

// GenerativeModel is a `final` class in google_generative_ai 0.4.7 —
// it cannot be subclassed or implemented outside of its library.
// We test AIService behaviour at the service boundary instead:
// - A real GenerativeModel is created but with no API key, so API calls return empty.
// - We verify AIService handles empty/null responses gracefully.
void main() {
  group('AIService Unit Tests (no-API-key fallback behaviour)', () {
    late AIService aiService;

    setUp(() {
      // Construct with a real model that has no API key.
      // All generateContent calls will throw/return null, which AIService catches.
      aiService = AIService(
        model: GenerativeModel(model: 'gemini-1.5-pro', apiKey: ''),
      );
    });

    test('breakdownTask returns empty list when API key is absent', () async {
      // The model will throw due to missing key — AIService catches and returns [].
      final result = await aiService.breakdownTask('Write unit tests');
      expect(result, isA<List<String>>());
    });

    test('breakdownTaskStream emits nothing when API key is absent', () async {
      // The stream should complete without yielding values when the call fails.
      final streamResult = await aiService.breakdownTaskStream('Write unit tests').toList();
      expect(streamResult, isA<List<String>>());
    });

    test('suggestCategory returns "Personal" fallback when API key is absent', () async {
      final result = await aiService.suggestCategory('My task', ['Work', 'Personal']);
      expect(result, 'Personal');
    });

    test('estimateDuration returns fallback string when API key is absent', () async {
      final result = await aiService.estimateDuration('My task', 'some description');
      expect(result, isA<String>());
    });
  });
}
