import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../services/firebase_storage_service.dart';
import '../services/data_migration_service.dart';
import '../services/notification_service.dart';
import 'dart:convert';

class TaskProvider with ChangeNotifier {
  final StorageService _storage = FirebaseStorageService();
  final NotificationService _notifications = NotificationService();

  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  Task? _selectedTask;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final Set<String> _selectedTaskIds = {};
  final _uuid = const Uuid();

  List<String> _categories = ['All', 'Work', 'Finance', 'Sport', 'Home', 'Personal'];

  final Map<String, IconData> _categoryIcons = {
    'Work': Icons.work_rounded,
    'Finance': Icons.account_balance_wallet_rounded,
    'Sport': Icons.fitness_center_rounded,
    'Home': Icons.home_rounded,
    'Personal': Icons.person_rounded,
    'All': Icons.list_rounded,
  };

  final Map<String, Color> _categoryColors = {
    'Work': const Color(0xFFF44336), // Red
    'Finance': const Color(0xFF4CAF50), // Green
    'Sport': const Color(0xFF9C27B0), // Purple
    'Home': const Color(0xFFFF9800), // Orange
    'Personal': const Color(0xFFFFC107), // Amber
    'All': const Color(0xFF2196F3), // Blue
  };

  Map<String, IconData> get categoryIcons => _categoryIcons;
  Map<String, Color> get categoryColors => _categoryColors;

  List<Task> get allTasks => _tasks;

  List<Task> get tasks => _filteredTasks;

  void _updateFilteredTasks() {
    List<Task> filtered = _selectedCategory == 'All' 
        ? List.from(_tasks) 
        : _tasks.where((t) => t.category == _selectedCategory).toList();

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((t) => 
        t.title.toLowerCase().contains(query) ||
        t.description.toLowerCase().contains(query)
      ).toList();
    }
    
    // Primary sort: starred, Secondary sort: orderIndex, Tertiary sort: id for stability
    filtered.sort((a, b) {
      if (a.isStarred && !b.isStarred) return -1;
      if (!a.isStarred && b.isStarred) return 1;
      int res = a.orderIndex.compareTo(b.orderIndex);
      if (res != 0) return res;
      return a.id.compareTo(b.id);
    });
    _filteredTasks = filtered;
  }

  List<Task> get activeTasks => _filteredTasks.where((t) => !t.isCompleted).toList();
  List<Task> get completedTasks => _filteredTasks.where((t) => t.isCompleted).toList();

  Task? get selectedTask => _selectedTask;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  List<String> get categories => _categories;
  Set<String> get selectedTaskIds => _selectedTaskIds;
  bool get isSelectionMode => _selectedTaskIds.isNotEmpty;

  TaskProvider() {
    _loadData();
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _updateFilteredTasks();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _updateFilteredTasks();
    notifyListeners();
  }

  void setSelectedTask(Task? task) {
    _selectedTask = task;
    notifyListeners();
  }

  Future<void> _loadData() async {
    await _storage.init();
    await _notifications.init();

    // Ensure migration from Local -> Firebase happens on first boot
    if (_storage is FirebaseStorageService) {
      await DataMigrationService.performMigrationIfNeeded(_storage as FirebaseStorageService);
    }

    final savedCategories = await _storage.loadCategories();
    if (savedCategories.isNotEmpty) _categories = savedCategories;

    final savedIcons = await _storage.loadCategoryIcons();
    if (savedIcons.isNotEmpty) _categoryIcons.addAll(savedIcons);

    final savedColors = await _storage.loadCategoryColors();
    if (savedColors.isNotEmpty) _categoryColors.addAll(savedColors);

    _tasks = await _storage.loadTasks();

    _updateFilteredTasks();
    notifyListeners();
  }

  Future<void> _saveTasks() async {
    await _storage.saveTasks(_tasks);
    
    // Sync notifications when saving tasks
    for (var task in _tasks) {
      if (task.isCompleted) {
        _notifications.cancelTaskReminder(task.id);
      } else {
        _notifications.scheduleTaskReminder(task);
      }
    }
  }

  Future<void> _saveCategories() async {
    await _storage.saveCategories(_categories);
    await _storage.saveCategoryIcons(_categoryIcons);
    await _storage.saveCategoryColors(_categoryColors);
  }

  Future<void> addCategory(String name, IconData icon, Color color) async {
    if (!_categories.contains(name)) {
      _categories.add(name);
      _categoryIcons[name] = icon;
      _categoryColors[name] = color;
      notifyListeners();
      await _saveCategories();
    }
  }

  Future<void> editCategory(String oldName, String newName, IconData icon, Color color) async {
    if (newName.isEmpty) return;
    if (newName != oldName && _categories.contains(newName)) return;

    final index = _categories.indexOf(oldName);
    if (index != -1) {
      _categories[index] = newName;
      
      // Update mappings
      _categoryIcons.remove(oldName);
      _categoryColors.remove(oldName);
      _categoryIcons[newName] = icon;
      _categoryColors[newName] = color;

      // Update all tasks with this category
      for (var task in _tasks) {
        if (task.category == oldName) {
          task.category = newName;
          task.color = color;
          task.icon = icon;
        }
      }

      if (_selectedCategory == oldName) {
        _selectedCategory = newName;
      }

      _updateFilteredTasks();
      notifyListeners();
      await _saveCategories();
      await _saveTasks();
    }
  }

  Future<void> deleteCategory(String name) async {
    if (name == 'All' || name == 'Personal') return; // Protect default categories

    _categories.remove(name);
    _categoryIcons.remove(name);
    _categoryColors.remove(name);

    // Reset tasks in this category to 'Personal'
    for (var task in _tasks) {
      if (task.category == name) {
        task.category = 'Personal';
        task.color = _categoryColors['Personal']!;
        task.icon = _categoryIcons['Personal']!;
      }
    }

    if (_selectedCategory == name) {
      _selectedCategory = 'All';
    }

    _updateFilteredTasks();
    notifyListeners();
    await _saveCategories();
    await _saveTasks();
  }

  Future<void> addTask() async {
    String category = _selectedCategory == 'All' ? 'Personal' : _selectedCategory;
    
    int minOrder = 0;
    if (_tasks.isNotEmpty) {
      minOrder = _tasks.map((t) => t.orderIndex).reduce((a, b) => a < b ? a : b);
    }

    final newTask = Task(
      id: _uuid.v4(),
      title: '',
      category: category,
      color: _categoryColors[category] ?? Colors.blue,
      icon: _categoryIcons[category] ?? Icons.task_alt,
      attachmentCount: 0,
      subtasks: [],
      orderIndex: minOrder - 1,
    );
    _tasks.insert(0, newTask);
    _selectedTask = newTask;
    _updateFilteredTasks();
    notifyListeners();
    await _saveTasks();
  }

  Future<void> updateTask(Task task, String title, String description) async {
    task.title = title;
    task.description = description;
    _updateFilteredTasks();
    notifyListeners();
    await _saveTasks();
  }

  Future<void> addSubtask(Task task, String title) async {
    task.subtasks.add(SubTask(id: _uuid.v4(), title: title));
    notifyListeners();
    await _saveTasks();
  }

  Future<void> toggleSubtask(Task task, SubTask subtask) async {
    subtask.isCompleted = !subtask.isCompleted;
    if (subtask.isCompleted) {
      HapticFeedback.lightImpact();
    }
    notifyListeners();
    await _saveTasks();
  }

  Future<void> deleteSubtask(Task task, SubTask subtask) async {
    task.subtasks.removeWhere((s) => s.id == subtask.id);
    notifyListeners();
    await _saveTasks();
  }

  Future<void> updateCategory(Task task, String category) async {
    task.category = category;
    task.color = _categoryColors[category] ?? Colors.blue;
    task.icon = _categoryIcons[category] ?? Icons.task_alt;
    _updateFilteredTasks();
    notifyListeners();
    await _saveTasks();
  }

  Future<void> updateDueDate(Task task, DateTime? date) async {
    task.dueDate = date;
    _updateFilteredTasks();
    notifyListeners();
    await _saveTasks();
  }

  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    final active = activeTasks;
    final completed = completedTasks;
    
    List<Task?> uiItems = [];
    uiItems.addAll(active);
    if (completed.isNotEmpty) {
      uiItems.add(null); // Header placeholder
      uiItems.addAll(completed);
    }

    if (oldIndex < 0 || oldIndex >= uiItems.length) return;
    Task? movedTask = uiItems[oldIndex];
    if (movedTask == null) return; // Cannot move header

    uiItems.removeAt(oldIndex);
    if (newIndex > oldIndex) newIndex--;
    
    if (newIndex < 0) newIndex = 0;
    if (newIndex > uiItems.length) newIndex = uiItems.length;

    // Detect if crossing header
    int headerIndexAfterRemove = uiItems.indexOf(null);
    if (headerIndexAfterRemove != -1) {
      if (oldIndex <= headerIndexAfterRemove && newIndex > headerIndexAfterRemove) {
        movedTask.isCompleted = true;
        movedTask.completionDate = DateTime.now();
      } else if (oldIndex > headerIndexAfterRemove && newIndex <= headerIndexAfterRemove) {
        movedTask.isCompleted = false;
        movedTask.completionDate = null;
      }
    }

    uiItems.insert(newIndex, movedTask);

    // After reorder, we handle the starred status if moving between regions
    final newlyOrderedVisible = uiItems.whereType<Task>().toList();
    final idxInVisible = newlyOrderedVisible.indexOf(movedTask);
    
    // Simple heuristic: if moved to a position where neighbors have a different starred status,
    // adopt that status to avoid jumping back due to the sort.
    if (newlyOrderedVisible.length > 1) {
      if (idxInVisible > 0) {
        movedTask.isStarred = newlyOrderedVisible[idxInVisible - 1].isStarred;
      } else {
        movedTask.isStarred = newlyOrderedVisible[1].isStarred;
      }
    }

    // Global Re-indexing to preserve relative order
    final List<Task> allTasksSorted = List.from(_tasks);
    
    // Sort logic that respects the NEW order of visible tasks but keeps non-visible ones relatively placed
    allTasksSorted.sort((a, b) {
      if (a.isStarred && !b.isStarred) return -1;
      if (!a.isStarred && b.isStarred) return 1;
      
      int aIdx = newlyOrderedVisible.indexOf(a);
      int bIdx = newlyOrderedVisible.indexOf(b);
      
      if (aIdx != -1 && bIdx != -1) return aIdx.compareTo(bIdx);
      if (aIdx != -1) return -1; 
      if (bIdx != -1) return 1;
      
      return a.orderIndex.compareTo(b.orderIndex);
    });

    // Assign final indices and update global list
    for (int i = 0; i < allTasksSorted.length; i++) {
      allTasksSorted[i].orderIndex = i;
    }
    _tasks = allTasksSorted;

    _updateFilteredTasks();
    notifyListeners();
    await _saveTasks();
  }

  void toggleTaskSelection(String taskId) {
    if (_selectedTaskIds.contains(taskId)) {
      _selectedTaskIds.remove(taskId);
    } else {
      _selectedTaskIds.add(taskId);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedTaskIds.clear();
    notifyListeners();
  }

  Future<void> deleteSelectedTasks() async {
    if (_selectedTask != null && _selectedTaskIds.contains(_selectedTask!.id)) {
      _selectedTask = null;
    }
    _tasks.removeWhere((t) => _selectedTaskIds.contains(t.id));
    _selectedTaskIds.clear();
    _updateFilteredTasks();
    notifyListeners();
    await _saveTasks();
  }

  Future<void> markSelectedAsCompleted(bool completed) async {
    final now = DateTime.now();
    for (var task in _tasks) {
      if (_selectedTaskIds.contains(task.id)) {
        task.isCompleted = completed;
        task.completionDate = completed ? now : null;
      }
    }
    _selectedTaskIds.clear();
    _updateFilteredTasks();
    notifyListeners();
    await _saveTasks();
  }

  Future<void> moveSelectedToCategory(String category) async {
    for (var task in _tasks) {
      if (_selectedTaskIds.contains(task.id)) {
        task.category = category;
        task.color = _categoryColors[category] ?? Colors.blue;
        task.icon = _categoryIcons[category] ?? Icons.task_alt;
      }
    }
    _selectedTaskIds.clear();
    _updateFilteredTasks();
    notifyListeners();
    await _saveTasks();
  }

  Future<void> toggleTask(Task task) async {
    task.isCompleted = !task.isCompleted;
    task.completionDate = task.isCompleted ? DateTime.now() : null;
    if (task.isCompleted) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
    _updateFilteredTasks();
    notifyListeners();
    await _saveTasks();
  }

  Future<void> toggleStarred(Task task) async {
    task.isStarred = !task.isStarred;
    HapticFeedback.selectionClick();
    _updateFilteredTasks();
    notifyListeners();
    await _saveTasks();
  }

  Future<void> deleteTask(Task task) async {
    _tasks.removeWhere((t) => t.id == task.id);
    _selectedTaskIds.remove(task.id);
    if (_selectedTask?.id == task.id) {
      _selectedTask = null;
    }
    HapticFeedback.vibrate();
    _updateFilteredTasks();
    notifyListeners();
    await _saveTasks();
  }

  Future<void> duplicateTask(Task task) async {
    int minOrder = 0;
    if (_tasks.isNotEmpty) {
      minOrder = _tasks.map((t) => t.orderIndex).reduce((a, b) => a < b ? a : b);
    }

    final newTask = task.copyWith(
      id: _uuid.v4(),
      title: task.title.isEmpty ? 'Copy of New Task' : 'Copy of ${task.title}',
      subtasks: task.subtasks.map((s) => SubTask(
        id: _uuid.v4(), 
        title: s.title, 
        isCompleted: s.isCompleted
      )).toList(),
      orderIndex: minOrder - 1,
    );
    _tasks.insert(0, newTask);
    HapticFeedback.mediumImpact();
    _updateFilteredTasks();
    notifyListeners();
    await _saveTasks();
  }

  Future<void> clearCompleted() async {
    _tasks.removeWhere((t) => t.isCompleted);
    if (_selectedTask?.isCompleted == true) {
      _selectedTask = null;
    }
    _updateFilteredTasks();
    notifyListeners();
    await _saveTasks();
  }

  Future<void> clearAllTasks() async {
    _tasks.clear();
    _selectedTask = null;
    _selectedTaskIds.clear();
    _updateFilteredTasks();
    notifyListeners();
    await _saveTasks();
  }

  bool get hasCompleted => _tasks.any((t) => t.isCompleted);

  Future<String> exportTasksToJson() async {
    final String encoded = json.encode(_tasks.map((t) => t.toJson()).toList());
    return encoded;
  }
}
