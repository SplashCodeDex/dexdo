import 'package:dexdo/core/utils/logger.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {

  AIService({GenerativeModel? model}) : _model = model ?? GenerativeModel(
    model: 'gemini-1.5-pro',
    apiKey: _apiKey,
  );
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  
  final GenerativeModel _model;

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

  Future<String> suggestCategory(String taskTitle, List<String> categories) async {
    final cleanCategories = categories.where((c) => c != 'All').toList();
    if (cleanCategories.isEmpty) return 'Personal';
    
    final prompt = 'Given the task title "$taskTitle", select the single most appropriate category from this list: ${cleanCategories.join(", ")}. '
        'Provide only the selected category name word, exactly as listed, with no extra punctuation, thoughts, or numbering. If none perfectly fit, reply "Personal".';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text == null || response.text!.isEmpty) {
        return 'Personal';
      }
      final suggested = response.text!.trim();
      if (cleanCategories.contains(suggested)) {
        return suggested;
      }
      // Check case-insensitive match
      for (var cat in cleanCategories) {
        if (cat.toLowerCase() == suggested.toLowerCase()) {
          return cat;
        }
      }
      return 'Personal';
    } catch (e, stack) {
      AppLogger.e('Error suggesting category with AI', e, stack);
      return 'Personal';
    }
  }

  Future<String> estimateDuration(String taskTitle, String description) async {
    final prompt = 'Given the task title "$taskTitle" and description "$description", '
        'estimate how long this task should realistically take. Return a highly concise estimation (e.g., "30 mins", "2 hours", "1 day") '
        'and a single short sentence explaining why. Be very brief (max 20 words total).';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text?.trim() ?? 'No estimate available';
    } catch (e, stack) {
      AppLogger.e('Error estimating task duration with AI', e, stack);
      return 'No estimate available';
    }
  }
}
