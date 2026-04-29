import 'package:dexdo/services/ai_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeGenerativeModel extends Fake implements GenerativeModel {
  @override
  Future<GenerateContentResponse> generateContent(Iterable<Content> prompt,
      {List<SafetySetting>? safetySettings, GenerationConfig? generationConfig}) async {
    return GenerateContentResponse([
      Candidate(
        Content('model', [TextPart('Subtask 1\nSubtask 2\nSubtask 3')]),
        null,
        null,
        null,
        null,
      )
    ], null);
  }

  @override
  Stream<GenerateContentResponse> generateContentStream(Iterable<Content> prompt,
      {List<SafetySetting>? safetySettings, GenerationConfig? generationConfig}) async* {
    yield GenerateContentResponse([
      Candidate(Content('model', [TextPart('Subtask 1\nSubtask 2\nSubtask 3')]), null, null, null, null)
    ], null);
  }
}

void main() {
  group('AIService Unit Tests', () {
    late AIService aiService;
    late FakeGenerativeModel fakeModel;

    setUp(() {
      fakeModel = FakeGenerativeModel();
      aiService = AIService(model: fakeModel);
    });

    test('breakdownTask returns parsed lines', () async {
      final result = await aiService.breakdownTask('My Task');
      expect(result.length, 3);
      expect(result[0], 'Subtask 1');
      expect(result[1], 'Subtask 2');
      expect(result[2], 'Subtask 3');
    });

    test('breakdownTaskStream streams output', () async {
      final streamResult = await aiService.breakdownTaskStream('My Task').toList();
      expect(streamResult.length, 1);
      expect(streamResult[0], 'Subtask 1\nSubtask 2\nSubtask 3');
    });
  });
}
