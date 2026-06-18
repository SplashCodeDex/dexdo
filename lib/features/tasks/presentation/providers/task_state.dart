import 'package:dexdo/core/error/failures.dart';
import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:dexdo/features/tasks/domain/entities/task_statistics.dart';
import 'package:flutter/material.dart';

enum TaskSortOption {
  dueDate,
  priority,
  title,
  orderIndex,
}

class TaskState {

  TaskState({
    this.tasks = const [],
    this.filteredTasks = const [],
    this.activeTasks = const [],
    this.completedTasks = const [],
    this.todayTasks = const [],
    this.upcomingTasks = const [],
    this.deepWorkTasks = const [],
    this.recoveryTasks = const [],
    this.completedTodayCount = 0,
    this.selectedTask,
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.sortOption = TaskSortOption.orderIndex,
    this.sortAscending = true,
    this.selectedTaskIds = const {},
    this.categories = const ['All', 'Work', 'Finance', 'Sport', 'Home', 'Personal'],
    this.categoryIcons = const {
      'Work': Icons.work_rounded,
      'Finance': Icons.account_balance_wallet_rounded,
      'Sport': Icons.fitness_center_rounded,
      'Home': Icons.home_rounded,
      'Personal': Icons.person_rounded,
      'All': Icons.list_rounded,
    },
    this.categoryColors = const {
      'Work': Color(0xFFF44336),
      'Finance': Color(0xFF4CAF50),
      'Sport': Color(0xFF9C27B0),
      'Home': Color(0xFFFF9800),
      'Personal': Color(0xFFFFC107),
      'All': Color(0xFF2196F3),
    },
    this.isLoading = false,
    this.isAILoading = false,
    TaskStatistics? statistics,
    this.error,
  }) : statistics = statistics ?? const TaskStatistics();
  final List<Task> tasks;
  final List<Task> filteredTasks;
  final List<Task> activeTasks;
  final List<Task> completedTasks;
  final List<Task> todayTasks;
  final List<Task> upcomingTasks;
  final List<Task> deepWorkTasks;
  final List<Task> recoveryTasks;
  final int completedTodayCount;
  final Task? selectedTask;
  final String selectedCategory;
  final String searchQuery;
  final TaskSortOption sortOption;
  final bool sortAscending;
  final Set<String> selectedTaskIds;
  final List<String> categories;
  final Map<String, IconData> categoryIcons;
  final Map<String, Color> categoryColors;
  final bool isLoading;
  final bool isAILoading;
  final TaskStatistics statistics;
  final Failure? error;

  List<Task> get allTasks => tasks;
  bool get hasCompleted => tasks.any((t) => t.isCompleted);
  bool get isSelectionMode => selectedTaskIds.isNotEmpty;

  TaskState copyWith({
    List<Task>? tasks,
    List<Task>? filteredTasks,
    List<Task>? activeTasks,
    List<Task>? completedTasks,
    List<Task>? todayTasks,
    List<Task>? upcomingTasks,
    List<Task>? deepWorkTasks,
    List<Task>? recoveryTasks,
    int? completedTodayCount,
    Task? selectedTask,
    bool clearSelectedTask = false,
    String? selectedCategory,
    String? searchQuery,
    TaskSortOption? sortOption,
    bool? sortAscending,
    Set<String>? selectedTaskIds,
    List<String>? categories,
    Map<String, IconData>? categoryIcons,
    Map<String, Color>? categoryColors,
    bool? isLoading,
    bool? isAILoading,
    TaskStatistics? statistics,
    Failure? error,
    bool clearError = false,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      activeTasks: activeTasks ?? this.activeTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      todayTasks: todayTasks ?? this.todayTasks,
      upcomingTasks: upcomingTasks ?? this.upcomingTasks,
      deepWorkTasks: deepWorkTasks ?? this.deepWorkTasks,
      recoveryTasks: recoveryTasks ?? this.recoveryTasks,
      completedTodayCount: completedTodayCount ?? this.completedTodayCount,
      selectedTask: clearSelectedTask ? null : (selectedTask ?? this.selectedTask),
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      sortAscending: sortAscending ?? this.sortAscending,
      selectedTaskIds: selectedTaskIds ?? this.selectedTaskIds,
      categories: categories ?? this.categories,
      categoryIcons: categoryIcons ?? this.categoryIcons,
      categoryColors: categoryColors ?? this.categoryColors,
      isLoading: isLoading ?? this.isLoading,
      isAILoading: isAILoading ?? this.isAILoading,
      statistics: statistics ?? this.statistics,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
