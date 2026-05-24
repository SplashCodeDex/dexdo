import 'dart:async';
import 'package:dexdo/core/services/notification_service.dart';
import 'package:dexdo/features/auth/domain/repositories/auth_repository.dart';
import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:dexdo/features/tasks/domain/repositories/task_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAuthRepository extends Fake implements AuthRepository {
  User? _currentUser;
  final _authStateController = StreamController<User?>.broadcast();

  @override
  User? get currentUser => _currentUser;

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  @override
  bool get isAnonymous => _currentUser?.isAnonymous ?? true;

  void simulateUser(User? user) {
    _currentUser = user;
    _authStateController.add(user);
  }

  @override
  Future<void> signOut() async {
    simulateUser(null);
  }

  @override
  Future<UserCredential?> signInAnonymously() async {
    return null; // Mock as needed
  }
}

class MockUser extends Fake implements User {
  MockUser({this.uid = 'test-uid', this.isAnonymous = false, this.email = 'test@example.com'});
  @override
  final String uid;
  @override
  final bool isAnonymous;
  @override
  final String? email;
}

class MockNotificationService extends Fake implements NotificationService {
  @override
  Future<void> init() async {}
  
  @override
  Future<void> scheduleTaskReminder(Task task) async {}
  
  @override
  Future<void> cancelTaskReminder(String taskId) async {}
}

class MockTaskRepository extends Fake implements TaskRepository {
  List<Task> tasks = [];
  List<String> categories = ['Personal', 'Work'];

  @override
  Future<void> init() async {}

  @override
  Future<List<Task>> loadTasks() async => tasks;

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    this.tasks = List.from(tasks);
  }

  @override
  Future<void> saveTask(Task task) async {
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
    } else {
      tasks.add(task);
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    tasks.removeWhere((t) => t.id == taskId);
  }

  @override
  Future<List<String>> loadCategories() async => categories;

  @override
  Future<void> saveCategories(List<String> categories) async {
    this.categories = categories;
  }

  @override
  Future<Map<String, IconData>> loadCategoryIcons() async => {};
  
  @override
  Future<Map<String, Color>> loadCategoryColors() async => {};
}
