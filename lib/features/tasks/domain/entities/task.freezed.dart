// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubTask {

 String get id; String get title; bool get isCompleted;
/// Create a copy of SubTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubTaskCopyWith<SubTask> get copyWith => _$SubTaskCopyWithImpl<SubTask>(this as SubTask, _$identity);

  /// Serializes this SubTask to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubTask&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,isCompleted);

@override
String toString() {
  return 'SubTask(id: $id, title: $title, isCompleted: $isCompleted)';
}


}

/// @nodoc
abstract mixin class $SubTaskCopyWith<$Res>  {
  factory $SubTaskCopyWith(SubTask value, $Res Function(SubTask) _then) = _$SubTaskCopyWithImpl;
@useResult
$Res call({
 String id, String title, bool isCompleted
});




}
/// @nodoc
class _$SubTaskCopyWithImpl<$Res>
    implements $SubTaskCopyWith<$Res> {
  _$SubTaskCopyWithImpl(this._self, this._then);

  final SubTask _self;
  final $Res Function(SubTask) _then;

/// Create a copy of SubTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? isCompleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SubTask].
extension SubTaskPatterns on SubTask {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubTask() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubTask value)  $default,){
final _that = this;
switch (_that) {
case _SubTask():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubTask value)?  $default,){
final _that = this;
switch (_that) {
case _SubTask() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  bool isCompleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubTask() when $default != null:
return $default(_that.id,_that.title,_that.isCompleted);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  bool isCompleted)  $default,) {final _that = this;
switch (_that) {
case _SubTask():
return $default(_that.id,_that.title,_that.isCompleted);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  bool isCompleted)?  $default,) {final _that = this;
switch (_that) {
case _SubTask() when $default != null:
return $default(_that.id,_that.title,_that.isCompleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubTask implements SubTask {
  const _SubTask({required this.id, required this.title, this.isCompleted = false});
  factory _SubTask.fromJson(Map<String, dynamic> json) => _$SubTaskFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey() final  bool isCompleted;

/// Create a copy of SubTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubTaskCopyWith<_SubTask> get copyWith => __$SubTaskCopyWithImpl<_SubTask>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubTaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubTask&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,isCompleted);

@override
String toString() {
  return 'SubTask(id: $id, title: $title, isCompleted: $isCompleted)';
}


}

/// @nodoc
abstract mixin class _$SubTaskCopyWith<$Res> implements $SubTaskCopyWith<$Res> {
  factory _$SubTaskCopyWith(_SubTask value, $Res Function(_SubTask) _then) = __$SubTaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, bool isCompleted
});




}
/// @nodoc
class __$SubTaskCopyWithImpl<$Res>
    implements _$SubTaskCopyWith<$Res> {
  __$SubTaskCopyWithImpl(this._self, this._then);

  final _SubTask _self;
  final $Res Function(_SubTask) _then;

/// Create a copy of SubTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? isCompleted = null,}) {
  return _then(_SubTask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Task {

 String get id; String get title; String get description; bool get isCompleted; DateTime? get completionDate; bool get isStarred;@IconDataConverter() IconData get icon;@ColorConverter() Color get color; String get category; int get attachmentCount; List<SubTask> get subtasks; DateTime? get dueDate; int get orderIndex; String get recurrence; TaskPriority get priority;
/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskCopyWith<Task> get copyWith => _$TaskCopyWithImpl<Task>(this as Task, _$identity);

  /// Serializes this Task to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Task&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.completionDate, completionDate) || other.completionDate == completionDate)&&(identical(other.isStarred, isStarred) || other.isStarred == isStarred)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.category, category) || other.category == category)&&(identical(other.attachmentCount, attachmentCount) || other.attachmentCount == attachmentCount)&&const DeepCollectionEquality().equals(other.subtasks, subtasks)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.recurrence, recurrence) || other.recurrence == recurrence)&&(identical(other.priority, priority) || other.priority == priority));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,isCompleted,completionDate,isStarred,icon,color,category,attachmentCount,const DeepCollectionEquality().hash(subtasks),dueDate,orderIndex,recurrence,priority);

@override
String toString() {
  return 'Task(id: $id, title: $title, description: $description, isCompleted: $isCompleted, completionDate: $completionDate, isStarred: $isStarred, icon: $icon, color: $color, category: $category, attachmentCount: $attachmentCount, subtasks: $subtasks, dueDate: $dueDate, orderIndex: $orderIndex, recurrence: $recurrence, priority: $priority)';
}


}

/// @nodoc
abstract mixin class $TaskCopyWith<$Res>  {
  factory $TaskCopyWith(Task value, $Res Function(Task) _then) = _$TaskCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, bool isCompleted, DateTime? completionDate, bool isStarred,@IconDataConverter() IconData icon,@ColorConverter() Color color, String category, int attachmentCount, List<SubTask> subtasks, DateTime? dueDate, int orderIndex, String recurrence, TaskPriority priority
});




}
/// @nodoc
class _$TaskCopyWithImpl<$Res>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._self, this._then);

  final Task _self;
  final $Res Function(Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? isCompleted = null,Object? completionDate = freezed,Object? isStarred = null,Object? icon = null,Object? color = null,Object? category = null,Object? attachmentCount = null,Object? subtasks = null,Object? dueDate = freezed,Object? orderIndex = null,Object? recurrence = null,Object? priority = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,completionDate: freezed == completionDate ? _self.completionDate : completionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isStarred: null == isStarred ? _self.isStarred : isStarred // ignore: cast_nullable_to_non_nullable
as bool,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,attachmentCount: null == attachmentCount ? _self.attachmentCount : attachmentCount // ignore: cast_nullable_to_non_nullable
as int,subtasks: null == subtasks ? _self.subtasks : subtasks // ignore: cast_nullable_to_non_nullable
as List<SubTask>,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,recurrence: null == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,
  ));
}

}


/// Adds pattern-matching-related methods to [Task].
extension TaskPatterns on Task {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Task value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Task value)  $default,){
final _that = this;
switch (_that) {
case _Task():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Task value)?  $default,){
final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  bool isCompleted,  DateTime? completionDate,  bool isStarred, @IconDataConverter()  IconData icon, @ColorConverter()  Color color,  String category,  int attachmentCount,  List<SubTask> subtasks,  DateTime? dueDate,  int orderIndex,  String recurrence,  TaskPriority priority)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.isCompleted,_that.completionDate,_that.isStarred,_that.icon,_that.color,_that.category,_that.attachmentCount,_that.subtasks,_that.dueDate,_that.orderIndex,_that.recurrence,_that.priority);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  bool isCompleted,  DateTime? completionDate,  bool isStarred, @IconDataConverter()  IconData icon, @ColorConverter()  Color color,  String category,  int attachmentCount,  List<SubTask> subtasks,  DateTime? dueDate,  int orderIndex,  String recurrence,  TaskPriority priority)  $default,) {final _that = this;
switch (_that) {
case _Task():
return $default(_that.id,_that.title,_that.description,_that.isCompleted,_that.completionDate,_that.isStarred,_that.icon,_that.color,_that.category,_that.attachmentCount,_that.subtasks,_that.dueDate,_that.orderIndex,_that.recurrence,_that.priority);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  bool isCompleted,  DateTime? completionDate,  bool isStarred, @IconDataConverter()  IconData icon, @ColorConverter()  Color color,  String category,  int attachmentCount,  List<SubTask> subtasks,  DateTime? dueDate,  int orderIndex,  String recurrence,  TaskPriority priority)?  $default,) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.isCompleted,_that.completionDate,_that.isStarred,_that.icon,_that.color,_that.category,_that.attachmentCount,_that.subtasks,_that.dueDate,_that.orderIndex,_that.recurrence,_that.priority);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Task extends Task {
  const _Task({required this.id, required this.title, this.description = '', this.isCompleted = false, this.completionDate, this.isStarred = false, @IconDataConverter() this.icon = Icons.task_alt, @ColorConverter() this.color = Colors.blue, this.category = 'Personal', this.attachmentCount = 0, final  List<SubTask> subtasks = const [], this.dueDate, this.orderIndex = 0, this.recurrence = 'none', this.priority = TaskPriority.medium}): _subtasks = subtasks,super._();
  factory _Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey() final  String description;
@override@JsonKey() final  bool isCompleted;
@override final  DateTime? completionDate;
@override@JsonKey() final  bool isStarred;
@override@JsonKey()@IconDataConverter() final  IconData icon;
@override@JsonKey()@ColorConverter() final  Color color;
@override@JsonKey() final  String category;
@override@JsonKey() final  int attachmentCount;
 final  List<SubTask> _subtasks;
@override@JsonKey() List<SubTask> get subtasks {
  if (_subtasks is EqualUnmodifiableListView) return _subtasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subtasks);
}

@override final  DateTime? dueDate;
@override@JsonKey() final  int orderIndex;
@override@JsonKey() final  String recurrence;
@override@JsonKey() final  TaskPriority priority;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskCopyWith<_Task> get copyWith => __$TaskCopyWithImpl<_Task>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Task&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.completionDate, completionDate) || other.completionDate == completionDate)&&(identical(other.isStarred, isStarred) || other.isStarred == isStarred)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.category, category) || other.category == category)&&(identical(other.attachmentCount, attachmentCount) || other.attachmentCount == attachmentCount)&&const DeepCollectionEquality().equals(other._subtasks, _subtasks)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.orderIndex, orderIndex) || other.orderIndex == orderIndex)&&(identical(other.recurrence, recurrence) || other.recurrence == recurrence)&&(identical(other.priority, priority) || other.priority == priority));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,isCompleted,completionDate,isStarred,icon,color,category,attachmentCount,const DeepCollectionEquality().hash(_subtasks),dueDate,orderIndex,recurrence,priority);

@override
String toString() {
  return 'Task(id: $id, title: $title, description: $description, isCompleted: $isCompleted, completionDate: $completionDate, isStarred: $isStarred, icon: $icon, color: $color, category: $category, attachmentCount: $attachmentCount, subtasks: $subtasks, dueDate: $dueDate, orderIndex: $orderIndex, recurrence: $recurrence, priority: $priority)';
}


}

/// @nodoc
abstract mixin class _$TaskCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$TaskCopyWith(_Task value, $Res Function(_Task) _then) = __$TaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, bool isCompleted, DateTime? completionDate, bool isStarred,@IconDataConverter() IconData icon,@ColorConverter() Color color, String category, int attachmentCount, List<SubTask> subtasks, DateTime? dueDate, int orderIndex, String recurrence, TaskPriority priority
});




}
/// @nodoc
class __$TaskCopyWithImpl<$Res>
    implements _$TaskCopyWith<$Res> {
  __$TaskCopyWithImpl(this._self, this._then);

  final _Task _self;
  final $Res Function(_Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? isCompleted = null,Object? completionDate = freezed,Object? isStarred = null,Object? icon = null,Object? color = null,Object? category = null,Object? attachmentCount = null,Object? subtasks = null,Object? dueDate = freezed,Object? orderIndex = null,Object? recurrence = null,Object? priority = null,}) {
  return _then(_Task(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,completionDate: freezed == completionDate ? _self.completionDate : completionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isStarred: null == isStarred ? _self.isStarred : isStarred // ignore: cast_nullable_to_non_nullable
as bool,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as IconData,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Color,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,attachmentCount: null == attachmentCount ? _self.attachmentCount : attachmentCount // ignore: cast_nullable_to_non_nullable
as int,subtasks: null == subtasks ? _self._subtasks : subtasks // ignore: cast_nullable_to_non_nullable
as List<SubTask>,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,orderIndex: null == orderIndex ? _self.orderIndex : orderIndex // ignore: cast_nullable_to_non_nullable
as int,recurrence: null == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as String,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,
  ));
}


}

// dart format on
