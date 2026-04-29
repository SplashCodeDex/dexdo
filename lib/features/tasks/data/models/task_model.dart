import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/task.dart';

part 'task_model.g.dart';

@collection
class TaskModel {
  Id? isarId;

  @Index(unique: true, replace: true)
  late String id;

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

  Task toEntity() {
    return Task(
      id: id,
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
    );
  }

  static TaskModel fromEntity(Task task) {
    return TaskModel()
      ..id = task.id
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
      ..recurrence = task.recurrence;
  }
}

@collection
class CategoryModel {
  Id? isarId;

  @Index(unique: true, replace: true)
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
