import 'package:dexdo/core/services/parsed_voice_task.dart';
import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:dexdo/features/tasks/domain/entities/task_templates.dart';

class OfflineTaskParser {
  /// Parses a voice command transcript into a structured [ParsedVoiceTask] completely offline.
  static ParsedVoiceTask parse(
    String transcript,
    List<String> categories, [
    List<TaskTemplate> templates = const [],
  ]) {
    if (transcript.trim().isEmpty) {
      return ParsedVoiceTask(title: 'New Voice Task');
    }

    String workingText = transcript;

    // 0. Match against templates
    TaskTemplate? matchedTemplate;
    final sortedTemplates = List<TaskTemplate>.from(templates)
      ..sort((a, b) => b.name.length.compareTo(a.name.length));

    for (final template in sortedTemplates) {
      final templateRegex = RegExp(
        '\\b${RegExp.escape(template.name)}\\b(?:\\s+(?:template|checklist|routine|list))?\\b|\\b(?:template|checklist|routine|list)\\s+for\\s+${RegExp.escape(template.name)}\\b',
        caseSensitive: false,
      );
      if (templateRegex.hasMatch(workingText)) {
        matchedTemplate = template;
        workingText = workingText.replaceAll(templateRegex, '');
        break;
      }
    }

    // 1. Extract Due Date and Time (on the original full text to avoid partial matches)
    final DateTime? dueDate = _extractDueDate(transcript);
    
    // Strip date/time patterns from the working text
    workingText = _stripDateTimePatterns(workingText);

    // 2. Extract Priority
    final TaskPriority? priority = _extractPriority(workingText);
    workingText = _stripPriorityPatterns(workingText);

    // 3. Extract Recurrence
    final String? recurrence = _extractRecurrence(workingText);
    workingText = _stripRecurrencePatterns(workingText);

    // 4. Extract Category
    String? category = _extractCategory(workingText, categories);
    if (category != null) {
      workingText = _stripCategoryPatterns(workingText, category);
    } else if (matchedTemplate != null) {
      category = matchedTemplate.category;
    }

    // 5. Extract Subtasks
    List<String>? subtasks = _extractSubtasks(workingText);
    if (subtasks != null) {
      workingText = _stripSubtasksPatterns(workingText);
    } else if (matchedTemplate != null) {
      subtasks = matchedTemplate.subtaskTitles;
    }

    // 6. Extract Description & Title
    String? description;
    final descRegex = RegExp(
      r'\b(?:description|desc|details|note|about):?\s*(.*)',
      caseSensitive: false,
    );
    final descMatch = descRegex.firstMatch(workingText);
    if (descMatch != null) {
      description = descMatch.group(1)?.trim();
      // Remove everything from the description keyword to the end of the text
      workingText = workingText.substring(0, descMatch.start).trim();
    }

    // Clean up remaining text to form the title
    String title = _cleanTitle(workingText);

    if (title.isEmpty) {
      if (matchedTemplate != null) {
        title = matchedTemplate.name;
      } else {
        // Fallback: Use a truncated version of the original transcript
        title = transcript.length > 50 ? '${transcript.substring(0, 47)}...' : transcript;
      }
    } else if (matchedTemplate != null && RegExp(r'^(?:apply|use|create|new|run|add)$', caseSensitive: false).hasMatch(title)) {
      title = matchedTemplate.name;
    }

    return ParsedVoiceTask(
      title: title,
      description: description,
      dueDate: dueDate,
      category: category,
      priority: priority,
      recurrence: recurrence ?? 'none',
      subtasks: subtasks,
    );
  }

  static DateTime? _extractDueDate(String text) {
    final now = DateTime.now();
    final DateTime? date = _extractDateOnly(text, now);
    if (date == null) {
      // If no date was found but time was specified (e.g. "at 5pm"), assume today
      final timeOnly = _parseTimeOnly(text, now);
      return timeOnly;
    }
    
    // Try to parse time and attach it to the parsed date
    final dateTimeWithTime = _parseTimeOnly(text, date);
    return dateTimeWithTime ?? date;
  }

  static DateTime? _extractDateOnly(String text, DateTime now) {
    final cleanText = text.toLowerCase();
    
    if (RegExp(r'\bday after tomorrow\b').hasMatch(cleanText)) {
      return DateTime(now.year, now.month, now.day).add(const Duration(days: 2));
    }
    if (RegExp(r'\btomorrow\b').hasMatch(cleanText)) {
      return DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    }
    if (RegExp(r'\btoday\b').hasMatch(cleanText)) {
      return DateTime(now.year, now.month, now.day);
    }
    if (RegExp(r'\bnext week\b|\bin a week\b').hasMatch(cleanText)) {
      return DateTime(now.year, now.month, now.day).add(const Duration(days: 7));
    }

    // Weekday match: "next Friday" or "on Friday" or "Friday"
    final weekdayDate = _parseWeekday(text, now);
    if (weekdayDate != null) return weekdayDate;

    // Explicit date match: "June 25th" or "12/25/2026"
    final explicitDate = _parseExplicitDate(text, now);
    if (explicitDate != null) return explicitDate;

    return null;
  }

  static DateTime? _parseWeekday(String text, DateTime now) {
    final weekdayRegex = RegExp(
      r'\b(?:(next|on)\s+)?(monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b',
      caseSensitive: false,
    );
    final match = weekdayRegex.firstMatch(text);
    if (match == null) return null;

    final isNext = match.group(1)?.toLowerCase() == 'next';
    final weekdayStr = match.group(2)!.toLowerCase();

    final weekdays = {
      'monday': DateTime.monday,
      'tuesday': DateTime.tuesday,
      'wednesday': DateTime.wednesday,
      'thursday': DateTime.thursday,
      'friday': DateTime.friday,
      'saturday': DateTime.saturday,
      'sunday': DateTime.sunday,
    };

    final targetWeekday = weekdays[weekdayStr]!;
    int daysToAdd = targetWeekday - now.weekday;
    if (daysToAdd <= 0) {
      daysToAdd += 7;
    }
    if (isNext) {
      daysToAdd += 7;
    }
    
    return DateTime(now.year, now.month, now.day).add(Duration(days: daysToAdd));
  }

  static DateTime? _parseExplicitDate(String text, DateTime now) {
    // 1. YYYY-MM-DD
    final yyyymmdd = RegExp(r'\b(\d{4})[-/](\d{1,2})[-/](\d{1,2})\b');
    var match = yyyymmdd.firstMatch(text);
    if (match != null) {
      final year = int.tryParse(match.group(1)!) ?? now.year;
      final month = int.tryParse(match.group(2)!) ?? now.month;
      final day = int.tryParse(match.group(3)!) ?? now.day;
      return DateTime(year, month, day);
    }

    // 2. MM/DD/YYYY or MM/DD
    final mmddyyyy = RegExp(r'\b(\d{1,2})[-/](\d{1,2})(?:[-/](\d{2,4}))?\b');
    match = mmddyyyy.firstMatch(text);
    if (match != null) {
      final first = int.parse(match.group(1)!);
      final second = int.parse(match.group(2)!);
      final thirdStr = match.group(3);
      
      int month;
      int day;
      int year = now.year;

      if (thirdStr != null) {
        int parsedYear = int.parse(thirdStr);
        if (parsedYear < 100) {
          parsedYear += 2000;
        }
        year = parsedYear;
      }

      if (first > 12) {
        day = first;
        month = second;
      } else if (second > 12) {
        month = first;
        day = second;
      } else {
        month = first;
        day = second;
      }

      if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
        return DateTime(year, month, day);
      }
    }

    // 3. "June 25th" or "25 June"
    final months = {
      'jan': 1, 'january': 1,
      'feb': 2, 'february': 2,
      'mar': 3, 'march': 3,
      'apr': 4, 'april': 4,
      'may': 5,
      'jun': 6, 'june': 6,
      'jul': 7, 'july': 7,
      'aug': 8, 'august': 8,
      'sep': 9, 'september': 9,
      'oct': 10, 'october': 10,
      'nov': 11, 'november': 11,
      'dec': 12, 'december': 12,
    };

    final monthNamesPattern = months.keys.join('|');
    
    // Month Day
    final monthDayRegex = RegExp(
      '\\b($monthNamesPattern)\\s+(\\d{1,2})(?:st|nd|rd|th)?\\b',
      caseSensitive: false,
    );
    match = monthDayRegex.firstMatch(text);
    if (match != null) {
      final mStr = match.group(1)!.toLowerCase();
      final dStr = match.group(2)!;
      final month = months[mStr]!;
      final day = int.parse(dStr);
      return DateTime(now.year, month, day);
    }

    // Day Month
    final dayMonthRegex = RegExp(
      '\\b(\\d{1,2})(?:st|nd|rd|th)?(?:\\s+of)?\\s+($monthNamesPattern)\\b',
      caseSensitive: false,
    );
    match = dayMonthRegex.firstMatch(text);
    if (match != null) {
      final dStr = match.group(1)!;
      final mStr = match.group(2)!.toLowerCase();
      final month = months[mStr]!;
      final day = int.parse(dStr);
      return DateTime(now.year, month, day);
    }

    return null;
  }

  static DateTime? _parseTimeOnly(String text, DateTime date) {
    // Matches "at 5pm", "at 5:30 am", "at 17:00", "5:30 pm"
    final timeRegex = RegExp(
      r'\b(?:at\s+)?(\d{1,2})(?::(\d{2}))?\s*(am|pm)\b|\b(?:at\s+)(\d{1,2}):(\d{2})\b',
      caseSensitive: false,
    );
    final match = timeRegex.firstMatch(text);
    if (match == null) return null;

    int hour = 0;
    int minute = 0;
    String? ampm;

    if (match.group(1) != null) {
      hour = int.parse(match.group(1)!);
      minute = match.group(2) != null ? int.parse(match.group(2)!) : 0;
      ampm = match.group(3)?.toLowerCase();
    } else {
      hour = int.parse(match.group(4)!);
      minute = int.parse(match.group(5)!);
    }

    if (ampm == 'pm' && hour < 12) {
      hour += 12;
    } else if (ampm == 'am' && hour == 12) {
      hour = 0;
    }

    if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
      return DateTime(date.year, date.month, date.day, hour, minute);
    }
    return null;
  }

  static String _stripDateTimePatterns(String text) {
    final dateRegexes = [
      RegExp(r'\bday after tomorrow\b', caseSensitive: false),
      RegExp(r'\btomorrow\b', caseSensitive: false),
      RegExp(r'\btoday\b', caseSensitive: false),
      RegExp(r'\bnext week\b|\bin a week\b', caseSensitive: false),
      RegExp(r'\b(?:next|on)\s+(?:monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b', caseSensitive: false),
      RegExp(r'\b(?:monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b', caseSensitive: false),
      RegExp(r'\b\d{4}[-/]\d{1,2}[-/]\d{1,2}\b'),
      RegExp(r'\b\d{1,2}[-/]\d{1,2}(?:[-/]\d{2,4})?\b'),
      RegExp(r'\b(?:january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|oct|nov|dec)\s+\d{1,2}(?:st|nd|rd|th)?\b', caseSensitive: false),
      RegExp(r'\b\d{1,2}(?:st|nd|rd|th)?(?:\s+of)?\s+(?:january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sep|oct|nov|dec)\b', caseSensitive: false),
      RegExp(r'\b(?:at\s+)?\d{1,2}(?::\d{2})?\s*(am|pm)\b|\b(?:at\s+)\d{1,2}:\d{2}\b', caseSensitive: false),
    ];

    String result = text;
    for (final regex in dateRegexes) {
      result = result.replaceAll(regex, '');
    }
    return result;
  }

  static TaskPriority? _extractPriority(String text) {
    // Check "priority high", "high priority", etc.
    final priorityRegex = RegExp(
      r'\b(?:priority\s+is\s+|priority:?\s*)(low|medium|high|urgent)\b|\b(urgent|high priority|low priority)\b',
      caseSensitive: false,
    );
    final match = priorityRegex.firstMatch(text);
    if (match == null) return null;

    final pStr = (match.group(1) ?? match.group(2))!.toLowerCase();
    if (pStr.contains('urgent')) return TaskPriority.urgent;
    if (pStr.contains('high')) return TaskPriority.high;
    if (pStr.contains('low')) return TaskPriority.low;
    return TaskPriority.medium;
  }

  static String _stripPriorityPatterns(String text) {
    final priorityRegex = RegExp(
      r'\b(?:priority\s+is\s+|priority:?\s*)(low|medium|high|urgent)\b|\b(urgent|high priority|low priority)\b',
      caseSensitive: false,
    );
    return text.replaceAll(priorityRegex, '');
  }

  static String? _extractRecurrence(String text) {
    final recurrenceRegex = RegExp(
      r'\b(?:recurrence:?\s*)?(daily|weekly|monthly|yearly)\b|\b(?:every|each)\s+(day|week|month|year)\b',
      caseSensitive: false,
    );
    final match = recurrenceRegex.firstMatch(text);
    if (match == null) return null;

    final rStr = (match.group(1) ?? match.group(2))!.toLowerCase();
    if (rStr == 'day' || rStr == 'daily') return 'daily';
    if (rStr == 'week' || rStr == 'weekly') return 'weekly';
    if (rStr == 'month' || rStr == 'monthly') return 'monthly';
    if (rStr == 'year' || rStr == 'yearly') return 'yearly';
    return 'none';
  }

  static String _stripRecurrencePatterns(String text) {
    final recurrenceRegex = RegExp(
      r'\b(?:recurrence:?\s*)?(daily|weekly|monthly|yearly)\b|\b(?:every|each)\s+(day|week|month|year)\b',
      caseSensitive: false,
    );
    return text.replaceAll(recurrenceRegex, '');
  }

  static String _stripCategoryPatterns(String text, String category) {
    final prefixRegex = RegExp(
      '\\bcategory:?\\s*(${RegExp.escape(category)})\\b',
      caseSensitive: false,
    );
    if (prefixRegex.hasMatch(text)) {
      return text.replaceAll(prefixRegex, '');
    }
    final standaloneRegex = RegExp(
      '\\b(${RegExp.escape(category)})\\b',
      caseSensitive: false,
    );
    return text.replaceAll(standaloneRegex, '');
  }

  static String? _extractCategory(String text, List<String> categories) {
    final cleanCategories = categories.where((c) => c != 'All').toList();
    final sortedCategories = List<String>.from(cleanCategories)
      ..sort((a, b) => b.length.compareTo(a.length));

    // 1. Explicit Category Label Match (e.g. "category Shopping")
    for (final cat in sortedCategories) {
      final prefixRegex = RegExp(
        '\\bcategory:?\\s*(${RegExp.escape(cat)})\\b',
        caseSensitive: false,
      );
      if (prefixRegex.hasMatch(text)) {
        return cat;
      }
    }

    // 2. Standalone Keyword Match
    for (final cat in sortedCategories) {
      final standaloneRegex = RegExp(
        '\\b(${RegExp.escape(cat)})\\b',
        caseSensitive: false,
      );
      if (standaloneRegex.hasMatch(text)) {
        return cat;
      }
    }

    return null;
  }

  static List<String>? _extractSubtasks(String text) {
    final subtasksRegex = RegExp(
      r'\b(?:subtasks|steps|checklist|items)\b\s*(?::|for|of|to\s+do)?\s*(.*)',
      caseSensitive: false,
    );
    final match = subtasksRegex.firstMatch(text);
    if (match == null) return null;

    final subtasksPart = match.group(1)!;
    if (subtasksPart.trim().isEmpty) return null;

    final rawItems = subtasksPart.split(RegExp(r',|\band\b|\bthen\b', caseSensitive: false));
    final List<String> items = [];
    for (final raw in rawItems) {
      final clean = raw.trim();
      if (clean.isNotEmpty) {
        final capitalized = clean[0].toUpperCase() + clean.substring(1);
        items.add(capitalized);
      }
    }
    return items.isNotEmpty ? items : null;
  }

  static String _stripSubtasksPatterns(String text) {
    final subtasksRegex = RegExp(
      r'\b(?:subtasks|steps|checklist|items)\b\s*(?::|for|of|to\s+do)?\s*(.*)',
      caseSensitive: false,
    );
    final match = subtasksRegex.firstMatch(text);
    if (match == null) return text;
    // Strip everything from the subtasks keyword to the end of the text
    return text.substring(0, match.start).trim();
  }

  static String _cleanTitle(String text) {
    // Replace duplicate whitespaces
    String clean = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // Remove leading/trailing formatting punctuation
    clean = clean.replaceAll(RegExp(r'^[-:,.\s]+|[-:,.\s]+$'), '').trim();

    // Remove leading helper words if any are left at the very start of the sentence
    clean = clean.replaceAll(RegExp(r'^(?:with|for|to|a|an|the)\s+', caseSensitive: false), '').trim();

    // Remove trailing helper words if any are left at the very end of the sentence
    clean = clean.replaceAll(RegExp(r'\s+(?:with|for|to|at|on|of|a|an|the)$', caseSensitive: false), '').trim();

    if (clean.isEmpty) return '';

    // Capitalize first letter
    return clean[0].toUpperCase() + clean.substring(1);
  }
}
