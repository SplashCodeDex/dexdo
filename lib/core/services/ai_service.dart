import 'dart:convert';
import 'package:dexdo/core/services/offline_task_parser.dart';
import 'package:dexdo/core/services/parsed_voice_task.dart';
import 'package:dexdo/core/utils/logger.dart';
import 'package:dexdo/features/tasks/domain/entities/task_templates.dart';
import 'package:flutter/material.dart' show Icons;
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

  Future<Map<String, List<String>>> generateBatchRoadmap(List<String> taskTitles) async {
    final prompt = 'I have a set of tasks: ${taskTitles.join(", ")}. '
        'For each task, provide 3 actionable subtasks. '
        'Format your response exactly as follows for each task:\n'
        'TASK: [Task Title]\n'
        'SUB: [Subtask 1]\n'
        'SUB: [Subtask 2]\n'
        'SUB: [Subtask 3]\n'
        'Repeat this for all tasks.';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        return {};
      }

      final lines = response.text!.split('\n');
      final Map<String, List<String>> roadmap = {};
      String? currentTask;

      for (var line in lines) {
        if (line.startsWith('TASK:')) {
          currentTask = line.replaceFirst('TASK:', '').trim();
          roadmap[currentTask] = [];
        } else if (line.startsWith('SUB:') && currentTask != null) {
          roadmap[currentTask]!.add(line.replaceFirst('SUB:', '').trim());
        }
      }
      return roadmap;
    } catch (e, stack) {
      AppLogger.e('Error generating batch roadmap with AI', e, stack);
      return {};
    }
  }

  Future<ParsedVoiceTask> parseVoiceCommand(
    String transcript,
    List<String> categories, [
    List<TaskTemplate> templates = const [],
  ]) async {
    final cleanCategories = categories.where((c) => c != 'All').toList();
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final weekdayStr = _getWeekdayName(now.weekday);

    final prompt = '''
You are a smart assistant parsing a voice command into a structured JSON task.
Current Date: $todayStr (today is $weekdayStr)
Available Categories: ${cleanCategories.join(", ")}

Voice command: "$transcript"

Please parse this voice command and return a JSON object with the following fields:
- "title": (String) A clear, short title for the task.
- "description": (String or null) Any extra context or description spoken, if present.
- "dueDate": (String or null) ISO-8601 date (YYYY-MM-DD) if a date/time is mentioned (e.g. "tomorrow", "next Friday", "at 5pm" is today, etc.). Resolve relative dates using the current date $todayStr.
- "category": (String or null) Select the most appropriate category from the available categories list. If none match, set to null.
- "priority": (String) Choose one of: "low", "medium", "high", "urgent". Default to "medium".
- "recurrence": (String) Choose one of: "none", "daily", "weekly", "monthly", "yearly". Default to "none".
- "subtasks": (Array of Strings or null) If subtasks are implied or requested, list them.

Return ONLY the raw JSON object. Do not wrap it in markdown code blocks or add any other text.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(
        content,
        generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      );
      
      final text = response.text;
      if (text == null || text.isEmpty) {
        return OfflineTaskParser.parse(transcript, cleanCategories, templates);
      }
      
      final json = jsonDecode(text.trim()) as Map<String, dynamic>;
      return ParsedVoiceTask.fromJson(json);
    } catch (e, stack) {
      AppLogger.e('Error parsing voice command with AI, falling back to offline parser', e, stack);
      return OfflineTaskParser.parse(transcript, cleanCategories, templates);
    }
  }

  Future<TaskTemplate> generateTemplateItems(String templateName, List<String> categories) async {
    final cleanCategories = categories.where((c) => c != 'All').toList();
    final prompt = '''
You are a creative planner. Generate a task template for: "$templateName".
Available Categories: ${cleanCategories.join(", ")}

Generate a JSON object with:
- "name": "$templateName"
- "category": Choose the best category from the list. Defaults to "Personal".
- "subtaskTitles": An array of 4 to 6 actionable subtasks for this template.

Return ONLY the raw JSON object. Do not wrap it in markdown code blocks or add any other text.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(
        content,
        generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      );
      
      final text = response.text;
      if (text != null && text.isNotEmpty) {
        final json = jsonDecode(text.trim()) as Map<String, dynamic>;
        final subtasks = List<String>.from(json['subtaskTitles'] as List);
        final category = json['category'] as String? ?? 'Personal';
        
        return TaskTemplate(
          id: 'template_ai_${DateTime.now().millisecondsSinceEpoch}',
          name: templateName,
          icon: Icons.auto_awesome,
          subtaskTitles: subtasks,
          category: category,
        );
      }
    } catch (e, stack) {
      AppLogger.e('Error generating template items with AI', e, stack);
    }
    
    return TaskTemplate(
      id: 'template_ai_${DateTime.now().millisecondsSinceEpoch}',
      name: templateName,
      icon: Icons.auto_awesome,
      subtaskTitles: const ['Step 1: Planning', 'Step 2: Execution', 'Step 3: Review'],
      category: 'Personal',
    );
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }
}
