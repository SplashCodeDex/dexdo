import 'package:dexdo/features/tasks/domain/entities/task.dart';

class ParsedVoiceTask {
  ParsedVoiceTask({
    required this.title,
    this.description,
    this.dueDate,
    this.category,
    this.priority,
    this.recurrence,
    this.subtasks,
  });

  factory ParsedVoiceTask.fromJson(Map<String, dynamic> json) {
    // Parse priority
    TaskPriority? priority;
    if (json['priority'] != null) {
      final pStr = json['priority'].toString().toLowerCase();
      priority = TaskPriority.values.firstWhere(
        (e) => e.name == pStr,
        orElse: () => TaskPriority.low,
      );
    }

    // Parse dueDate
    DateTime? dueDate;
    if (json['dueDate'] != null) {
      dueDate = DateTime.tryParse(json['dueDate'].toString());
    }

    // Parse subtasks
    List<String>? subtasks;
    if (json['subtasks'] != null) {
      subtasks = List<String>.from(json['subtasks'] as List);
    }

    return ParsedVoiceTask(
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      dueDate: dueDate,
      category: json['category'] as String?,
      priority: priority,
      recurrence: json['recurrence'] as String?,
      subtasks: subtasks,
    );
  }

  final String title;
  final String? description;
  final DateTime? dueDate;
  final String? category;
  final TaskPriority? priority;
  final String? recurrence;
  final List<String>? subtasks;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'category': category,
      'priority': priority?.name,
      'recurrence': recurrence,
      'subtasks': subtasks,
    };
  }
}
