import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';

class TaskState {
  final List<Task> tasks;
  final List<Task> filteredTasks;
  final Task? selectedTask;
  final String selectedCategory;
  final String searchQuery;
  final Set<String> selectedTaskIds;
  final List<String> categories;
  final Map<String, IconData> categoryIcons;
  final Map<String, Color> categoryColors;
  final bool isLoading;

  TaskState({
    this.tasks = const [],
    this.filteredTasks = const [],
    this.selectedTask,
    this.selectedCategory = 'All',
    this.searchQuery = '',
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
  });

  List<Task> get activeTasks => filteredTasks.where((t) => !t.isCompleted).toList();
  List<Task> get completedTasks => filteredTasks.where((t) => t.isCompleted).toList();
  bool get isSelectionMode => selectedTaskIds.isNotEmpty;

  TaskState copyWith({
    List<Task>? tasks,
    List<Task>? filteredTasks,
    Task? selectedTask,
    bool clearSelectedTask = false,
    String? selectedCategory,
    String? searchQuery,
    Set<String>? selectedTaskIds,
    List<String>? categories,
    Map<String, IconData>? categoryIcons,
    Map<String, Color>? categoryColors,
    bool? isLoading,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      selectedTask: clearSelectedTask ? null : (selectedTask ?? this.selectedTask),
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTaskIds: selectedTaskIds ?? this.selectedTaskIds,
      categories: categories ?? this.categories,
      categoryIcons: categoryIcons ?? this.categoryIcons,
      categoryColors: categoryColors ?? this.categoryColors,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
