import 'package:flutter/material.dart';

class SubTask {
  final String id;
  String title;
  bool isCompleted;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory SubTask.fromJson(Map<String, dynamic> map) {
    return SubTask(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}

class Task {
  final String id;
  String title;
  String description;
  bool isCompleted;
  DateTime? completionDate;
  bool isStarred;
  IconData icon;
  Color color;
  String category;
  int attachmentCount;
  List<SubTask> subtasks;
  DateTime? dueDate;
  int orderIndex;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.completionDate,
    this.isStarred = false,
    this.icon = Icons.task_alt,
    this.color = Colors.blue,
    this.category = 'Personal',
    this.attachmentCount = 0,
    List<SubTask>? subtasks,
    this.dueDate,
    this.orderIndex = 0,
  }) : subtasks = subtasks ?? [];

  int get subtaskCount => subtasks.length;
  int get completedSubtaskCount => subtasks.where((s) => s.isCompleted).toList().length;
  double get progress => subtasks.isEmpty ? 0 : completedSubtaskCount / subtaskCount;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? completionDate,
    bool? isStarred,
    IconData? icon,
    Color? color,
    String? category,
    int? attachmentCount,
    List<SubTask>? subtasks,
    DateTime? dueDate,
    int? orderIndex,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      completionDate: completionDate ?? this.completionDate,
      isStarred: isStarred ?? this.isStarred,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      category: category ?? this.category,
      attachmentCount: attachmentCount ?? this.attachmentCount,
      subtasks: subtasks ?? this.subtasks,
      dueDate: dueDate ?? this.dueDate,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'completionDate': completionDate?.toIso8601String(),
      'isStarred': isStarred ? 1 : 0,
      'icon': icon.codePoint,
      'color': color.toARGB32(),
      'category': category,
      'attachmentCount': attachmentCount,
      'subtasks': subtasks.map((s) => s.toJson()).toList(),
      'dueDate': dueDate?.toIso8601String(),
      'orderIndex': orderIndex,
    };
  }

  factory Task.fromJson(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      isCompleted: map['isCompleted'] == 1,
      completionDate: map['completionDate'] != null ? DateTime.parse(map['completionDate']) : null,
      isStarred: map['isStarred'] == 1,
      icon: IconData(map['icon'] ?? Icons.task_alt.codePoint, fontFamily: 'MaterialIcons'),
      color: Color(map['color'] ?? Colors.blue.toARGB32()),
      category: map['category'] ?? 'All',
      attachmentCount: map['attachmentCount'] ?? 0,
      subtasks: (map['subtasks'] as List<dynamic>?)
          ?.map((s) => SubTask.fromJson(s))
          .toList() ?? [],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      orderIndex: map['orderIndex'] ?? 0,
    );
  }
}
