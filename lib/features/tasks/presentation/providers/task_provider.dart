import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dexdo/core/error/failures.dart';
import 'package:dexdo/core/services/ai_service.dart';
import 'package:dexdo/core/services/notification_service.dart';
import 'package:dexdo/core/utils/haptics.dart';
import 'package:dexdo/core/utils/logger.dart';
import 'package:dexdo/features/tasks/data/repositories/task_repository_provider.dart';
import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:dexdo/features/tasks/domain/entities/task_statistics.dart';
import 'package:dexdo/features/tasks/domain/repositories/task_repository.dart';
import 'package:dexdo/features/tasks/presentation/providers/task_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final taskProvider = NotifierProvider<TaskNotifier, TaskState>(() {
  return TaskNotifier();
});

class TaskNotifier extends Notifier<TaskState> {
  late TaskRepository _repository;
  late NotificationService _notifications;
  final _aiService = AIService();
  final _uuid = const Uuid();
  Timer? _searchDebounce;
  bool _disposed = false;

  @override
  TaskState build() {
    _repository = ref.watch(taskRepositoryProvider);
    _notifications = ref.watch(notificationServiceProvider);
    
    ref.onDispose(() {
      _disposed = true;
      _searchDebounce?.cancel();
    });

    unawaited(Future.microtask(() => _loadData()));
    
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
    if (_disposed) return;
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
    if (_disposed) return;
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      final categories = await _repository.loadCategories();
      final icons = await _repository.loadCategoryIcons();
      final colors = await _repository.loadCategoryColors();
      final tasks = await _repository.loadTasks();

      if (_disposed) return;
      state = state.copyWith(
        tasks: tasks,
        categories: categories.isNotEmpty ? categories : state.categories,
        categoryIcons: icons.isNotEmpty ? icons : state.categoryIcons,
        categoryColors: colors.isNotEmpty ? colors : state.categoryColors,
        isLoading: false,
      );
      _updateFilteredTasks();
      _calculateStats();
    } catch (e, stack) {
      _handleError(e, stack, 'Reload from storage failed');
    }
  }

  void silentUpdate(List<Task> updatedTasks) {
    if (_disposed) return;
    state = state.copyWith(tasks: updatedTasks);
    _updateFilteredTasks();
    _calculateStats();
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
    
    final active = filtered.where((t) => !t.isCompleted).toList();
    final completed = filtered.where((t) => t.isCompleted).toList();

    // Logic for Dashboard-specific lists
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final completedTodayCount = state.tasks.where((t) {
      if (t.isCompleted && t.completionDate != null) {
        final cDate = DateTime(t.completionDate!.year, t.completionDate!.month, t.completionDate!.day);
        return cDate.isAtSameMomentAs(today);
      }
      return false;
    }).length;

    final todayTasks = active.where((t) {
      if (t.dueDate != null) {
        final taskDate = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
        return taskDate.isBefore(today) || taskDate.isAtSameMomentAs(today);
      }
      return t.isStarred;
    }).toList();

    final deepWork = active.where((t) =>
      t.isStarred ||
      t.priority == TaskPriority.high ||
      t.subtasks.length >= 3
    ).toList();

    final recovery = active.where((t) =>
      t.priority == TaskPriority.low &&
      t.subtasks.isEmpty &&
      !t.isStarred
    ).toList();

    // Logic for Upcoming Tasks (Optimized: pre-sort for UI)
    final upcoming = List<Task>.from(active)
      ..sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });

    state = state.copyWith(
      filteredTasks: filtered,
      activeTasks: active,
      completedTasks: completed,
      todayTasks: todayTasks,
      upcomingTasks: upcoming,
      deepWorkTasks: deepWork,
      recoveryTasks: recovery,
      completedTodayCount: completedTodayCount,
    );
  }

  Future<void> _calculateStats() async {
    final tasks = state.tasks;
    if (tasks.isEmpty || _disposed) return;

    try {
      final stats = await compute(_performStatsCalculation, tasks);
      if (!_disposed) {
        state = state.copyWith(statistics: stats);
      }
    } catch (e, stack) {
      if (!_disposed) {
        AppLogger.e('Stats calculation failed', e, stack);
      }
    }
  }

  static TaskStatistics _performStatsCalculation(List<Task> allTasks) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    // 1. Completion Rate & Velocity
    final recentCompleted = allTasks.where((t) =>
      t.isCompleted &&
      t.completionDate != null &&
      t.completionDate!.isAfter(thirtyDaysAgo)
    ).toList();

    final completionRate = allTasks.isEmpty ? 0.0 : recentCompleted.length / allTasks.length;

    // Map completions to days for velocity chart
    final Map<int, int> dailyCounts = {};
    for (var i = 0; i < 30; i++) {
      dailyCounts[i] = 0;
    }

    for (var task in recentCompleted) {
      final daysAgo = now.difference(task.completionDate!).inDays;
      if (daysAgo >= 0 && daysAgo < 30) {
        dailyCounts[29 - daysAgo] = (dailyCounts[29 - daysAgo] ?? 0) + 1;
      }
    }

    final velocitySpots = dailyCounts.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
        .toList();

    // 2. Category Distribution
    final Map<String, int> catCounts = {};
    for (var task in allTasks) {
      catCounts[task.category] = (catCounts[task.category] ?? 0) + 1;
    }
    final categoryDistribution = catCounts.map((k, v) => MapEntry(k, v / allTasks.length));

    // 3. Habit Strength (Exponential Decay Consistency)
    // PERFORMANCE OPTIMIZATION: Pre-calculate a Set of completion date keys (O(N))
    // to allow O(1) lookups in the 30-day loop, reducing total complexity from O(30*N) to O(N).
    final Set<String> completionDateKeys = allTasks
        .where((t) => t.isCompleted && t.completionDate != null)
        .map((t) => '${t.completionDate!.year}-${t.completionDate!.month}-${t.completionDate!.day}')
        .toSet();

    double strength = 0.0;
    for (var i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month}-${date.day}';

      if (completionDateKeys.contains(dateKey)) {
        strength += pow(0.9, i); // Recent days have more weight
      }
    }
    // Normalize strength (max possible is sum of 0.9^i for i=0 to 29 approx 10)
    strength = (strength / 10.0).clamp(0.0, 1.0);

    return TaskStatistics(
      habitStrength: strength,
      completionRate: completionRate,
      categoryDistribution: categoryDistribution,
      completionVelocitySpots: velocitySpots,
    );
  }

  void setSelectedTask(Task? task) {
    state = state.copyWith(selectedTask: task, clearSelectedTask: task == null);
  }

  Future<void> addTask({String title = '', DateTime? dueDate, TaskPriority? priority, String? category}) async {
    try {
      final String taskCategory = category ?? (state.selectedCategory == 'All' ? 'Personal' : state.selectedCategory);
      
      final updatedTasks = state.tasks.map((t) => t.copyWith(orderIndex: t.orderIndex + 1)).toList();

      final newTask = Task(
        id: _uuid.v4(),
        title: title,
        category: taskCategory,
        color: state.categoryColors[taskCategory] ?? Colors.blue,
        icon: state.categoryIcons[taskCategory] ?? Icons.task_alt,
        orderIndex: 0,
        dueDate: dueDate,
        priority: priority ?? TaskPriority.low,
      );
      
      state = state.copyWith(
        tasks: [newTask, ...updatedTasks],
        selectedTask: newTask,
      );
      _updateFilteredTasks();
      _calculateStats();
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
      _calculateStats();

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
      _calculateStats();
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
      _calculateStats();
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
      _calculateStats();
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
    _calculateStats();
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
    _calculateStats();
    await _repository.saveTasks(state.tasks);
  }

  Future<void> breakdownSelectedTasks() async {
    if (state.selectedTaskIds.isEmpty) return;

    state = state.copyWith(isAILoading: true);
    try {
      final selectedTasks = state.tasks.where((t) => state.selectedTaskIds.contains(t.id)).toList();
      final titles = selectedTasks.map((t) => t.title).toList();

      final roadmap = await _aiService.generateBatchRoadmap(titles);

      final updatedTasks = List<Task>.from(state.tasks);
      for (var i = 0; i < updatedTasks.length; i++) {
        final task = updatedTasks[i];
        if (state.selectedTaskIds.contains(task.id)) {
          final suggestedSubtasks = roadmap[task.title] ?? roadmap.values.firstWhere((v) => roadmap.keys.any((k) => k.contains(task.title)), orElse: () => []);

          if (suggestedSubtasks.isNotEmpty) {
            final newSubtasks = suggestedSubtasks.map((s) => SubTask(id: _uuid.v4(), title: s, isCompleted: false)).toList();
            updatedTasks[i] = task.copyWith(subtasks: [...task.subtasks, ...newSubtasks]);
          }
        }
      }

      state = state.copyWith(tasks: updatedTasks, isAILoading: false, selectedTaskIds: {});
      _updateFilteredTasks();
      _calculateStats();
      await _repository.saveTasks(state.tasks);
      unawaited(AppHaptics.success());
    } catch (e, stack) {
      _handleError(e, stack, 'Batch breakdown failed');
      state = state.copyWith(isAILoading: false);
    }
  }

  Future<void> clearAllTasks() async {
    try {
      final taskIds = state.tasks.map((t) => t.id).toList();
      state = state.copyWith(tasks: [], selectedTaskIds: {}, clearSelectedTask: true);
      _updateFilteredTasks();
      _calculateStats();
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
      _calculateStats();
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

// Derived State Providers (Performance Optimization)

final weeklyProductivityProvider = Provider<List<double>>((ref) {
  final tasks = ref.watch(taskProvider.select((s) => s.tasks));
  final today = DateTime.now();
  final last7Days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
  
  final List<double> data = List.filled(7, 0);
  
  for (var i = 0; i < 7; i++) {
    final date = last7Days[i];
    final completedOnDate = tasks.where((t) {
      if (!t.isCompleted || t.completionDate == null) return false;
      return t.completionDate!.year == date.year &&
             t.completionDate!.month == date.month &&
             t.completionDate!.day == date.day;
    }).length;
    data[i] = completedOnDate.toDouble();
  }
  return data;
});

class CategoryStats {
  CategoryStats({
    required this.activeCount,
    required this.totalCount,
    required this.progress,
  });
  final int activeCount;
  final int totalCount;
  final double progress;
}

final categoryStatsProvider = Provider.family<CategoryStats, String>((ref, category) {
  final tasks = ref.watch(taskProvider.select((s) => s.tasks));
  final categoryTasks = tasks.where((t) => t.category == category).toList();
  final activeCount = categoryTasks.where((t) => !t.isCompleted).length;
  final totalCount = categoryTasks.length;
  final progress = totalCount == 0 ? 0.0 : (totalCount - activeCount) / totalCount;
  
  return CategoryStats(
    activeCount: activeCount,
    totalCount: totalCount,
    progress: progress,
  );
});
