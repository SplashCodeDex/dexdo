import 'dart:async';
import 'dart:convert';

import 'package:dexdo/core/error/failures.dart';
import 'package:dexdo/core/services/notification_service.dart';
import 'package:dexdo/core/utils/haptics.dart';
import 'package:dexdo/core/utils/logger.dart';
import 'package:dexdo/features/tasks/data/repositories/task_repository_provider.dart';
import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:dexdo/features/tasks/domain/repositories/task_repository.dart';
import 'package:dexdo/features/tasks/presentation/providers/task_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

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
    _notifications = NotificationService();
    
    Future.microtask(() => _loadData());
    
    return TaskState(isLoading: true);
  }

  Future<void> _loadData() async {
    try {
      await _repository.init();
      await _notifications.init();
      await reloadFromStorage();
    } catch (e, stack) {
      _handleError(e, stack, 'Initialization failed');
    }
  }

  void _handleError(dynamic e, StackTrace stack, String message) {
    AppLogger.e(message, e, stack);
    state = state.copyWith(
      error: FailureMapper.map(e),
      isLoading: false,
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> reloadFromStorage() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
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
    } catch (e, stack) {
      _handleError(e, stack, 'Reload from storage failed');
    }
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

  void setSortOption(TaskSortOption option, {bool? ascending}) {
    state = state.copyWith(
      sortOption: option,
      sortAscending: ascending ?? (option == state.sortOption ? !state.sortAscending : true),
    );
    _updateFilteredTasks();
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
      // Starred tasks always come first unless we implement a very specific sort
      if (a.isStarred && !b.isStarred) return -1;
      if (!a.isStarred && b.isStarred) return 1;

      int comparison;
      switch (state.sortOption) {
        case TaskSortOption.dueDate:
          if (a.dueDate == null && b.dueDate == null) {
            comparison = 0;
          } else if (a.dueDate == null) {
            comparison = 1;
          } else if (b.dueDate == null) {
            comparison = -1;
          } else {
            comparison = a.dueDate!.compareTo(b.dueDate!);
          }
          break;
        case TaskSortOption.priority:
          comparison = b.priority.index.compareTo(a.priority.index); // Higher priority first
          break;
        case TaskSortOption.title:
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case TaskSortOption.orderIndex:
          comparison = a.orderIndex.compareTo(b.orderIndex);
          break;
      }

      if (comparison == 0) {
        return a.id.compareTo(b.id);
      }
      
      return state.sortAscending ? comparison : -comparison;
    });
    
    state = state.copyWith(filteredTasks: filtered);
  }

  void setSelectedTask(Task? task) {
    state = state.copyWith(selectedTask: task, clearSelectedTask: task == null);
  }

  Future<void> addTask({DateTime? dueDate}) async {
    try {
      final String category = state.selectedCategory == 'All' ? 'Personal' : state.selectedCategory;
      
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
      unawaited(AppHaptics.light());
      await _repository.saveTasks(state.tasks);
    } catch (e, stack) {
      _handleError(e, stack, 'Add task failed');
    }
  }

  Future<void> updateTask(Task task, String title, String description) async {
    try {
      final updatedTask = task.copyWith(title: title, description: description);
      _replaceTask(updatedTask);
      await _repository.saveTask(updatedTask);
    } catch (e, stack) {
      _handleError(e, stack, 'Update task failed');
    }
  }

  Future<void> updateTaskPriority(Task task, TaskPriority priority) async {
    try {
      final updatedTask = task.copyWith(priority: priority);
      _replaceTask(updatedTask);
      unawaited(AppHaptics.light());
      await _repository.saveTask(updatedTask);
    } catch (e, stack) {
      _handleError(e, stack, 'Update task priority failed');
    }
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
    try {
      final isMarkingDone = !task.isCompleted;
      final updatedTask = task.copyWith(
        isCompleted: isMarkingDone,
        completionDate: isMarkingDone ? DateTime.now() : null,
      );
      
      _replaceTask(updatedTask);
      
      if (isMarkingDone) {
        unawaited(AppHaptics.heavy());
        await _notifications.cancelTaskReminder(task.id);

        final List<Task> pendingClones = [];
        _handleRecurrence(task, DateTime.now(), pendingClones);
        if (pendingClones.isNotEmpty) {
          state = state.copyWith(tasks: [...state.tasks, ...pendingClones]);
          if (state.selectedTask?.id == task.id) {
            state = state.copyWith(selectedTask: pendingClones.first);
          }
          _updateFilteredTasks();
          await _repository.saveTasks(state.tasks);
        }
      } else {
        unawaited(AppHaptics.medium());
        await _notifications.scheduleTaskReminder(updatedTask);
      }
      
      await _repository.saveTask(updatedTask);
    } catch (e, stack) {
      _handleError(e, stack, 'Toggle task failed');
    }
  }

  void _handleRecurrence(Task task, DateTime now, List<Task> newTasksList) {
    if (task.recurrence != 'none') {
      final bool exists = state.tasks.any((t) => t.title == task.title && !t.isCompleted && t.dueDate != null && t.dueDate!.isAfter(now));
      if (exists) return;
      DateTime nextDueDate = task.dueDate ?? now;
      if (task.recurrence == 'daily') {
        nextDueDate = nextDueDate.add(const Duration(days: 1));
      } else if (task.recurrence == 'weekly') {
        nextDueDate = nextDueDate.add(const Duration(days: 7));
      } else if (task.recurrence == 'monthly') {
        nextDueDate = DateTime(nextDueDate.year, nextDueDate.month + 1, nextDueDate.day, nextDueDate.hour, nextDueDate.minute);
      } else if (task.recurrence == 'yearly') {
        nextDueDate = DateTime(nextDueDate.year + 1, nextDueDate.month, nextDueDate.day, nextDueDate.hour, nextDueDate.minute);
      }

      final clone = Task(
        id: _uuid.v4(),
        title: task.title,
        description: task.description,
        isCompleted: false,
        completionDate: null,
        isStarred: task.isStarred,
        icon: task.icon,
        color: task.color,
        category: task.category,
        dueDate: nextDueDate,
        recurrence: task.recurrence,
        orderIndex: task.orderIndex - 1,
        priority: task.priority,
        subtasks: task.subtasks.map((s) => SubTask(id: _uuid.v4(), title: s.title, isCompleted: false)).toList(),
      );
      newTasksList.add(clone);
    }
  }

  Future<void> addSubtask(Task task, String title) async {
    try {
      final newSubtask = SubTask(id: _uuid.v4(), title: title, isCompleted: false);
      final updatedSubtasks = [...task.subtasks, newSubtask];
      final updatedTask = task.copyWith(subtasks: updatedSubtasks);
      _replaceTask(updatedTask);
      await _repository.saveTask(updatedTask);
    } catch (e, stack) {
      _handleError(e, stack, 'Add subtask failed');
    }
  }

  Future<void> toggleSubtask(Task task, SubTask subtask) async {
    try {
      final updatedSubtasks = task.subtasks.map((s) {
        if (s.id == subtask.id) {
          final isMarkingDone = !s.isCompleted;
          if (isMarkingDone) {
            unawaited(AppHaptics.light());
          }
          return s.copyWith(isCompleted: isMarkingDone);
        }
        return s;
      }).toList();
      final updatedTask = task.copyWith(subtasks: updatedSubtasks);
      _replaceTask(updatedTask);
      await _repository.saveTask(updatedTask);
    } catch (e, stack) {
      _handleError(e, stack, 'Toggle subtask failed');
    }
  }

  Future<void> deleteSubtask(Task task, SubTask subtask) async {
    try {
      final updatedSubtasks = task.subtasks.where((s) => s.id != subtask.id).toList();
      final updatedTask = task.copyWith(subtasks: updatedSubtasks);
      _replaceTask(updatedTask);
      await _repository.saveTask(updatedTask);
    } catch (e, stack) {
      _handleError(e, stack, 'Delete subtask failed');
    }
  }

  Future<void> updateCategory(Task task, String category) async {
    try {
      final updatedTask = task.copyWith(
        category: category,
        color: state.categoryColors[category] ?? Colors.blue,
        icon: state.categoryIcons[category] ?? Icons.task_alt,
      );
      _replaceTask(updatedTask);
      await _repository.saveTask(updatedTask);
    } catch (e, stack) {
      _handleError(e, stack, 'Update category failed');
    }
  }

  Future<void> updateDueDate(Task task, DateTime? date) async {
    try {
      final updatedTask = task.copyWith(dueDate: date);
      _replaceTask(updatedTask);
      if (date == null) {
        await _notifications.cancelTaskReminder(task.id);
      } else if (!task.isCompleted) {
        await _notifications.scheduleTaskReminder(updatedTask);
      }
      await _repository.saveTask(updatedTask);
    } catch (e, stack) {
      _handleError(e, stack, 'Update due date failed');
    }
  }

  Future<void> updateRecurrence(Task task, String recurrence) async {
    try {
      final updatedTask = task.copyWith(recurrence: recurrence);
      _replaceTask(updatedTask);
      await _repository.saveTask(updatedTask);
    } catch (e, stack) {
      _handleError(e, stack, 'Update recurrence failed');
    }
  }

  Future<void> duplicateTask(Task task) async {
    try {
      final updatedTasks = state.tasks.map((t) => t.copyWith(orderIndex: t.orderIndex + 1)).toList();
      
      final duplicatedTask = task.copyWith(
        id: _uuid.v4(),
        title: task.title.isEmpty ? 'Copy of New Task' : 'Copy of ${task.title}',
        subtasks: task.subtasks.map((s) => s.copyWith(id: _uuid.v4())).toList(),
        orderIndex: 0,
      );

      state = state.copyWith(
        tasks: [duplicatedTask, ...updatedTasks],
      );
      _updateFilteredTasks();
      unawaited(AppHaptics.medium());
      await _repository.saveTasks(state.tasks);
    } catch (e, stack) {
      _handleError(e, stack, 'Duplicate task failed');
    }
  }

  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    try {
      final activeTasks = state.filteredTasks.where((t) => !t.isCompleted).toList();
      
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      
      final task = activeTasks.removeAt(oldIndex);
      activeTasks.insert(newIndex, task);
      
      final updatedTasks = List<Task>.from(state.tasks);
      for (int i = 0; i < activeTasks.length; i++) {
        final current = activeTasks[i];
        final indexInMain = updatedTasks.indexWhere((t) => t.id == current.id);
        if (indexInMain != -1) {
          updatedTasks[indexInMain] = updatedTasks[indexInMain].copyWith(orderIndex: i);
        }
      }
      
      state = state.copyWith(tasks: updatedTasks);
      _updateFilteredTasks();
      await _repository.saveTasks(state.tasks);
    } catch (e, stack) {
      _handleError(e, stack, 'Reorder tasks failed');
    }
  }

  Future<void> toggleStarred(Task task) async {
    try {
      final updatedTask = task.copyWith(isStarred: !task.isStarred);
      _replaceTask(updatedTask);
      unawaited(AppHaptics.light());
      await _repository.saveTask(updatedTask);
    } catch (e, stack) {
      _handleError(e, stack, 'Toggle starred failed');
    }
  }

  Future<void> deleteTask(Task task) async {
    try {
      final tasks = state.tasks.where((t) => t.id != task.id).toList();
      final selectedIds = Set<String>.from(state.selectedTaskIds)..remove(task.id);
      
      state = state.copyWith(
        tasks: tasks,
        selectedTaskIds: selectedIds,
        clearSelectedTask: state.selectedTask?.id == task.id,
      );
      
      _updateFilteredTasks();
      unawaited(AppHaptics.heavy());
      await _repository.deleteTask(task.id);
      await _notifications.cancelTaskReminder(task.id);
    } catch (e, stack) {
      _handleError(e, stack, 'Delete task failed');
    }
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
    final List<Task> pendingClones = [];
    final updatedTasks = state.tasks.map((task) {
      if (state.selectedTaskIds.contains(task.id)) {
        final updated = task.copyWith(isCompleted: completed, completionDate: completed ? now : null);
        if (completed) {
          _handleRecurrence(task, now, pendingClones);
        }
        return updated;
      }
      return task;
    }).toList();

    state = state.copyWith(
      tasks: [...updatedTasks, ...pendingClones],
      selectedTaskIds: {},
    );
    _updateFilteredTasks();
    await _repository.saveTasks(state.tasks);
  }

  Future<void> clearAllTasks() async {
    try {
      final taskIds = state.tasks.map((t) => t.id).toList();
      state = state.copyWith(tasks: [], selectedTaskIds: {}, clearSelectedTask: true);
      _updateFilteredTasks();
      await _repository.batchDeleteTasks(taskIds);
      for (var id in taskIds) {
        await _notifications.cancelTaskReminder(id);
      }
    } catch (e, stack) {
      _handleError(e, stack, 'Clear all tasks failed');
    }
  }

  Future<void> clearCompleted() async {
    try {
      final completed = state.tasks.where((t) => t.isCompleted).toList();
      final completedIds = completed.map((t) => t.id).toList();
      final tasks = state.tasks.where((t) => !t.isCompleted).toList();
      
      state = state.copyWith(
        tasks: tasks,
        selectedTaskIds: state.selectedTaskIds.where((id) => !completedIds.contains(id)).toSet(),
        clearSelectedTask: state.selectedTask != null && state.selectedTask!.isCompleted,
      );
      
      _updateFilteredTasks();
      await _repository.batchDeleteTasks(completedIds);
    } catch (e, stack) {
      _handleError(e, stack, 'Clear completed failed');
    }
  }

  Future<void> moveSelectedToCategory(String category) async {
    try {
      final updatedTasks = state.tasks.map((task) {
        if (state.selectedTaskIds.contains(task.id)) {
          return task.copyWith(
            category: category,
            color: state.categoryColors[category] ?? Colors.blue,
            icon: state.categoryIcons[category] ?? Icons.task_alt,
          );
        }
        return task;
      }).toList();

      state = state.copyWith(
        tasks: updatedTasks,
        selectedTaskIds: {},
      );
      _updateFilteredTasks();
      await _repository.saveTasks(state.tasks);
    } catch (e, stack) {
      _handleError(e, stack, 'Move selected to category failed');
    }
  }

  String exportTasksToJson() {
    return jsonEncode(state.tasks.map((t) => t.toJson()).toList());
  }

  Future<void> addCategory(String name, IconData icon, Color color) async {
    try {
      if (state.categories.contains(name)) return;
      
      final updatedCategories = [...state.categories, name];
      final updatedIcons = {...state.categoryIcons, name: icon};
      final updatedColors = {...state.categoryColors, name: color};
      
      state = state.copyWith(
        categories: updatedCategories,
        categoryIcons: updatedIcons,
        categoryColors: updatedColors,
      );
      
      await _repository.saveCategoryIcons(updatedIcons);
      await _repository.saveCategoryColors(updatedColors);
    } catch (e, stack) {
      _handleError(e, stack, 'Add category failed');
    }
  }

  Future<void> editCategory(String oldName, String newName, IconData icon, Color color) async {
    try {
      if (oldName == 'All' || oldName == 'Personal') return;
      
      final updatedCategories = state.categories.map((c) => c == oldName ? newName : c).toList();
      final updatedIcons = Map<String, IconData>.from(state.categoryIcons);
      updatedIcons.remove(oldName);
      updatedIcons[newName] = icon;
      
      final updatedColors = Map<String, Color>.from(state.categoryColors);
      updatedColors.remove(oldName);
      updatedColors[newName] = color;
      
      final updatedTasks = state.tasks.map((t) {
        if (t.category == oldName) {
          return t.copyWith(category: newName, icon: icon, color: color);
        }
        return t;
      }).toList();

      state = state.copyWith(
        tasks: updatedTasks,
        categories: updatedCategories,
        categoryIcons: updatedIcons,
        categoryColors: updatedColors,
        selectedCategory: state.selectedCategory == oldName ? newName : state.selectedCategory,
      );
      
      _updateFilteredTasks();
      await _repository.saveTasks(state.tasks);
      await _repository.saveCategoryIcons(updatedIcons);
      await _repository.saveCategoryColors(updatedColors);
    } catch (e, stack) {
      _handleError(e, stack, 'Edit category failed');
    }
  }

  Future<void> deleteCategory(String category) async {
    try {
      if (category == 'All' || category == 'Personal') return;
      
      final updatedCategories = state.categories.where((c) => c != category).toList();
      final updatedIcons = Map<String, IconData>.from(state.categoryIcons)..remove(category);
      final updatedColors = Map<String, Color>.from(state.categoryColors)..remove(category);
      
      final updatedTasks = state.tasks.map((t) {
        if (t.category == category) {
          return t.copyWith(
            category: 'Personal',
            icon: state.categoryIcons['Personal'] ?? Icons.person_rounded,
            color: state.categoryColors['Personal'] ?? Colors.amber,
          );
        }
        return t;
      }).toList();

      state = state.copyWith(
        tasks: updatedTasks,
        categories: updatedCategories,
        categoryIcons: updatedIcons,
        categoryColors: updatedColors,
        selectedCategory: state.selectedCategory == category ? 'All' : state.selectedCategory,
      );
      
      _updateFilteredTasks();
      await _repository.saveTasks(state.tasks);
      await _repository.saveCategoryIcons(updatedIcons);
      await _repository.saveCategoryColors(updatedColors);
    } catch (e, stack) {
      _handleError(e, stack, 'Delete category failed');
    }
  }
}
