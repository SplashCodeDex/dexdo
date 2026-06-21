import 'package:dexdo/core/constants/app_icons.dart';
import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:dexdo/features/tasks/domain/entities/task_templates.dart';
import 'package:flutter/material.dart';
import 'package:isar_plus/isar_plus.dart';

part 'task_model.g.dart';

/// Fast hash function for converting String IDs to 64-bit integers for Isar.
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;
  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit;
    hash *= 0x100000001b3;
  }
  return hash.toSigned(64);
}

@collection
class TaskModel {
  @id
  int isarId = 0;

  @Index(unique: true)
  late String taskId;

  late String title;
  late String description;
  @Index()
  late bool isCompleted;
  DateTime? completionDate;

  @Index()
  late bool isStarred;

  late int iconCodePoint;
  late int colorValue;

  @Index()
  late String category;
  late int attachmentCount;
  late List<SubTaskModel> subtasks;
  DateTime? dueDate;
  late int orderIndex;
  late String recurrence;
  
  late int priorityIndex;

  @Index()
  late bool isDeleted = false;
  DateTime? updatedAt;

  Task toEntity() {
    return Task(
      id: taskId,
      title: title,
      description: description,
      isCompleted: isCompleted,
      completionDate: completionDate,
      isStarred: isStarred,
      icon: AppIcons.fromLegacyCodePoint(iconCodePoint),
      color: Color(colorValue),
      category: category,
      attachmentCount: attachmentCount,
      subtasks: subtasks.map((s) => s.toEntity()).toList(),
      dueDate: dueDate,
      orderIndex: orderIndex,
      recurrence: recurrence,
      priority: TaskPriority.values[priorityIndex],
      isDeleted: isDeleted,
      updatedAt: updatedAt,
    );
  }

  static TaskModel fromEntity(Task task) {
    return TaskModel()
      ..isarId = fastHash(task.id)
      ..taskId = task.id
      ..title = task.title
      ..description = task.description
      ..isCompleted = task.isCompleted
      ..completionDate = task.completionDate
      ..isStarred = task.isStarred
      ..iconCodePoint = task.icon.codePoint
      ..colorValue = task.color.toARGB32()
      ..category = task.category
      ..attachmentCount = task.attachmentCount
      ..subtasks = task.subtasks.map((s) => SubTaskModel.fromEntity(s)).toList()
      ..dueDate = task.dueDate
      ..orderIndex = task.orderIndex
      ..recurrence = task.recurrence
      ..priorityIndex = task.priority.index
      ..isDeleted = task.isDeleted
      ..updatedAt = task.updatedAt;
  }
}

@collection
class CategoryModel {
  @id
  int isarId = 0;

  @Index(unique: true)
  late String name;

  late int iconCodePoint;
  late int colorValue;

  static CategoryModel fromData(String name, int iconCodePoint, int colorValue) {
    return CategoryModel()
      ..isarId = fastHash(name)
      ..name = name
      ..iconCodePoint = iconCodePoint
      ..colorValue = colorValue;
  }
}

@embedded
class SubTaskModel {
  late String id;
  late String title;
  late bool isCompleted;

  SubTask toEntity() {
    return SubTask(
      id: id,
      title: title,
      isCompleted: isCompleted,
    );
  }

  static SubTaskModel fromEntity(SubTask subTask) {
    return SubTaskModel()
      ..id = subTask.id
      ..title = subTask.title
      ..isCompleted = subTask.isCompleted;
  }
}

@collection
class TemplateModel {
  @id
  int isarId = 0;

  @Index(unique: true)
  late String templateId;

  late String name;
  late int iconCodePoint;
  late List<String> subtaskTitles;
  late String category;

  TaskTemplate toEntity() {
    return TaskTemplate(
      id: templateId,
      name: name,
      icon: AppIcons.fromLegacyCodePoint(iconCodePoint),
      category: category,
      subtaskTitles: subtaskTitles,
    );
  }

  static TemplateModel fromEntity(TaskTemplate template) {
    return TemplateModel()
      ..isarId = fastHash(template.id)
      ..templateId = template.id
      ..name = template.name
      ..iconCodePoint = template.icon.codePoint
      ..category = template.category
      ..subtaskTitles = template.subtaskTitles;
  }
}
