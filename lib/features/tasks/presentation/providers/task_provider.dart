import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../data/repositories/task_repository_provider.dart';
import '../../../../core/services/notification_service.dart';
import 'task_state.dart';

final taskProvider = NotifierProvider<TaskNotifier, TaskState>(() {
  return TaskNotifier();
});

class TaskNotifier extends Notifier<TaskState> {
  late TaskRepository _repository;
  late NotificationService _notifications;
  final _uuid = const Uuid();
  Timer? _searchDebounce;

  @override
  TaskState build() {
    _repository = ref.watch(taskRepositoryProvider);
    _notifications = NotificationService(); // Could also be a provider
    
    // Future.microtask is used to load data after the build method completes
    Future.microtask(() => _loadData());
    
    return TaskState(isLoading: true);
  }

  Future<void> _loadData() async {
    await _repository.init();
    await _notifications.init();
    await reloadFromStorage();
  }

  Future<void> reloadFromStorage() async {
    state = state.copyWith(isLoading: true);
    
    final categories = await _repository.loadCategories();
    final icons = await _repository.loadCategoryIcons();
    final colors = await _repository.loadCategoryColors();
    final tasks = await _repository.loadTasks();

    state = state.copyWith(
      tasks: tasks,
      categories: categories.isNotEmpty ? categories : state.categories,
      categoryIcons: icons.isNotEmpty ? icons : state.categoryIcons,
      categoryColors: colors.isNotEmpty ? colors : state.categoryColors,
      isLoading: false,
    );
    _updateFilteredTasks();
  }

  void setCategory(String category) {
    if (state.selectedCategory == category) return;
    state = state.copyWith(selectedCategory: category);
    _updateFilteredTasks();
  }

  void setSearchQuery(String query) {
    if (state.searchQuery == query) return;
    state = state.copyWith(searchQuery: query);

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _updateFilteredTasks();
    });
  }

  void _updateFilteredTasks() {
    List<Task> filtered = state.selectedCategory == 'All' 
        ? List.from(state.tasks) 
        : state.tasks.where((t) => t.category == state.selectedCategory).toList();

    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((t) => 
        t.title.toLowerCase().contains(query) ||
        t.description.toLowerCase().contains(query)
      ).toList();
    }
    
    filtered.sort((a, b) {
      if (a.isStarred && !b.isStarred) return -1;
      if (!a.isStarred && b.isStarred) return 1;
      int res = a.orderIndex.compareTo(b.orderIndex);
      if (res != 0) return res;
      return a.id.compareTo(b.id);
    });
    
    state = state.copyWith(filteredTasks: filtered);
  }

  void setSelectedTask(Task? task) {
    state = state.copyWith(selectedTask: task, clearSelectedTask: task == null);
  }

  Future<void> addTask({DateTime? dueDate}) async {
    String category = state.selectedCategory == 'All' ? 'Personal' : state.selectedCategory;
    
    final updatedTasks = state.tasks.map((t) => t.copyWith(orderIndex: t.orderIndex + 1)).toList();

    final newTask = Task(
      id: _uuid.v4(),
      title: '',
      category: category,
      color: state.categoryColors[category] ?? Colors.blue,
      icon: state.categoryIcons[category] ?? Icons.task_alt,
      orderIndex: 0,
      dueDate: dueDate,
    );
    
    state = state.copyWith(
      tasks: [newTask, ...updatedTasks],
      selectedTask: newTask,
    );
    _updateFilteredTasks();
    await _repository.saveTasks(state.tasks);
  }

  Future<void> updateTask(Task task, String title, String description) async {
    final updatedTask = task.copyWith(title: title, description: description);
    _replaceTask(updatedTask);
    await _repository.saveTask(updatedTask);
  }

  void _replaceTask(Task updatedTask) {
    final tasks = state.tasks.map((t) => t.id == updatedTask.id ? updatedTask : t).toList();
    state = state.copyWith(tasks: tasks);
    if (state.selectedTask?.id == updatedTask.id) {
      state = state.copyWith(selectedTask: updatedTask);
    }
    _updateFilteredTasks();
  }

  Future<void> toggleTask(Task task) async {
    final isMarkingDone = !task.isCompleted;
    final updatedTask = task.copyWith(
      isCompleted: isMarkingDone,
      completionDate: isMarkingDone ? DateTime.now() : null,
    );
    
    _replaceTask(updatedTask);
    
    if (isMarkingDone) {
      HapticFeedback.heavyImpact();
      await _notifications.cancelTaskReminder(task.id);
    } else {
      HapticFeedback.mediumImpact();
      await _notifications.scheduleTaskReminder(updatedTask);
    }
    
    await _repository.saveTask(updatedTask);
  }

  Future<void> toggleStarred(Task task) async {
    final updatedTask = task.copyWith(isStarred: !task.isStarred);
    _replaceTask(updatedTask);
    HapticFeedback.selectionClick();
    await _repository.saveTask(updatedTask);
  }

  Future<void> deleteTask(Task task) async {
    final tasks = state.tasks.where((t) => t.id != task.id).toList();
    final selectedIds = Set<String>.from(state.selectedTaskIds)..remove(task.id);
    
    state = state.copyWith(
      tasks: tasks,
      selectedTaskIds: selectedIds,
      clearSelectedTask: state.selectedTask?.id == task.id,
    );
    
    _updateFilteredTasks();
    HapticFeedback.vibrate();
    await _repository.deleteTask(task.id);
    await _notifications.cancelTaskReminder(task.id);
  }

  void toggleTaskSelection(String taskId) {
    final selectedIds = Set<String>.from(state.selectedTaskIds);
    if (selectedIds.contains(taskId)) {
      selectedIds.remove(taskId);
    } else {
      selectedIds.add(taskId);
    }
    state = state.copyWith(selectedTaskIds: selectedIds);
  }

  void clearSelection() {
    state = state.copyWith(selectedTaskIds: {});
  }

  Future<void> deleteSelectedTasks() async {
    final toDeleteIds = state.selectedTaskIds.toList();
    final tasks = state.tasks.where((t) => !state.selectedTaskIds.contains(t.id)).toList();
    
    state = state.copyWith(
      tasks: tasks,
      selectedTaskIds: {},
      clearSelectedTask: state.selectedTask != null && state.selectedTaskIds.contains(state.selectedTask!.id),
    );
    
    _updateFilteredTasks();
    await _repository.batchDeleteTasks(toDeleteIds);
    for (var id in toDeleteIds) {
      await _notifications.cancelTaskReminder(id);
    }
  }

  // Simplified version of other methods for brevity, can expand later
  Future<void> markSelectedAsCompleted(bool completed) async {
    final now = DateTime.now();
    final updatedTasks = state.tasks.map((task) {
      if (state.selectedTaskIds.contains(task.id)) {
        return task.copyWith(isCompleted: completed, completionDate: completed ? now : null);
      }
      return task;
    }).toList();

    state = state.copyWith(tasks: updatedTasks, selectedTaskIds: {});
    _updateFilteredTasks();
    await _repository.saveTasks(state.tasks);
  }
}
