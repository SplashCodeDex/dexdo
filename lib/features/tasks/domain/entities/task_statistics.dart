import 'package:fl_chart/fl_chart.dart';

class TaskStatistics {
  const TaskStatistics({
    this.habitStrength = 0.0,
    this.completionRate = 0.0,
    this.categoryDistribution = const {},
    this.completionVelocitySpots = const [],
    this.currentStreak = 0,
    this.bestStreak = 0,
  });

  final double habitStrength; // 0.0 to 1.0
  final double completionRate; // Last 30 days
  final Map<String, double> categoryDistribution;
  final List<FlSpot> completionVelocitySpots;
  final int currentStreak;
  final int bestStreak;

  TaskStatistics copyWith({
    double? habitStrength,
    double? completionRate,
    Map<String, double>? categoryDistribution,
    List<FlSpot>? completionVelocitySpots,
    int? currentStreak,
    int? bestStreak,
  }) {
    return TaskStatistics(
      habitStrength: habitStrength ?? this.habitStrength,
      completionRate: completionRate ?? this.completionRate,
      categoryDistribution: categoryDistribution ?? this.categoryDistribution,
      completionVelocitySpots: completionVelocitySpots ?? this.completionVelocitySpots,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
    );
  }
}
