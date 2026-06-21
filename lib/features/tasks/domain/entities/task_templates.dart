import 'package:flutter/material.dart';

class TaskTemplate {
  const TaskTemplate({
    required this.id,
    required this.name,
    required this.icon,
    required this.subtaskTitles,
    required this.category,
  });

  final String id;
  final String name;
  final IconData icon;
  final List<String> subtaskTitles;
  final String category;

  TaskTemplate copyWith({
    String? id,
    String? name,
    IconData? icon,
    List<String>? subtaskTitles,
    String? category,
  }) {
    return TaskTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      subtaskTitles: subtaskTitles ?? this.subtaskTitles,
      category: category ?? this.category,
    );
  }

  static List<TaskTemplate> get defaultTemplates => [
    const TaskTemplate(
      id: 'template_grocery',
      name: 'Grocery List',
      icon: Icons.shopping_cart_rounded,
      category: 'Personal',
      subtaskTitles: ['Fruits & Vegetables', 'Milk & Dairy', 'Bread & Bakery', 'Protein/Meat', 'Pantry Essentials'],
    ),
    const TaskTemplate(
      id: 'template_morning',
      name: 'Morning Routine',
      icon: Icons.wb_sunny_rounded,
      category: 'Personal',
      subtaskTitles: ['Drink a glass of water', '10-minute meditation', 'Stretching/Exercise', 'Eat healthy breakfast', 'Plan today\'s tasks'],
    ),
    const TaskTemplate(
      id: 'template_weekly_review',
      name: 'Weekly Review',
      icon: Icons.analytics_rounded,
      category: 'Work',
      subtaskTitles: ['Review all completed tasks', 'Clean up task list & backlog', 'Update upcoming project schedules', 'Define 3 key wins for next week'],
    ),
    const TaskTemplate(
      id: 'template_workout',
      name: 'Workout Routine',
      icon: Icons.fitness_center_rounded,
      category: 'Personal',
      subtaskTitles: ['5-minute dynamic warm up', 'Strength/Cardio workout (30m)', '5-minute static stretch', 'Hydrate & post-workout meal'],
    ),
  ];
}
