// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubTask _$SubTaskFromJson(Map<String, dynamic> json) => _SubTask(
  id: json['id'] as String,
  title: json['title'] as String,
  isCompleted: json['isCompleted'] as bool? ?? false,
);

Map<String, dynamic> _$SubTaskToJson(_SubTask instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'isCompleted': instance.isCompleted,
};

_Task _$TaskFromJson(Map<String, dynamic> json) => _Task(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String? ?? '',
  isCompleted: json['isCompleted'] as bool? ?? false,
  completionDate: json['completionDate'] == null
      ? null
      : DateTime.parse(json['completionDate'] as String),
  isStarred: json['isStarred'] as bool? ?? false,
  icon: json['icon'] == null
      ? Icons.task_alt
      : const IconDataConverter().fromJson(json['icon']),
  color: json['color'] == null
      ? Colors.blue
      : const ColorConverter().fromJson((json['color'] as num).toInt()),
  category: json['category'] as String? ?? 'Personal',
  attachmentCount: (json['attachmentCount'] as num?)?.toInt() ?? 0,
  subtasks:
      (json['subtasks'] as List<dynamic>?)
          ?.map((e) => SubTask.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
  recurrence: json['recurrence'] as String? ?? 'none',
  priority:
      $enumDecodeNullable(_$TaskPriorityEnumMap, json['priority']) ??
      TaskPriority.medium,
  isDeleted: json['isDeleted'] as bool? ?? false,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$TaskToJson(_Task instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'isCompleted': instance.isCompleted,
  'completionDate': instance.completionDate?.toIso8601String(),
  'isStarred': instance.isStarred,
  'icon': const IconDataConverter().toJson(instance.icon),
  'color': const ColorConverter().toJson(instance.color),
  'category': instance.category,
  'attachmentCount': instance.attachmentCount,
  'subtasks': instance.subtasks,
  'dueDate': instance.dueDate?.toIso8601String(),
  'orderIndex': instance.orderIndex,
  'recurrence': instance.recurrence,
  'priority': _$TaskPriorityEnumMap[instance.priority]!,
  'isDeleted': instance.isDeleted,
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$TaskPriorityEnumMap = {
  TaskPriority.low: 'low',
  TaskPriority.medium: 'medium',
  TaskPriority.high: 'high',
  TaskPriority.urgent: 'urgent',
};
