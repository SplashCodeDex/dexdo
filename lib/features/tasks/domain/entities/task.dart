import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class SubTask with _$SubTask {
  const factory SubTask({
    required String id,
    required String title,
    @Default(false) bool isCompleted,
  }) = _SubTask;

  factory SubTask.fromJson(Map<String, dynamic> json) => _$SubTaskFromJson(json);
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent;

  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.purple;
    }
  }
}

@freezed
class Task with _$Task {
  const Task._();

  const factory Task({
    required String id,
    required String title,
    @Default('') String description,
    @Default(false) bool isCompleted,
    DateTime? completionDate,
    @Default(false) bool isStarred,
    @IconDataConverter() @Default(Icons.task_alt) IconData icon,
    @ColorConverter() @Default(Colors.blue) Color color,
    @Default('Personal') String category,
    @Default(0) int attachmentCount,
    @Default([]) List<SubTask> subtasks,
    DateTime? dueDate,
    @Default(0) int orderIndex,
    @Default('none') String recurrence,
    @Default(TaskPriority.medium) TaskPriority priority,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  int get subtaskCount => subtasks.length;
  int get completedSubtaskCount => subtasks.where((s) => s.isCompleted).length;
  double get progress => subtasks.isEmpty ? 0 : completedSubtaskCount / subtaskCount;
}

class IconDataConverter implements JsonConverter<IconData, int> {
  const IconDataConverter();

  @override
  IconData fromJson(int json) => IconData(json, fontFamily: 'MaterialIcons');

  @override
  int toJson(IconData object) => object.codePoint;
}

class ColorConverter implements JsonConverter<Color, int> {
  const ColorConverter();

  @override
  Color fromJson(int json) => Color(json);

  @override
  int toJson(Color object) => object.toARGB32();
}
