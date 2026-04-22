import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';
import '../repositories/firebase_task_repository.dart';
import '../services/data_migration_service.dart';
import '../services/notification_service.dart';
import 'dart:convert';
import 'dart:async';

class TaskProvider with ChangeNotifier {
  final TaskRepository _repository;
  final NotificationService _notifications;

  Timer? _searchDebounce;

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

  TaskProvider({TaskRepository? repository, NotificationService? notifications}) 
      : _repository = repository ?? FirebaseTaskRepository(),
        _notifications = notifications ?? NotificationService() {
    _loadData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
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

    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _updateFilteredTasks();
      notifyListeners();
    });
  }

  void setSelectedTask(Task? task) {
    _selectedTask = task;
    notifyListeners();
  }

  Future<void> _loadData() async {
    await _repository.init();
    await _notifications.init();

    // Ensure migration from Local -> Firebase happens on first boot
    if (_repository is FirebaseTaskRepository) {
      await DataMigrationService.performMigrationIfNeeded(_repository);
    }

    await reloadFromStorage();
  }

  Future<void> reloadFromStorage() async {
    final savedCategories = await _repository.loadCategories();
    if (savedCategories.isNotEmpty) _categories = savedCategories;

    final savedIcons = await _repository.loadCategoryIcons();
    if (savedIcons.isNotEmpty) _categoryIcons.addAll(savedIcons);

    final savedColors = await _repository.loadCategoryColors();
    if (savedColors.isNotEmpty) _categoryColors.addAll(savedColors);

    _tasks = await _repository.loadTasks();

    _updateFilteredTasks();
    notifyListeners();
  }

  Future<void> _saveTasks() async {
    await _repository.saveTasks(_tasks);
    
    // Sync notifications when saving tasks
    for (var task in _tasks) {
      if (task.isCompleted) {
        _notifications.cancelTaskReminder(task.id);
      } else {
        _notifications.scheduleTaskReminder(task);
      }
    }
  }

  Future<void> _syncTask(Task task) async {
    await _repository.saveTask(task);
    if (task.isCompleted) {
      _notifications.cancelTaskReminder(task.id);
    } else {
      _notifications.scheduleTaskReminder(task);
    }
  }

  Future<void> _removeTask(Task task) async {
    await _repository.deleteTask(task.id);
    _notifications.cancelTaskReminder(task.id);
  }

  Future<void> _saveCategories() async {
    await _repository.saveCategories(_categories);
    await _repository.saveCategoryIcons(_categoryIcons);
    await _repository.saveCategoryColors(_categoryColors);
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

  Future<void> addTask({DateTime? dueDate}) async {
    String category = _selectedCategory == 'All' ? 'Personal' : _selectedCategory;
    
    for (var t in _tasks) {
      t.orderIndex++;
    }

    final newTask = Task(
      id: _uuid.v4(),
      title: '',
      category: category,
      color: _categoryColors[category] ?? Colors.blue,
      icon: _categoryIcons[category] ?? Icons.task_alt,
      attachmentCount: 0,
      subtasks: [],
      orderIndex: 0,
      dueDate: dueDate,
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
    await _syncTask(task);
  }

  Future<void> addSubtask(Task task, String title) async {
    task.subtasks.add(SubTask(id: _uuid.v4(), title: title));
    notifyListeners();
    await _syncTask(task);
  }

  Future<void> toggleSubtask(Task task, SubTask subtask) async {
    subtask.isCompleted = !subtask.isCompleted;
    if (subtask.isCompleted) {
      HapticFeedback.lightImpact();
    }
    notifyListeners();
    await _syncTask(task);
  }

  Future<void> deleteSubtask(Task task, SubTask subtask) async {
    task.subtasks.removeWhere((s) => s.id == subtask.id);
    notifyListeners();
    await _syncTask(task);
  }

  Future<void> updateCategory(Task task, String category) async {
    task.category = category;
    task.color = _categoryColors[category] ?? Colors.blue;
    task.icon = _categoryIcons[category] ?? Icons.task_alt;
    _updateFilteredTasks();
    notifyListeners();
    await _syncTask(task);
  }

  Future<void> updateDueDate(Task task, DateTime? date) async {
    task.dueDate = date;
    _updateFilteredTasks();
    notifyListeners();
    await _syncTask(task);
  }

  Future<void> updateRecurrence(Task task, String recurrence) async {
    task.recurrence = recurrence;
    notifyListeners();
    await _syncTask(task);
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

    // Global Re-indexing to preserve relative order
    final List<Task> allTasksSorted = List.from(_tasks);

    // Detect if crossing header
    int headerIndexAfterRemove = uiItems.indexOf(null);
    if (headerIndexAfterRemove != -1) {
      if (oldIndex <= headerIndexAfterRemove && newIndex > headerIndexAfterRemove) {
        movedTask.isCompleted = true;
        movedTask.completionDate = DateTime.now();
        List<Task> pendingClones = [];
        _handleRecurrence(movedTask, DateTime.now(), pendingClones);
        if (pendingClones.isNotEmpty) {
          allTasksSorted.addAll(pendingClones);
        }
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

    // Assign final indices and track modified ones
    final List<Task> affectedTasks = [];
    for (int i = 0; i < allTasksSorted.length; i++) {
      if (allTasksSorted[i].orderIndex != i) {
        allTasksSorted[i].orderIndex = i;
        affectedTasks.add(allTasksSorted[i]);
      }
    }
    _tasks = allTasksSorted;

    _updateFilteredTasks();
    notifyListeners();
    if (affectedTasks.isNotEmpty) {
      await _repository.batchUpdateTasks(affectedTasks);
    }
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
    final toDeleteIds = _selectedTaskIds.toList();
    _tasks.removeWhere((t) => _selectedTaskIds.contains(t.id));
    _selectedTaskIds.clear();
    _updateFilteredTasks();
    notifyListeners();
    if (toDeleteIds.isNotEmpty) {
      await _repository.batchDeleteTasks(toDeleteIds);
      for (var id in toDeleteIds) {
        _notifications.cancelTaskReminder(id);
      }
    }
  }

  Future<void> markSelectedAsCompleted(bool completed) async {
    final now = DateTime.now();
    List<Task> newRecurringTasks = [];

    for (var task in _tasks) {
      if (_selectedTaskIds.contains(task.id)) {
        if (!task.isCompleted && completed) {
           _handleRecurrence(task, now, newRecurringTasks);
        }
        task.isCompleted = completed;
        task.completionDate = completed ? now : null;
      }
    }
    if (newRecurringTasks.isNotEmpty) {
      _tasks.addAll(newRecurringTasks);
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

  void _handleRecurrence(Task task, DateTime now, List<Task> newTasksList) {
    if (task.recurrence != null && task.recurrence != 'none') {
      bool exists = _tasks.any((t) => t.title == task.title && !t.isCompleted && t.dueDate != null && t.dueDate!.isAfter(now));
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

      // Clone the task
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
        orderIndex: task.orderIndex - 1, // Keep it near the top
        subtasks: task.subtasks.map((s) => SubTask(id: _uuid.v4(), title: s.title, isCompleted: false)).toList()
      );
      newTasksList.add(clone);
    }
  }

  Future<void> toggleTaskCompletion(Task task) async {
    bool isMarkingDone = !task.isCompleted;
    task.isCompleted = isMarkingDone;
    task.completionDate = isMarkingDone ? DateTime.now() : null;
    
    if (isMarkingDone) {
      HapticFeedback.heavyImpact();
      List<Task> pendingClones = [];
      _handleRecurrence(task, DateTime.now(), pendingClones);
      if (pendingClones.isNotEmpty) {
        _tasks.addAll(pendingClones);
        // Deselect if we are completing it and looking at it
        if (_selectedTask?.id == task.id) {
           _selectedTask = pendingClones.first;
        }
      }
    } else {
      HapticFeedback.mediumImpact();
    }
    
    _updateFilteredTasks();
    notifyListeners();
    await _syncTask(task);
    // Since we added clones to _tasks, we need to save the new ones too
    if (isMarkingDone) {
      final clones = _tasks.where((t) => t.isCompleted == false && t.title == task.title && t.dueDate != null && t.dueDate!.isAfter(DateTime.now().subtract(const Duration(days: 1)))).toList();
      for(var clone in clones) {
        if(clone.id != task.id) {
           await _syncTask(clone);
        }
      }
    }
  }

  Future<void> toggleStarred(Task task) async {
    task.isStarred = !task.isStarred;
    HapticFeedback.selectionClick();
    _updateFilteredTasks();
    notifyListeners();
    await _syncTask(task);
  }

  Future<void> deleteTask(Task task) async {
    _tasks.removeWhere((t) => t.id == task.id);
    _selectedTaskIds.remove(task.id);
    if (_selectedTask?.id == task.id) {
      _selectedTask = null;
    }
    HapticFeedback.vibrate();
    await _removeTask(task);
    _updateFilteredTasks();
    notifyListeners();
  }

  Future<void> duplicateTask(Task task) async {
    for (var t in _tasks) {
      t.orderIndex++;
    }

    final newTask = task.copyWith(
      id: _uuid.v4(),
      title: task.title.isEmpty ? 'Copy of New Task' : 'Copy of ${task.title}',
      subtasks: task.subtasks.map((s) => SubTask(
        id: _uuid.v4(), 
        title: s.title, 
        isCompleted: s.isCompleted
      )).toList(),
      orderIndex: 0,
    );
    _tasks.insert(0, newTask);
    HapticFeedback.mediumImpact();
    _updateFilteredTasks();
    notifyListeners();
    await _saveTasks();
  }

  Future<void> clearCompleted() async {
    final toDelete = _tasks.where((t) => t.isCompleted).toList();
    final toDeleteIds = toDelete.map((t) => t.id).toList();
    _tasks.removeWhere((t) => t.isCompleted);
    if (_selectedTask?.isCompleted == true) {
      _selectedTask = null;
    }
    _updateFilteredTasks();
    notifyListeners();
    if (toDeleteIds.isNotEmpty) {
      await _repository.batchDeleteTasks(toDeleteIds);
      for (var id in toDeleteIds) {
        _notifications.cancelTaskReminder(id);
      }
    }
  }

  Future<void> clearAllTasks() async {
    final toDeleteIds = _tasks.map((t) => t.id).toList();
    _tasks.clear();
    _selectedTask = null;
    _selectedTaskIds.clear();
    _updateFilteredTasks();
    notifyListeners();
    if (toDeleteIds.isNotEmpty) {
      await _repository.batchDeleteTasks(toDeleteIds);
      for (var id in toDeleteIds) {
         _notifications.cancelTaskReminder(id);
      }
    }
  }

  bool get hasCompleted => _tasks.any((t) => t.isCompleted);

  Future<String> exportTasksToJson() async {
    final String encoded = json.encode(_tasks.map((t) => t.toJson()).toList());
    return encoded;
  }
}
