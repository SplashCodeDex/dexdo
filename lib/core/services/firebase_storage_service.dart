import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/task.dart';
import 'storage_service.dart';

class FirebaseStorageService implements StorageService {
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

      return snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          data['id'] = doc.id; // Force ID to match the document key
          return Task.fromJson(data);
        } catch (e) {
          debugPrint('Error parsing firestore task: $e');
          return null;
        }
      }).whereType<Task>().toList();
    } catch (e) {
      debugPrint('Firestore loadTasks Error: $e');
      return [];
    }
  }

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    if (_auth.currentUser == null) return;

    final batch = _db.batch();
    final tasksRef = _db.collection('users').doc(_userId).collection('tasks');

    // In a true production app, we would only sync diffs!
    // For this migration, we'll batch write the current state.
    for (var task in tasks) {
      batch.set(tasksRef.doc(task.id), task.toJson());
    }

    try {
      await batch.commit();
    } catch (e) {
      debugPrint('Firestore saveTasks Error: $e');
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
