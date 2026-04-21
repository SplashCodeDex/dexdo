import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/task.dart';
import 'task_repository.dart';

class FirebaseTaskRepository implements TaskRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? 'unauthenticated';

  @override
  Future<void> init() async {
    // Automatically auth anonymously if no user is present
    if (_auth.currentUser == null) {
      try {
        await _auth.signInAnonymously();
      } catch (e) {
        debugPrint('Failed to sign in anonymously: $e');
      }
    }
  }

  @override
  Future<List<Task>> loadTasks() async {
    if (_auth.currentUser == null) return [];
    
    try {
      final snapshot = await _db
          .collection('users')
          .doc(_userId)
          .collection('tasks')
          .get();

      final List<Task> activeTasks = [];
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      var archiveBatch = _db.batch();
      int archiveCount = 0;
      final archiveRef = _db.collection('users').doc(_userId).collection('archived_tasks');
      final tasksRef = _db.collection('users').doc(_userId).collection('tasks');

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id; // Force ID to match the document key
          final task = Task.fromJson(data);

          // Auto-archiving logic for tasks older than 30 days
          if (task.isCompleted && task.completionDate != null && task.completionDate!.isBefore(thirtyDaysAgo)) {
             archiveBatch.set(archiveRef.doc(task.id), task.toJson());
             archiveBatch.delete(tasksRef.doc(task.id));
             archiveCount++;
             
             if (archiveCount >= 490) { // Firestore batch limit is 500
               await archiveBatch.commit();
               archiveBatch = _db.batch();
               archiveCount = 0;
             }
          } else {
             activeTasks.add(task);
          }
        } catch (e) {
          debugPrint('Error parsing firestore task: $e');
        }
      }

      // Commit any remaining archives
      if (archiveCount > 0) {
         try {
           await archiveBatch.commit();
         } catch (e) {
           debugPrint('Error committing archive batch: $e');
         }
      }

      return activeTasks;
    } catch (e) {
      debugPrint('Firestore loadTasks Error: $e');
      return [];
    }
  }

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    if (_auth.currentUser == null) return;

    var batch = _db.batch();
    final tasksRef = _db.collection('users').doc(_userId).collection('tasks');

    var count = 0;
    for (var task in tasks) {
      batch.set(tasksRef.doc(task.id), task.toJson());
      count++;
      if (count >= 490) {
        try {
          await batch.commit();
          batch = _db.batch();
          count = 0;
        } catch (e) {
          debugPrint('Firestore saveTasks batch chunk Error: $e');
        }
      }
    }

    try {
      if (count > 0) await batch.commit();
    } catch (e) {
      debugPrint('Firestore saveTasks Error: $e');
    }
  }

  @override
  Future<void> saveTask(Task task) async {
    if (_auth.currentUser == null) return;
    try {
      await _db.collection('users').doc(_userId).collection('tasks').doc(task.id).set(task.toJson());
    } catch (e) {
      debugPrint('Firestore saveTask Error: $e');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    if (_auth.currentUser == null) return;
    try {
      await _db.collection('users').doc(_userId).collection('tasks').doc(taskId).delete();
    } catch (e) {
      debugPrint('Firestore deleteTask Error: $e');
    }
  }

  @override
  Future<List<String>> loadCategories() async {
    if (_auth.currentUser == null) return [];
    try {
      final doc = await _db.collection('users').doc(_userId).collection('settings').doc('categories').get();
      if (doc.exists) {
        return List<String>.from(doc.data()?['list'] ?? []);
      }
    } catch (e) {
      debugPrint('Firestore loadCategories Error: $e');
    }
    return [];
  }

  @override
  Future<void> saveCategories(List<String> categories) async {
    if (_auth.currentUser == null) return;
    await _db.collection('users').doc(_userId).collection('settings').doc('categories').set({
      'list': categories,
    });
  }

  @override
  Future<Map<String, IconData>> loadCategoryIcons() async {
    if (_auth.currentUser == null) return {};
    try {
      final doc = await _db.collection('users').doc(_userId).collection('settings').doc('categoryIcons').get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        final Map<String, IconData> result = {};
        data.forEach((key, value) {
          result[key] = IconData(value as int, fontFamily: 'MaterialIcons');
        });
        return result;
      }
    } catch (e) {
      debugPrint('Firestore loadCategoryIcons Error: $e');
    }
    return {};
  }

  @override
  Future<void> saveCategoryIcons(Map<String, IconData> icons) async {
    if (_auth.currentUser == null) return;
    final Map<String, int> iconMap = {};
    icons.forEach((key, value) => iconMap[key] = value.codePoint);
    await _db.collection('users').doc(_userId).collection('settings').doc('categoryIcons').set(iconMap);
  }

  @override
  Future<Map<String, Color>> loadCategoryColors() async {
    if (_auth.currentUser == null) return {};
    try {
      final doc = await _db.collection('users').doc(_userId).collection('settings').doc('categoryColors').get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        final Map<String, Color> result = {};
        data.forEach((key, value) {
          result[key] = Color(value as int);
        });
        return result;
      }
    } catch (e) {
      debugPrint('Firestore loadCategoryColors Error: $e');
    }
    return {};
  }

  @override
  Future<void> saveCategoryColors(Map<String, Color> colors) async {
    if (_auth.currentUser == null) return;
    final Map<String, int> colorMap = {};
    colors.forEach((key, value) => colorMap[key] = value.toARGB32());
    await _db.collection('users').doc(_userId).collection('settings').doc('categoryColors').set(colorMap);
  }
}
