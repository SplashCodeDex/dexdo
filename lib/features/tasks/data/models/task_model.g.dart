// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetTaskModelCollection on Isar {
  IsarCollection<int, TaskModel> get taskModels => this.collection();
}

final TaskModelSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'TaskModel',
    idName: 'isarId',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'taskId', type: IsarType.string),
      IsarPropertySchema(name: 'title', type: IsarType.string),
      IsarPropertySchema(name: 'description', type: IsarType.string),
      IsarPropertySchema(name: 'isCompleted', type: IsarType.bool),
      IsarPropertySchema(name: 'completionDate', type: IsarType.dateTime),
      IsarPropertySchema(name: 'isStarred', type: IsarType.bool),
      IsarPropertySchema(name: 'iconCodePoint', type: IsarType.long),
      IsarPropertySchema(name: 'colorValue', type: IsarType.long),
      IsarPropertySchema(name: 'category', type: IsarType.string),
      IsarPropertySchema(name: 'attachmentCount', type: IsarType.long),
      IsarPropertySchema(
        name: 'subtasks',
        type: IsarType.objectList,
        target: 'SubTaskModel',
      ),
      IsarPropertySchema(name: 'dueDate', type: IsarType.dateTime),
      IsarPropertySchema(name: 'orderIndex', type: IsarType.long),
      IsarPropertySchema(name: 'recurrence', type: IsarType.string),
      IsarPropertySchema(name: 'priorityIndex', type: IsarType.long),
      IsarPropertySchema(name: 'isDeleted', type: IsarType.bool),
      IsarPropertySchema(name: 'updatedAt', type: IsarType.dateTime),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'taskId',
        properties: ["taskId"],
        unique: true,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'isCompleted',
        properties: ["isCompleted"],
        unique: false,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'isStarred',
        properties: ["isStarred"],
        unique: false,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'category',
        properties: ["category"],
        unique: false,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'isDeleted',
        properties: ["isDeleted"],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, TaskModel>(
    serialize: serializeTaskModel,
    deserialize: deserializeTaskModel,
    deserializeProperty: deserializeTaskModelProp,
  ),
  getEmbeddedSchemas: () => [SubTaskModelSchema],
);

@isarProtected
int serializeTaskModel(IsarWriter writer, TaskModel object) {
  IsarCore.writeString(writer, 1, object.taskId);
  IsarCore.writeString(writer, 2, object.title);
  IsarCore.writeString(writer, 3, object.description);
  IsarCore.writeBool(writer, 4, value: object.isCompleted);
  IsarCore.writeLong(
    writer,
    5,
    object.completionDate?.toUtc().microsecondsSinceEpoch ??
        -9223372036854775808,
  );
  IsarCore.writeBool(writer, 6, value: object.isStarred);
  IsarCore.writeLong(writer, 7, object.iconCodePoint);
  IsarCore.writeLong(writer, 8, object.colorValue);
  IsarCore.writeString(writer, 9, object.category);
  IsarCore.writeLong(writer, 10, object.attachmentCount);
  {
    final list = object.subtasks;
    final listWriter = IsarCore.beginList(writer, 11, list.length);
    for (var i = 0; i < list.length; i++) {
      {
        final value = list[i];
        final objectWriter = IsarCore.beginObject(listWriter, i);
        serializeSubTaskModel(objectWriter, value);
        IsarCore.endObject(listWriter, objectWriter);
      }
    }
    IsarCore.endList(writer, listWriter);
  }
  IsarCore.writeLong(
    writer,
    12,
    object.dueDate?.toUtc().microsecondsSinceEpoch ?? -9223372036854775808,
  );
  IsarCore.writeLong(writer, 13, object.orderIndex);
  IsarCore.writeString(writer, 14, object.recurrence);
  IsarCore.writeLong(writer, 15, object.priorityIndex);
  IsarCore.writeBool(writer, 16, value: object.isDeleted);
  IsarCore.writeLong(
    writer,
    17,
    object.updatedAt?.toUtc().microsecondsSinceEpoch ?? -9223372036854775808,
  );
  return object.isarId;
}

@isarProtected
TaskModel deserializeTaskModel(IsarReader reader) {
  final object = TaskModel();
  object.isarId = IsarCore.readId(reader);
  object.taskId = IsarCore.readString(reader, 1) ?? '';
  object.title = IsarCore.readString(reader, 2) ?? '';
  object.description = IsarCore.readString(reader, 3) ?? '';
  object.isCompleted = IsarCore.readBool(reader, 4);
  {
    final value = IsarCore.readLong(reader, 5);
    if (value == -9223372036854775808) {
      object.completionDate = null;
    } else {
      object.completionDate = DateTime.fromMicrosecondsSinceEpoch(
        value,
        isUtc: true,
      ).toLocal();
    }
  }
  object.isStarred = IsarCore.readBool(reader, 6);
  object.iconCodePoint = IsarCore.readLong(reader, 7);
  object.colorValue = IsarCore.readLong(reader, 8);
  object.category = IsarCore.readString(reader, 9) ?? '';
  object.attachmentCount = IsarCore.readLong(reader, 10);
  {
    final length = IsarCore.readList(reader, 11, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        object.subtasks = const <SubTaskModel>[];
      } else {
        final list = List<SubTaskModel>.filled(
          length,
          SubTaskModel(),
          growable: true,
        );
        for (var i = 0; i < length; i++) {
          {
            final objectReader = IsarCore.readObject(reader, i);
            if (objectReader.isNull) {
              list[i] = SubTaskModel();
            } else {
              final embedded = deserializeSubTaskModel(objectReader);
              IsarCore.freeReader(objectReader);
              list[i] = embedded;
            }
          }
        }
        IsarCore.freeReader(reader);
        object.subtasks = list;
      }
    }
  }
  {
    final value = IsarCore.readLong(reader, 12);
    if (value == -9223372036854775808) {
      object.dueDate = null;
    } else {
      object.dueDate = DateTime.fromMicrosecondsSinceEpoch(
        value,
        isUtc: true,
      ).toLocal();
    }
  }
  object.orderIndex = IsarCore.readLong(reader, 13);
  object.recurrence = IsarCore.readString(reader, 14) ?? '';
  object.priorityIndex = IsarCore.readLong(reader, 15);
  object.isDeleted = IsarCore.readBool(reader, 16);
  {
    final value = IsarCore.readLong(reader, 17);
    if (value == -9223372036854775808) {
      object.updatedAt = null;
    } else {
      object.updatedAt = DateTime.fromMicrosecondsSinceEpoch(
        value,
        isUtc: true,
      ).toLocal();
    }
  }
  return object;
}

@isarProtected
dynamic deserializeTaskModelProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readString(reader, 3) ?? '';
    case 4:
      return IsarCore.readBool(reader, 4);
    case 5:
      {
        final value = IsarCore.readLong(reader, 5);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(
            value,
            isUtc: true,
          ).toLocal();
        }
      }
    case 6:
      return IsarCore.readBool(reader, 6);
    case 7:
      return IsarCore.readLong(reader, 7);
    case 8:
      return IsarCore.readLong(reader, 8);
    case 9:
      return IsarCore.readString(reader, 9) ?? '';
    case 10:
      return IsarCore.readLong(reader, 10);
    case 11:
      {
        final length = IsarCore.readList(reader, 11, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return const <SubTaskModel>[];
          } else {
            final list = List<SubTaskModel>.filled(
              length,
              SubTaskModel(),
              growable: true,
            );
            for (var i = 0; i < length; i++) {
              {
                final objectReader = IsarCore.readObject(reader, i);
                if (objectReader.isNull) {
                  list[i] = SubTaskModel();
                } else {
                  final embedded = deserializeSubTaskModel(objectReader);
                  IsarCore.freeReader(objectReader);
                  list[i] = embedded;
                }
              }
            }
            IsarCore.freeReader(reader);
            return list;
          }
        }
      }
    case 12:
      {
        final value = IsarCore.readLong(reader, 12);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(
            value,
            isUtc: true,
          ).toLocal();
        }
      }
    case 13:
      return IsarCore.readLong(reader, 13);
    case 14:
      return IsarCore.readString(reader, 14) ?? '';
    case 15:
      return IsarCore.readLong(reader, 15);
    case 16:
      return IsarCore.readBool(reader, 16);
    case 17:
      {
        final value = IsarCore.readLong(reader, 17);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(
            value,
            isUtc: true,
          ).toLocal();
        }
      }
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _TaskModelUpdate {
  bool call({
    required int isarId,
    String? taskId,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? completionDate,
    bool? isStarred,
    int? iconCodePoint,
    int? colorValue,
    String? category,
    int? attachmentCount,
    DateTime? dueDate,
    int? orderIndex,
    String? recurrence,
    int? priorityIndex,
    bool? isDeleted,
    DateTime? updatedAt,
  });
}

class _TaskModelUpdateImpl implements _TaskModelUpdate {
  const _TaskModelUpdateImpl(this.collection);

  final IsarCollection<int, TaskModel> collection;

  @override
  bool call({
    required int isarId,
    Object? taskId = ignore,
    Object? title = ignore,
    Object? description = ignore,
    Object? isCompleted = ignore,
    Object? completionDate = ignore,
    Object? isStarred = ignore,
    Object? iconCodePoint = ignore,
    Object? colorValue = ignore,
    Object? category = ignore,
    Object? attachmentCount = ignore,
    Object? dueDate = ignore,
    Object? orderIndex = ignore,
    Object? recurrence = ignore,
    Object? priorityIndex = ignore,
    Object? isDeleted = ignore,
    Object? updatedAt = ignore,
  }) {
    return collection.updateProperties(
          [isarId],
          {
            if (taskId != ignore) 1: taskId as String?,
            if (title != ignore) 2: title as String?,
            if (description != ignore) 3: description as String?,
            if (isCompleted != ignore) 4: isCompleted as bool?,
            if (completionDate != ignore) 5: completionDate as DateTime?,
            if (isStarred != ignore) 6: isStarred as bool?,
            if (iconCodePoint != ignore) 7: iconCodePoint as int?,
            if (colorValue != ignore) 8: colorValue as int?,
            if (category != ignore) 9: category as String?,
            if (attachmentCount != ignore) 10: attachmentCount as int?,
            if (dueDate != ignore) 12: dueDate as DateTime?,
            if (orderIndex != ignore) 13: orderIndex as int?,
            if (recurrence != ignore) 14: recurrence as String?,
            if (priorityIndex != ignore) 15: priorityIndex as int?,
            if (isDeleted != ignore) 16: isDeleted as bool?,
            if (updatedAt != ignore) 17: updatedAt as DateTime?,
          },
        ) >
        0;
  }
}

sealed class _TaskModelUpdateAll {
  int call({
    required List<int> isarId,
    String? taskId,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? completionDate,
    bool? isStarred,
    int? iconCodePoint,
    int? colorValue,
    String? category,
    int? attachmentCount,
    DateTime? dueDate,
    int? orderIndex,
    String? recurrence,
    int? priorityIndex,
    bool? isDeleted,
    DateTime? updatedAt,
  });
}

class _TaskModelUpdateAllImpl implements _TaskModelUpdateAll {
  const _TaskModelUpdateAllImpl(this.collection);

  final IsarCollection<int, TaskModel> collection;

  @override
  int call({
    required List<int> isarId,
    Object? taskId = ignore,
    Object? title = ignore,
    Object? description = ignore,
    Object? isCompleted = ignore,
    Object? completionDate = ignore,
    Object? isStarred = ignore,
    Object? iconCodePoint = ignore,
    Object? colorValue = ignore,
    Object? category = ignore,
    Object? attachmentCount = ignore,
    Object? dueDate = ignore,
    Object? orderIndex = ignore,
    Object? recurrence = ignore,
    Object? priorityIndex = ignore,
    Object? isDeleted = ignore,
    Object? updatedAt = ignore,
  }) {
    return collection.updateProperties(isarId, {
      if (taskId != ignore) 1: taskId as String?,
      if (title != ignore) 2: title as String?,
      if (description != ignore) 3: description as String?,
      if (isCompleted != ignore) 4: isCompleted as bool?,
      if (completionDate != ignore) 5: completionDate as DateTime?,
      if (isStarred != ignore) 6: isStarred as bool?,
      if (iconCodePoint != ignore) 7: iconCodePoint as int?,
      if (colorValue != ignore) 8: colorValue as int?,
      if (category != ignore) 9: category as String?,
      if (attachmentCount != ignore) 10: attachmentCount as int?,
      if (dueDate != ignore) 12: dueDate as DateTime?,
      if (orderIndex != ignore) 13: orderIndex as int?,
      if (recurrence != ignore) 14: recurrence as String?,
      if (priorityIndex != ignore) 15: priorityIndex as int?,
      if (isDeleted != ignore) 16: isDeleted as bool?,
      if (updatedAt != ignore) 17: updatedAt as DateTime?,
    });
  }
}

extension TaskModelUpdate on IsarCollection<int, TaskModel> {
  _TaskModelUpdate get update => _TaskModelUpdateImpl(this);

  _TaskModelUpdateAll get updateAll => _TaskModelUpdateAllImpl(this);
}

sealed class _TaskModelQueryUpdate {
  int call({
    String? taskId,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? completionDate,
    bool? isStarred,
    int? iconCodePoint,
    int? colorValue,
    String? category,
    int? attachmentCount,
    DateTime? dueDate,
    int? orderIndex,
    String? recurrence,
    int? priorityIndex,
    bool? isDeleted,
    DateTime? updatedAt,
  });
}

class _TaskModelQueryUpdateImpl implements _TaskModelQueryUpdate {
  const _TaskModelQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<TaskModel> query;
  final int? limit;

  @override
  int call({
    Object? taskId = ignore,
    Object? title = ignore,
    Object? description = ignore,
    Object? isCompleted = ignore,
    Object? completionDate = ignore,
    Object? isStarred = ignore,
    Object? iconCodePoint = ignore,
    Object? colorValue = ignore,
    Object? category = ignore,
    Object? attachmentCount = ignore,
    Object? dueDate = ignore,
    Object? orderIndex = ignore,
    Object? recurrence = ignore,
    Object? priorityIndex = ignore,
    Object? isDeleted = ignore,
    Object? updatedAt = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (taskId != ignore) 1: taskId as String?,
      if (title != ignore) 2: title as String?,
      if (description != ignore) 3: description as String?,
      if (isCompleted != ignore) 4: isCompleted as bool?,
      if (completionDate != ignore) 5: completionDate as DateTime?,
      if (isStarred != ignore) 6: isStarred as bool?,
      if (iconCodePoint != ignore) 7: iconCodePoint as int?,
      if (colorValue != ignore) 8: colorValue as int?,
      if (category != ignore) 9: category as String?,
      if (attachmentCount != ignore) 10: attachmentCount as int?,
      if (dueDate != ignore) 12: dueDate as DateTime?,
      if (orderIndex != ignore) 13: orderIndex as int?,
      if (recurrence != ignore) 14: recurrence as String?,
      if (priorityIndex != ignore) 15: priorityIndex as int?,
      if (isDeleted != ignore) 16: isDeleted as bool?,
      if (updatedAt != ignore) 17: updatedAt as DateTime?,
    });
  }
}

extension TaskModelQueryUpdate on IsarQuery<TaskModel> {
  _TaskModelQueryUpdate get updateFirst =>
      _TaskModelQueryUpdateImpl(this, limit: 1);

  _TaskModelQueryUpdate get updateAll => _TaskModelQueryUpdateImpl(this);
}

class _TaskModelQueryBuilderUpdateImpl implements _TaskModelQueryUpdate {
  const _TaskModelQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<TaskModel, TaskModel, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? taskId = ignore,
    Object? title = ignore,
    Object? description = ignore,
    Object? isCompleted = ignore,
    Object? completionDate = ignore,
    Object? isStarred = ignore,
    Object? iconCodePoint = ignore,
    Object? colorValue = ignore,
    Object? category = ignore,
    Object? attachmentCount = ignore,
    Object? dueDate = ignore,
    Object? orderIndex = ignore,
    Object? recurrence = ignore,
    Object? priorityIndex = ignore,
    Object? isDeleted = ignore,
    Object? updatedAt = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (taskId != ignore) 1: taskId as String?,
        if (title != ignore) 2: title as String?,
        if (description != ignore) 3: description as String?,
        if (isCompleted != ignore) 4: isCompleted as bool?,
        if (completionDate != ignore) 5: completionDate as DateTime?,
        if (isStarred != ignore) 6: isStarred as bool?,
        if (iconCodePoint != ignore) 7: iconCodePoint as int?,
        if (colorValue != ignore) 8: colorValue as int?,
        if (category != ignore) 9: category as String?,
        if (attachmentCount != ignore) 10: attachmentCount as int?,
        if (dueDate != ignore) 12: dueDate as DateTime?,
        if (orderIndex != ignore) 13: orderIndex as int?,
        if (recurrence != ignore) 14: recurrence as String?,
        if (priorityIndex != ignore) 15: priorityIndex as int?,
        if (isDeleted != ignore) 16: isDeleted as bool?,
        if (updatedAt != ignore) 17: updatedAt as DateTime?,
      });
    } finally {
      q.close();
    }
  }
}

extension TaskModelQueryBuilderUpdate
    on QueryBuilder<TaskModel, TaskModel, QOperations> {
  _TaskModelQueryUpdate get updateFirst =>
      _TaskModelQueryBuilderUpdateImpl(this, limit: 1);

  _TaskModelQueryUpdate get updateAll => _TaskModelQueryBuilderUpdateImpl(this);
}

extension TaskModelQueryFilter
    on QueryBuilder<TaskModel, TaskModel, QFilterCondition> {
  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> isarIdEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> isarIdGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  isarIdGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> isarIdLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 0, value: value));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  isarIdLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> isarIdBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 0, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> taskIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> taskIdGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  taskIdGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> taskIdLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  taskIdLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> taskIdBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> taskIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> taskIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> taskIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> taskIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> taskIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> taskIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  titleGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> titleLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  titleLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> titleContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> titleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 3, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  descriptionGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  descriptionGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> descriptionLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 3, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  descriptionLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> descriptionBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  descriptionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> descriptionContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> descriptionMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 3,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 3, value: ''),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 3, value: ''),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> isCompletedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  completionDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  completionDateIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  completionDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  completionDateGreaterThan(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  completionDateGreaterThanOrEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  completionDateLessThan(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 5, value: value));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  completionDateLessThanOrEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  completionDateBetween(DateTime? lower, DateTime? upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 5, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> isStarredEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  iconCodePointEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 7, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  iconCodePointGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 7, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  iconCodePointGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 7, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  iconCodePointLessThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 7, value: value));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  iconCodePointLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 7, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  iconCodePointBetween(int lower, int upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 7, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> colorValueEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 8, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  colorValueGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 8, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  colorValueGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 8, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> colorValueLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 8, value: value));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  colorValueLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 8, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> colorValueBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 8, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> categoryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 9, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> categoryGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  categoryGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> categoryLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 9, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  categoryLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> categoryBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 9,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> categoryContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> categoryMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 9,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 9, value: ''),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 9, value: ''),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  attachmentCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 10, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  attachmentCountGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 10, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  attachmentCountGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 10, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  attachmentCountLessThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 10, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  attachmentCountLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 10, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  attachmentCountBetween(int lower, int upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 10, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> subtasksIsEmpty() {
    return not().subtasksIsNotEmpty();
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  subtasksIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 11, value: null),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> dueDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 12));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> dueDateIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 12));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> dueDateEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 12, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> dueDateGreaterThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 12, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  dueDateGreaterThanOrEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 12, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> dueDateLessThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 12, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  dueDateLessThanOrEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 12, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> dueDateBetween(
    DateTime? lower,
    DateTime? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 12, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> orderIndexEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 13, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  orderIndexGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 13, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  orderIndexGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 13, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> orderIndexLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 13, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  orderIndexLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 13, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> orderIndexBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 13, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> recurrenceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 14,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  recurrenceGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 14,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  recurrenceGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 14,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> recurrenceLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 14, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  recurrenceLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 14,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> recurrenceBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 14,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  recurrenceStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 14,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> recurrenceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 14,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> recurrenceContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 14,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> recurrenceMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 14,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  recurrenceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 14, value: ''),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  recurrenceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 14, value: ''),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  priorityIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 15, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  priorityIndexGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 15, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  priorityIndexGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 15, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  priorityIndexLessThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 15, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  priorityIndexLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 15, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  priorityIndexBetween(int lower, int upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 15, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> isDeletedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 16, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 17));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  updatedAtIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 17));
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> updatedAtEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 17, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 17, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  updatedAtGreaterThanOrEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 17, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> updatedAtLessThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 17, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition>
  updatedAtLessThanOrEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 17, value: value),
      );
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterFilterCondition> updatedAtBetween(
    DateTime? lower,
    DateTime? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 17, lower: lower, upper: upper),
      );
    });
  }
}

extension TaskModelQueryObject
    on QueryBuilder<TaskModel, TaskModel, QFilterCondition> {}

extension TaskModelQuerySortBy on QueryBuilder<TaskModel, TaskModel, QSortBy> {
  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByTaskId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByTaskIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByTitleDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByDescription({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByDescriptionDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByCompletionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByCompletionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIsStarred() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIsStarredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIconCodePoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIconCodePointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByCategory({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByCategoryDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByAttachmentCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByAttachmentCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, sort: Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByOrderIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByOrderIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByRecurrence({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByRecurrenceDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByPriorityIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByPriorityIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15, sort: Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16, sort: Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(17);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(17, sort: Sort.desc);
    });
  }
}

extension TaskModelQuerySortThenBy
    on QueryBuilder<TaskModel, TaskModel, QSortThenBy> {
  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByTaskId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByTaskIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByTitleDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByDescription({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByDescriptionDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByCompletionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByCompletionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIsStarred() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIsStarredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIconCodePoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIconCodePointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByCategory({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByCategoryDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByAttachmentCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByAttachmentCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, sort: Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByOrderIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByOrderIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByRecurrence({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByRecurrenceDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByPriorityIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByPriorityIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15, sort: Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByIsDeletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(16, sort: Sort.desc);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(17);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(17, sort: Sort.desc);
    });
  }
}

extension TaskModelQueryWhereDistinct
    on QueryBuilder<TaskModel, TaskModel, QDistinct> {
  QueryBuilder<TaskModel, TaskModel, QAfterDistinct> distinctByTaskId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterDistinct> distinctByDescription({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterDistinct> distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterDistinct>
  distinctByCompletionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterDistinct> distinctByIsStarred() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterDistinct> distinctByIconCodePoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterDistinct> distinctByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterDistinct> distinctByCategory({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterDistinct>
  distinctByAttachmentCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterDistinct> distinctByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(12);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterDistinct> distinctByOrderIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(13);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterDistinct> distinctByRecurrence({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(14, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterDistinct> distinctByPriorityIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(15);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterDistinct> distinctByIsDeleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(16);
    });
  }

  QueryBuilder<TaskModel, TaskModel, QAfterDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(17);
    });
  }
}

extension TaskModelQueryProperty1
    on QueryBuilder<TaskModel, TaskModel, QProperty> {
  QueryBuilder<TaskModel, int, QAfterProperty> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<TaskModel, String, QAfterProperty> taskIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<TaskModel, String, QAfterProperty> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<TaskModel, String, QAfterProperty> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<TaskModel, bool, QAfterProperty> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<TaskModel, DateTime?, QAfterProperty> completionDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<TaskModel, bool, QAfterProperty> isStarredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<TaskModel, int, QAfterProperty> iconCodePointProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<TaskModel, int, QAfterProperty> colorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<TaskModel, String, QAfterProperty> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<TaskModel, int, QAfterProperty> attachmentCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<TaskModel, List<SubTaskModel>, QAfterProperty>
  subtasksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<TaskModel, DateTime?, QAfterProperty> dueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<TaskModel, int, QAfterProperty> orderIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<TaskModel, String, QAfterProperty> recurrenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<TaskModel, int, QAfterProperty> priorityIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }

  QueryBuilder<TaskModel, bool, QAfterProperty> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(16);
    });
  }

  QueryBuilder<TaskModel, DateTime?, QAfterProperty> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(17);
    });
  }
}

extension TaskModelQueryProperty2<R>
    on QueryBuilder<TaskModel, R, QAfterProperty> {
  QueryBuilder<TaskModel, (R, int), QAfterProperty> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<TaskModel, (R, String), QAfterProperty> taskIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<TaskModel, (R, String), QAfterProperty> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<TaskModel, (R, String), QAfterProperty> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<TaskModel, (R, bool), QAfterProperty> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<TaskModel, (R, DateTime?), QAfterProperty>
  completionDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<TaskModel, (R, bool), QAfterProperty> isStarredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<TaskModel, (R, int), QAfterProperty> iconCodePointProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<TaskModel, (R, int), QAfterProperty> colorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<TaskModel, (R, String), QAfterProperty> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<TaskModel, (R, int), QAfterProperty> attachmentCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<TaskModel, (R, List<SubTaskModel>), QAfterProperty>
  subtasksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<TaskModel, (R, DateTime?), QAfterProperty> dueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<TaskModel, (R, int), QAfterProperty> orderIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<TaskModel, (R, String), QAfterProperty> recurrenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<TaskModel, (R, int), QAfterProperty> priorityIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }

  QueryBuilder<TaskModel, (R, bool), QAfterProperty> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(16);
    });
  }

  QueryBuilder<TaskModel, (R, DateTime?), QAfterProperty> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(17);
    });
  }
}

extension TaskModelQueryProperty3<R1, R2>
    on QueryBuilder<TaskModel, (R1, R2), QAfterProperty> {
  QueryBuilder<TaskModel, (R1, R2, int), QOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<TaskModel, (R1, R2, String), QOperations> taskIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<TaskModel, (R1, R2, String), QOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<TaskModel, (R1, R2, String), QOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<TaskModel, (R1, R2, bool), QOperations> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<TaskModel, (R1, R2, DateTime?), QOperations>
  completionDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<TaskModel, (R1, R2, bool), QOperations> isStarredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<TaskModel, (R1, R2, int), QOperations> iconCodePointProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<TaskModel, (R1, R2, int), QOperations> colorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<TaskModel, (R1, R2, String), QOperations> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<TaskModel, (R1, R2, int), QOperations>
  attachmentCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<TaskModel, (R1, R2, List<SubTaskModel>), QOperations>
  subtasksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<TaskModel, (R1, R2, DateTime?), QOperations> dueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<TaskModel, (R1, R2, int), QOperations> orderIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<TaskModel, (R1, R2, String), QOperations> recurrenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<TaskModel, (R1, R2, int), QOperations> priorityIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }

  QueryBuilder<TaskModel, (R1, R2, bool), QOperations> isDeletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(16);
    });
  }

  QueryBuilder<TaskModel, (R1, R2, DateTime?), QOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(17);
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetCategoryModelCollection on Isar {
  IsarCollection<int, CategoryModel> get categoryModels => this.collection();
}

final CategoryModelSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'CategoryModel',
    idName: 'isarId',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'name', type: IsarType.string),
      IsarPropertySchema(name: 'iconCodePoint', type: IsarType.long),
      IsarPropertySchema(name: 'colorValue', type: IsarType.long),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'name',
        properties: ["name"],
        unique: true,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, CategoryModel>(
    serialize: serializeCategoryModel,
    deserialize: deserializeCategoryModel,
    deserializeProperty: deserializeCategoryModelProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeCategoryModel(IsarWriter writer, CategoryModel object) {
  IsarCore.writeString(writer, 1, object.name);
  IsarCore.writeLong(writer, 2, object.iconCodePoint);
  IsarCore.writeLong(writer, 3, object.colorValue);
  return object.isarId;
}

@isarProtected
CategoryModel deserializeCategoryModel(IsarReader reader) {
  final object = CategoryModel();
  object.isarId = IsarCore.readId(reader);
  object.name = IsarCore.readString(reader, 1) ?? '';
  object.iconCodePoint = IsarCore.readLong(reader, 2);
  object.colorValue = IsarCore.readLong(reader, 3);
  return object;
}

@isarProtected
dynamic deserializeCategoryModelProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readLong(reader, 2);
    case 3:
      return IsarCore.readLong(reader, 3);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _CategoryModelUpdate {
  bool call({
    required int isarId,
    String? name,
    int? iconCodePoint,
    int? colorValue,
  });
}

class _CategoryModelUpdateImpl implements _CategoryModelUpdate {
  const _CategoryModelUpdateImpl(this.collection);

  final IsarCollection<int, CategoryModel> collection;

  @override
  bool call({
    required int isarId,
    Object? name = ignore,
    Object? iconCodePoint = ignore,
    Object? colorValue = ignore,
  }) {
    return collection.updateProperties(
          [isarId],
          {
            if (name != ignore) 1: name as String?,
            if (iconCodePoint != ignore) 2: iconCodePoint as int?,
            if (colorValue != ignore) 3: colorValue as int?,
          },
        ) >
        0;
  }
}

sealed class _CategoryModelUpdateAll {
  int call({
    required List<int> isarId,
    String? name,
    int? iconCodePoint,
    int? colorValue,
  });
}

class _CategoryModelUpdateAllImpl implements _CategoryModelUpdateAll {
  const _CategoryModelUpdateAllImpl(this.collection);

  final IsarCollection<int, CategoryModel> collection;

  @override
  int call({
    required List<int> isarId,
    Object? name = ignore,
    Object? iconCodePoint = ignore,
    Object? colorValue = ignore,
  }) {
    return collection.updateProperties(isarId, {
      if (name != ignore) 1: name as String?,
      if (iconCodePoint != ignore) 2: iconCodePoint as int?,
      if (colorValue != ignore) 3: colorValue as int?,
    });
  }
}

extension CategoryModelUpdate on IsarCollection<int, CategoryModel> {
  _CategoryModelUpdate get update => _CategoryModelUpdateImpl(this);

  _CategoryModelUpdateAll get updateAll => _CategoryModelUpdateAllImpl(this);
}

sealed class _CategoryModelQueryUpdate {
  int call({String? name, int? iconCodePoint, int? colorValue});
}

class _CategoryModelQueryUpdateImpl implements _CategoryModelQueryUpdate {
  const _CategoryModelQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<CategoryModel> query;
  final int? limit;

  @override
  int call({
    Object? name = ignore,
    Object? iconCodePoint = ignore,
    Object? colorValue = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (name != ignore) 1: name as String?,
      if (iconCodePoint != ignore) 2: iconCodePoint as int?,
      if (colorValue != ignore) 3: colorValue as int?,
    });
  }
}

extension CategoryModelQueryUpdate on IsarQuery<CategoryModel> {
  _CategoryModelQueryUpdate get updateFirst =>
      _CategoryModelQueryUpdateImpl(this, limit: 1);

  _CategoryModelQueryUpdate get updateAll =>
      _CategoryModelQueryUpdateImpl(this);
}

class _CategoryModelQueryBuilderUpdateImpl
    implements _CategoryModelQueryUpdate {
  const _CategoryModelQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<CategoryModel, CategoryModel, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? name = ignore,
    Object? iconCodePoint = ignore,
    Object? colorValue = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (name != ignore) 1: name as String?,
        if (iconCodePoint != ignore) 2: iconCodePoint as int?,
        if (colorValue != ignore) 3: colorValue as int?,
      });
    } finally {
      q.close();
    }
  }
}

extension CategoryModelQueryBuilderUpdate
    on QueryBuilder<CategoryModel, CategoryModel, QOperations> {
  _CategoryModelQueryUpdate get updateFirst =>
      _CategoryModelQueryBuilderUpdateImpl(this, limit: 1);

  _CategoryModelQueryUpdate get updateAll =>
      _CategoryModelQueryBuilderUpdateImpl(this);
}

extension CategoryModelQueryFilter
    on QueryBuilder<CategoryModel, CategoryModel, QFilterCondition> {
  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  isarIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  isarIdGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  isarIdGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  isarIdLessThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 0, value: value));
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  isarIdLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  isarIdBetween(int lower, int upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 0, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  nameGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  nameGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  nameLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  nameLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  nameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  iconCodePointEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  iconCodePointGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 2, value: value),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  iconCodePointGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 2, value: value),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  iconCodePointLessThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 2, value: value));
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  iconCodePointLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 2, value: value),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  iconCodePointBetween(int lower, int upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 2, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  colorValueEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  colorValueGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  colorValueGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  colorValueLessThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 3, value: value));
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  colorValueLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterFilterCondition>
  colorValueBetween(int lower, int upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 3, lower: lower, upper: upper),
      );
    });
  }
}

extension CategoryModelQueryObject
    on QueryBuilder<CategoryModel, CategoryModel, QFilterCondition> {}

extension CategoryModelQuerySortBy
    on QueryBuilder<CategoryModel, CategoryModel, QSortBy> {
  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy> sortByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy> sortByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy> sortByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy> sortByNameDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy>
  sortByIconCodePoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy>
  sortByIconCodePointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy> sortByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy>
  sortByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }
}

extension CategoryModelQuerySortThenBy
    on QueryBuilder<CategoryModel, CategoryModel, QSortThenBy> {
  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy> thenByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy> thenByNameDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy>
  thenByIconCodePoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy>
  thenByIconCodePointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy> thenByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterSortBy>
  thenByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }
}

extension CategoryModelQueryWhereDistinct
    on QueryBuilder<CategoryModel, CategoryModel, QDistinct> {
  QueryBuilder<CategoryModel, CategoryModel, QAfterDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterDistinct>
  distinctByIconCodePoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }

  QueryBuilder<CategoryModel, CategoryModel, QAfterDistinct>
  distinctByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }
}

extension CategoryModelQueryProperty1
    on QueryBuilder<CategoryModel, CategoryModel, QProperty> {
  QueryBuilder<CategoryModel, int, QAfterProperty> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<CategoryModel, String, QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<CategoryModel, int, QAfterProperty> iconCodePointProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<CategoryModel, int, QAfterProperty> colorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }
}

extension CategoryModelQueryProperty2<R>
    on QueryBuilder<CategoryModel, R, QAfterProperty> {
  QueryBuilder<CategoryModel, (R, int), QAfterProperty> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<CategoryModel, (R, String), QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<CategoryModel, (R, int), QAfterProperty>
  iconCodePointProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<CategoryModel, (R, int), QAfterProperty> colorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }
}

extension CategoryModelQueryProperty3<R1, R2>
    on QueryBuilder<CategoryModel, (R1, R2), QAfterProperty> {
  QueryBuilder<CategoryModel, (R1, R2, int), QOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<CategoryModel, (R1, R2, String), QOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<CategoryModel, (R1, R2, int), QOperations>
  iconCodePointProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<CategoryModel, (R1, R2, int), QOperations> colorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetTemplateModelCollection on Isar {
  IsarCollection<int, TemplateModel> get templateModels => this.collection();
}

final TemplateModelSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'TemplateModel',
    idName: 'isarId',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'templateId', type: IsarType.string),
      IsarPropertySchema(name: 'name', type: IsarType.string),
      IsarPropertySchema(name: 'iconCodePoint', type: IsarType.long),
      IsarPropertySchema(name: 'subtaskTitles', type: IsarType.stringList),
      IsarPropertySchema(name: 'category', type: IsarType.string),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'templateId',
        properties: ["templateId"],
        unique: true,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, TemplateModel>(
    serialize: serializeTemplateModel,
    deserialize: deserializeTemplateModel,
    deserializeProperty: deserializeTemplateModelProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeTemplateModel(IsarWriter writer, TemplateModel object) {
  IsarCore.writeString(writer, 1, object.templateId);
  IsarCore.writeString(writer, 2, object.name);
  IsarCore.writeLong(writer, 3, object.iconCodePoint);
  {
    final list = object.subtaskTitles;
    final listWriter = IsarCore.beginList(writer, 4, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeString(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  IsarCore.writeString(writer, 5, object.category);
  return object.isarId;
}

@isarProtected
TemplateModel deserializeTemplateModel(IsarReader reader) {
  final object = TemplateModel();
  object.isarId = IsarCore.readId(reader);
  object.templateId = IsarCore.readString(reader, 1) ?? '';
  object.name = IsarCore.readString(reader, 2) ?? '';
  object.iconCodePoint = IsarCore.readLong(reader, 3);
  {
    final length = IsarCore.readList(reader, 4, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        object.subtaskTitles = const <String>[];
      } else {
        final list = List<String>.filled(length, '', growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readString(reader, i) ?? '';
        }
        IsarCore.freeReader(reader);
        object.subtaskTitles = list;
      }
    }
  }
  object.category = IsarCore.readString(reader, 5) ?? '';
  return object;
}

@isarProtected
dynamic deserializeTemplateModelProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readLong(reader, 3);
    case 4:
      {
        final length = IsarCore.readList(reader, 4, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return const <String>[];
          } else {
            final list = List<String>.filled(length, '', growable: true);
            for (var i = 0; i < length; i++) {
              list[i] = IsarCore.readString(reader, i) ?? '';
            }
            IsarCore.freeReader(reader);
            return list;
          }
        }
      }
    case 5:
      return IsarCore.readString(reader, 5) ?? '';
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _TemplateModelUpdate {
  bool call({
    required int isarId,
    String? templateId,
    String? name,
    int? iconCodePoint,
    String? category,
  });
}

class _TemplateModelUpdateImpl implements _TemplateModelUpdate {
  const _TemplateModelUpdateImpl(this.collection);

  final IsarCollection<int, TemplateModel> collection;

  @override
  bool call({
    required int isarId,
    Object? templateId = ignore,
    Object? name = ignore,
    Object? iconCodePoint = ignore,
    Object? category = ignore,
  }) {
    return collection.updateProperties(
          [isarId],
          {
            if (templateId != ignore) 1: templateId as String?,
            if (name != ignore) 2: name as String?,
            if (iconCodePoint != ignore) 3: iconCodePoint as int?,
            if (category != ignore) 5: category as String?,
          },
        ) >
        0;
  }
}

sealed class _TemplateModelUpdateAll {
  int call({
    required List<int> isarId,
    String? templateId,
    String? name,
    int? iconCodePoint,
    String? category,
  });
}

class _TemplateModelUpdateAllImpl implements _TemplateModelUpdateAll {
  const _TemplateModelUpdateAllImpl(this.collection);

  final IsarCollection<int, TemplateModel> collection;

  @override
  int call({
    required List<int> isarId,
    Object? templateId = ignore,
    Object? name = ignore,
    Object? iconCodePoint = ignore,
    Object? category = ignore,
  }) {
    return collection.updateProperties(isarId, {
      if (templateId != ignore) 1: templateId as String?,
      if (name != ignore) 2: name as String?,
      if (iconCodePoint != ignore) 3: iconCodePoint as int?,
      if (category != ignore) 5: category as String?,
    });
  }
}

extension TemplateModelUpdate on IsarCollection<int, TemplateModel> {
  _TemplateModelUpdate get update => _TemplateModelUpdateImpl(this);

  _TemplateModelUpdateAll get updateAll => _TemplateModelUpdateAllImpl(this);
}

sealed class _TemplateModelQueryUpdate {
  int call({
    String? templateId,
    String? name,
    int? iconCodePoint,
    String? category,
  });
}

class _TemplateModelQueryUpdateImpl implements _TemplateModelQueryUpdate {
  const _TemplateModelQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<TemplateModel> query;
  final int? limit;

  @override
  int call({
    Object? templateId = ignore,
    Object? name = ignore,
    Object? iconCodePoint = ignore,
    Object? category = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (templateId != ignore) 1: templateId as String?,
      if (name != ignore) 2: name as String?,
      if (iconCodePoint != ignore) 3: iconCodePoint as int?,
      if (category != ignore) 5: category as String?,
    });
  }
}

extension TemplateModelQueryUpdate on IsarQuery<TemplateModel> {
  _TemplateModelQueryUpdate get updateFirst =>
      _TemplateModelQueryUpdateImpl(this, limit: 1);

  _TemplateModelQueryUpdate get updateAll =>
      _TemplateModelQueryUpdateImpl(this);
}

class _TemplateModelQueryBuilderUpdateImpl
    implements _TemplateModelQueryUpdate {
  const _TemplateModelQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<TemplateModel, TemplateModel, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? templateId = ignore,
    Object? name = ignore,
    Object? iconCodePoint = ignore,
    Object? category = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (templateId != ignore) 1: templateId as String?,
        if (name != ignore) 2: name as String?,
        if (iconCodePoint != ignore) 3: iconCodePoint as int?,
        if (category != ignore) 5: category as String?,
      });
    } finally {
      q.close();
    }
  }
}

extension TemplateModelQueryBuilderUpdate
    on QueryBuilder<TemplateModel, TemplateModel, QOperations> {
  _TemplateModelQueryUpdate get updateFirst =>
      _TemplateModelQueryBuilderUpdateImpl(this, limit: 1);

  _TemplateModelQueryUpdate get updateAll =>
      _TemplateModelQueryBuilderUpdateImpl(this);
}

extension TemplateModelQueryFilter
    on QueryBuilder<TemplateModel, TemplateModel, QFilterCondition> {
  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  isarIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  isarIdGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  isarIdGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  isarIdLessThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 0, value: value));
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  isarIdLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  isarIdBetween(int lower, int upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 0, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  templateIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  templateIdGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  templateIdGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  templateIdLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  templateIdLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  templateIdBetween(String lower, String upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  templateIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  templateIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  templateIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  templateIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  templateIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  templateIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  nameGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  nameGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  nameLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  nameLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  nameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  nameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  iconCodePointEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  iconCodePointGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  iconCodePointGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  iconCodePointLessThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 3, value: value));
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  iconCodePointLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  iconCodePointBetween(int lower, int upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 3, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  subtaskTitlesElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 4, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  subtaskTitlesElementGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  subtaskTitlesElementGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  subtaskTitlesElementLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 4, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  subtaskTitlesElementLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  subtaskTitlesElementBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  subtaskTitlesElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  subtaskTitlesElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  subtaskTitlesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  subtaskTitlesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 4,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  subtaskTitlesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 4, value: ''),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  subtaskTitlesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 4, value: ''),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  subtaskTitlesIsEmpty() {
    return not().subtaskTitlesIsNotEmpty();
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  subtaskTitlesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 4, value: null),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  categoryEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 5, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  categoryGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  categoryGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  categoryLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 5, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  categoryLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  categoryBetween(String lower, String upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 5,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  categoryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  categoryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  categoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  categoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 5,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 5, value: ''),
      );
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterFilterCondition>
  categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 5, value: ''),
      );
    });
  }
}

extension TemplateModelQueryObject
    on QueryBuilder<TemplateModel, TemplateModel, QFilterCondition> {}

extension TemplateModelQuerySortBy
    on QueryBuilder<TemplateModel, TemplateModel, QSortBy> {
  QueryBuilder<TemplateModel, TemplateModel, QAfterSortBy> sortByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterSortBy> sortByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterSortBy> sortByTemplateId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterSortBy>
  sortByTemplateIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterSortBy> sortByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterSortBy> sortByNameDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterSortBy>
  sortByIconCodePoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterSortBy>
  sortByIconCodePointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterSortBy> sortByCategory({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterSortBy> sortByCategoryDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension TemplateModelQuerySortThenBy
    on QueryBuilder<TemplateModel, TemplateModel, QSortThenBy> {
  QueryBuilder<TemplateModel, TemplateModel, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterSortBy> thenByTemplateId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterSortBy>
  thenByTemplateIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterSortBy> thenByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterSortBy> thenByNameDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterSortBy>
  thenByIconCodePoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterSortBy>
  thenByIconCodePointDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterSortBy> thenByCategory({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterSortBy> thenByCategoryDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension TemplateModelQueryWhereDistinct
    on QueryBuilder<TemplateModel, TemplateModel, QDistinct> {
  QueryBuilder<TemplateModel, TemplateModel, QAfterDistinct>
  distinctByTemplateId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterDistinct>
  distinctByIconCodePoint() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterDistinct>
  distinctBySubtaskTitles() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<TemplateModel, TemplateModel, QAfterDistinct>
  distinctByCategory({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5, caseSensitive: caseSensitive);
    });
  }
}

extension TemplateModelQueryProperty1
    on QueryBuilder<TemplateModel, TemplateModel, QProperty> {
  QueryBuilder<TemplateModel, int, QAfterProperty> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<TemplateModel, String, QAfterProperty> templateIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<TemplateModel, String, QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<TemplateModel, int, QAfterProperty> iconCodePointProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<TemplateModel, List<String>, QAfterProperty>
  subtaskTitlesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<TemplateModel, String, QAfterProperty> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }
}

extension TemplateModelQueryProperty2<R>
    on QueryBuilder<TemplateModel, R, QAfterProperty> {
  QueryBuilder<TemplateModel, (R, int), QAfterProperty> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<TemplateModel, (R, String), QAfterProperty>
  templateIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<TemplateModel, (R, String), QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<TemplateModel, (R, int), QAfterProperty>
  iconCodePointProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<TemplateModel, (R, List<String>), QAfterProperty>
  subtaskTitlesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<TemplateModel, (R, String), QAfterProperty> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }
}

extension TemplateModelQueryProperty3<R1, R2>
    on QueryBuilder<TemplateModel, (R1, R2), QAfterProperty> {
  QueryBuilder<TemplateModel, (R1, R2, int), QOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<TemplateModel, (R1, R2, String), QOperations>
  templateIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<TemplateModel, (R1, R2, String), QOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<TemplateModel, (R1, R2, int), QOperations>
  iconCodePointProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<TemplateModel, (R1, R2, List<String>), QOperations>
  subtaskTitlesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<TemplateModel, (R1, R2, String), QOperations>
  categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }
}

// **************************************************************************
// _IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

final SubTaskModelSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'SubTaskModel',

    embedded: true,
    properties: [
      IsarPropertySchema(name: 'id', type: IsarType.string),
      IsarPropertySchema(name: 'title', type: IsarType.string),
      IsarPropertySchema(name: 'isCompleted', type: IsarType.bool),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<void, SubTaskModel>(
    serialize: serializeSubTaskModel,
    deserialize: deserializeSubTaskModel,
  ),
);

@isarProtected
int serializeSubTaskModel(IsarWriter writer, SubTaskModel object) {
  IsarCore.writeString(writer, 1, object.id);
  IsarCore.writeString(writer, 2, object.title);
  IsarCore.writeBool(writer, 3, value: object.isCompleted);
  return 0;
}

@isarProtected
SubTaskModel deserializeSubTaskModel(IsarReader reader) {
  final object = SubTaskModel();
  object.id = IsarCore.readString(reader, 1) ?? '';
  object.title = IsarCore.readString(reader, 2) ?? '';
  object.isCompleted = IsarCore.readBool(reader, 3);
  return object;
}

extension SubTaskModelQueryFilter
    on QueryBuilder<SubTaskModel, SubTaskModel, QFilterCondition> {
  QueryBuilder<SubTaskModel, SubTaskModel, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SubTaskModel, SubTaskModel, QAfterFilterCondition> idGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskModel, SubTaskModel, QAfterFilterCondition>
  idGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskModel, SubTaskModel, QAfterFilterCondition> idLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SubTaskModel, SubTaskModel, QAfterFilterCondition>
  idLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskModel, SubTaskModel, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskModel, SubTaskModel, QAfterFilterCondition> idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskModel, SubTaskModel, QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskModel, SubTaskModel, QAfterFilterCondition> idContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskModel, SubTaskModel, QAfterFilterCondition> idMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskModel, SubTaskModel, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<SubTaskModel, SubTaskModel, QAfterFilterCondition>
  idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<SubTaskModel, SubTaskModel, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SubTaskModel, SubTaskModel, QAfterFilterCondition>
  titleGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskModel, SubTaskModel, QAfterFilterCondition>
  titleGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskModel, SubTaskModel, QAfterFilterCondition> titleLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SubTaskModel, SubTaskModel, QAfterFilterCondition>
  titleLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskModel, SubTaskModel, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskModel, SubTaskModel, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskModel, SubTaskModel, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskModel, SubTaskModel, QAfterFilterCondition> titleContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskModel, SubTaskModel, QAfterFilterCondition> titleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SubTaskModel, SubTaskModel, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<SubTaskModel, SubTaskModel, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<SubTaskModel, SubTaskModel, QAfterFilterCondition>
  isCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 3, value: value),
      );
    });
  }
}

extension SubTaskModelQueryObject
    on QueryBuilder<SubTaskModel, SubTaskModel, QFilterCondition> {}
