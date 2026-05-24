import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:flutter/material.dart';
import 'package:isar_plus/isar_plus.dart';

part 'task_model.g.dart';

@collection
class TaskModel {
  @id
  int isarId = 0;

  @Index(unique: true)
  late String taskId;

  late String title;
  late String description;
  late bool isCompleted;
  DateTime? completionDate;
  late bool isStarred;
  late int iconCodePoint;
  late int colorValue;
  late String category;
  late int attachmentCount;
  late List<SubTaskModel> subtasks;
  DateTime? dueDate;
  late int orderIndex;
  late String recurrence;
  
  late int priorityIndex;

  Task toEntity() {
    return Task(
      id: taskId,
      title: title,
      description: description,
      isCompleted: isCompleted,
      completionDate: completionDate,
      isStarred: isStarred,
      icon: IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
      color: Color(colorValue),
      category: category,
      attachmentCount: attachmentCount,
      subtasks: subtasks.map((s) => s.toEntity()).toList(),
      dueDate: dueDate,
      orderIndex: orderIndex,
      recurrence: recurrence,
      priority: TaskPriority.values[priorityIndex],
    );
  }

  static TaskModel fromEntity(Task task) {
    return TaskModel()
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
      ..priorityIndex = task.priority.index;
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
