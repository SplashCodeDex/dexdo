import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dexdo/models/task.dart';

void main() {
  group('Task Model Tests', () {
    test('Task JSON initialization creates a valid Task', () {
      final json = {
        'id': '1234',
        'title': 'Test Title',
        'description': 'Test Description',
        'isCompleted': true,
        'category': 'Work',
        'icon': Icons.work.codePoint,
        'color': Colors.red.toARGB32(),
        'orderIndex': 5,
        'isStarred': false,
        'subtasks': []
      };

      final task = Task.fromJson(json);

      expect(task.id, '1234');
      expect(task.title, 'Test Title');
      expect(task.description, 'Test Description');
      expect(task.isCompleted, true);
      expect(task.category, 'Work');
      expect(task.orderIndex, 5);
      expect(task.isStarred, false);
      expect(task.subtasks, isEmpty);
    });

    test('Task serialization to JSON produces valid Map', () {
      final task = Task(
        id: '1234',
        title: 'Test Title',
        description: 'Test Description',
        category: 'Work',
        color: Colors.red,
        icon: Icons.work,
        attachmentCount: 0,
        subtasks: [],
        orderIndex: 2,
        isCompleted: true,
      );

      final json = task.toJson();

      expect(json['id'], '1234');
      expect(json['title'], 'Test Title');
      expect(json['isCompleted'], true);
      expect(json['category'], 'Work');
      expect(json['orderIndex'], 2);
    });

    test('Task.copyWith creates a new instance with updated values', () {
      final task = Task(
        id: '1234',
        title: 'Title',
        category: 'Work',
        color: Colors.red,
        icon: Icons.work,
        attachmentCount: 0,
        subtasks: [],
        orderIndex: 1,
      );

      final updatedTask = task.copyWith(
        title: 'New Title',
        isCompleted: true,
      );

      expect(updatedTask.id, '1234'); // ID stays the same
      expect(updatedTask.title, 'New Title'); // Title updated
      expect(updatedTask.isCompleted, true); // Status updated
      expect(updatedTask.category, 'Work'); // Status unchanged
    });
  });
}
