import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/logger.dart';

class AIService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  
  final GenerativeModel _model;

  AIService({GenerativeModel? model}) : _model = model ?? GenerativeModel(
    model: 'gemini-1.5-pro',
    apiKey: _apiKey,
  );

  /// Breakdown task with streaming support for better UX
  Stream<String> breakdownTaskStream(String taskTitle) async* {
    final prompt = 'Break down the following task into a list of actionable subtasks (max 5). '
        'Provide only the subtask names, one per line, without any numbering or extra text: "$taskTitle"';

    try {
      final content = [Content.text(prompt)];
      final responseStream = _model.generateContentStream(content);
      
      await for (final chunk in responseStream) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e, stack) {
      AppLogger.e('Error streaming task breakdown with AI', e, stack);
    }
  }

  Future<List<String>> breakdownTask(String taskTitle) async {
    final prompt = 'Break down the following task into a list of 5 actionable subtasks. '
        'Provide only the subtask names, one per line, without any numbering or extra text: "$taskTitle"';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text == null || response.text!.isEmpty) {
        return [];
      }

      return response.text!
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (e, stack) {
      AppLogger.e('Error breaking down task with AI', e, stack);
      return [];
    }
  }
}
