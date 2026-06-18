import 'dart:async';
import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DashboardMode {
  planning, // Main Dashboard
  deepWork, // Focused on a specific task
}

class DashboardState {
  const DashboardState({
    required this.mode,
    required this.secondsRemaining,
    this.focusTask,
  });

  final DashboardMode mode;
  final int secondsRemaining;
  final Task? focusTask;

  DashboardState copyWith({
    DashboardMode? mode,
    int? secondsRemaining,
    Task? focusTask,
    bool clearFocusTask = false,
  }) {
    return DashboardState(
      mode: mode ?? this.mode,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      focusTask: clearFocusTask ? null : (focusTask ?? this.focusTask),
    );
  }
}

final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(() {
  return DashboardNotifier();
});

class DashboardNotifier extends Notifier<DashboardState> {
  Timer? _timer;
  static const int _defaultFocusDuration = 25 * 60; // Pomodoro default

  @override
  DashboardState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });

    return const DashboardState(
      mode: DashboardMode.planning,
      secondsRemaining: _defaultFocusDuration,
    );
  }

  void enterFocusMode(Task task, {int minutes = 25}) {
    state = state.copyWith(
      mode: DashboardMode.deepWork,
      focusTask: task,
      secondsRemaining: minutes * 60,
    );
    _startTimer();
  }

  void exitFocusMode() {
    _timer?.cancel();
    state = state.copyWith(
      mode: DashboardMode.planning,
      clearFocusTask: true,
      secondsRemaining: _defaultFocusDuration,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondsRemaining > 0) {
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      } else {
        _timer?.cancel();
        // In a real app, we might trigger a notification here
      }
    });
  }

  void toggleTimer() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    } else {
      _startTimer();
    }
  }

  void resetTimer({int minutes = 25}) {
    state = state.copyWith(secondsRemaining: minutes * 60);
  }
}
