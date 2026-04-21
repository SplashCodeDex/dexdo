import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import 'dart:convert';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
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

  List<Task> get tasks {
    List<Task> filtered = _selectedCategory == 'All' 
        ? List.from(_tasks) 
        : _tasks.where((t) => t.category == _selectedCategory).toList();

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) => 
        t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        t.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Primary sort: starred, Secondary sort: orderIndex
    filtered.sort((a, b) {
      if (a.isStarred && !b.isStarred) return -1;
      if (!a.isStarred && b.isStarred) return 1;
      return a.orderIndex.compareTo(b.orderIndex);
    });
    return filtered;
  }

  List<Task> get activeTasks => tasks.where((t) => !t.isCompleted).toList();
  List<Task> get completedTasks => tasks.where((t) => t.isCompleted).toList();

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
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedTask(Task? task) {
    _selectedTask = task;
    notifyListeners();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Categories
    final List<String>? savedCategories = prefs.getStringList('categories');
    if (savedCategories != null) {
      _categories = savedCategories;
    }

    // Load Category Icons
    final String? iconsJson = prefs.getString('category_icons');
    if (iconsJson != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(iconsJson);
        decoded.forEach((key, value) {
          _categoryIcons[key] = IconData(value, fontFamily: 'MaterialIcons');
        });
      } catch (e) {
        debugPrint('Error loading category icons: $e');
      }
    }

    // Load Category Colors
    final String? colorsJson = prefs.getString('category_colors');
    if (colorsJson != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(colorsJson);
        decoded.forEach((key, value) {
          _categoryColors[key] = Color(value);
        });
      } catch (e) {
        debugPrint('Error loading category colors: $e');
      }
    }

    // Load Tasks
    final String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      try {
        final List<dynamic> decoded = json.decode(tasksJson);
        _tasks = decoded.map((item) => Task.fromMap(item)).toList();
      } catch (e) {
        debugPrint('Error loading tasks: $e');
        _tasks = [];
      }
    }
    notifyListeners();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_tasks.map((t) => t.toMap()).toList());
    await prefs.setString('tasks', encoded);
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('categories', _categories);

    final Map<String, int> iconMap = {};
    _categoryIcons.forEach((key, value) => iconMap[key] = value.codePoint);
    await prefs.setString('category_icons', json.encode(iconMap));

    final Map<String, int> colorMap = {};
    _categoryColors.forEach((key, value) => colorMap[key] = value.toARGB32());
    await prefs.setString('category_colors', json.encode(colorMap));
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
    notifyListeners();
    await _saveTasks();
  }

  Future<void> updateTask(Task task, String title, String description) async {
    task.title = title;
    task.description = description;
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
    notifyListeners();
    await _saveTasks();
  }

  Future<void> updateDueDate(Task task, DateTime? date) async {
    task.dueDate = date;
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
      } else if (oldIndex > headerIndexAfterRemove && newIndex <= headerIndexAfterRemove) {
        movedTask.isCompleted = false;
      }
    }

    uiItems.insert(newIndex, movedTask);

    // Re-assign orderIndex for tasks in this view
    int counter = 0;
    for (var item in uiItems) {
      if (item != null) {
        item.orderIndex = counter++;
      }
    }

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
    notifyListeners();
    await _saveTasks();
  }

  Future<void> markSelectedAsCompleted(bool completed) async {
    for (var task in _tasks) {
      if (_selectedTaskIds.contains(task.id)) {
        task.isCompleted = completed;
      }
    }
    _selectedTaskIds.clear();
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
    notifyListeners();
    await _saveTasks();
  }

  Future<void> toggleTask(Task task) async {
    task.isCompleted = !task.isCompleted;
    if (task.isCompleted) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
    notifyListeners();
    await _saveTasks();
  }

  Future<void> toggleStarred(Task task) async {
    task.isStarred = !task.isStarred;
    HapticFeedback.selectionClick();
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
    notifyListeners();
    await _saveTasks();
  }

  Future<void> clearCompleted() async {
    _tasks.removeWhere((t) => t.isCompleted);
    if (_selectedTask?.isCompleted == true) {
      _selectedTask = null;
    }
    notifyListeners();
    await _saveTasks();
  }

  bool get hasCompleted => _tasks.any((t) => t.isCompleted);
}
