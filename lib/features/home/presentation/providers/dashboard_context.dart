import 'dart:async';
import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:flutter/widgets.dart';
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
    this.isTimerRunning = false,
  });

  final DashboardMode mode;
  final int secondsRemaining;
  final Task? focusTask;
  final bool isTimerRunning;

  DashboardState copyWith({
    DashboardMode? mode,
    int? secondsRemaining,
    Task? focusTask,
    bool clearFocusTask = false,
    bool? isTimerRunning,
  }) {
    return DashboardState(
      mode: mode ?? this.mode,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      focusTask: clearFocusTask ? null : (focusTask ?? this.focusTask),
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
    );
  }
}

final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(() {
  return DashboardNotifier();
});

class DashboardNotifier extends Notifier<DashboardState> {
  Timer? _timer;
  AppLifecycleListener? _lifecycleListener;
  DateTime? _targetEndTime;
  bool _wasTimerRunning = false;
  
  static const int _defaultFocusDuration = 25 * 60; // Pomodoro default

  @override
  DashboardState build() {
    _lifecycleListener = AppLifecycleListener(
      onPause: _onPause,
      onResume: _onResume,
    );
    
    ref.onDispose(() {
      _timer?.cancel();
      _lifecycleListener?.dispose();
    });

    return const DashboardState(
      mode: DashboardMode.planning,
      secondsRemaining: _defaultFocusDuration,
      isTimerRunning: false,
    );
  }

  void enterFocusMode(Task task, {int minutes = 25}) {
    state = state.copyWith(
      mode: DashboardMode.deepWork,
      focusTask: task,
      secondsRemaining: minutes * 60,
      isTimerRunning: true,
    );
    _startTimer();
  }

  void exitFocusMode() {
    _timer?.cancel();
    state = state.copyWith(
      mode: DashboardMode.planning,
      clearFocusTask: true,
      secondsRemaining: _defaultFocusDuration,
      isTimerRunning: false,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    state = state.copyWith(isTimerRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondsRemaining > 0) {
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      } else {
        _timer?.cancel();
        state = state.copyWith(isTimerRunning: false);
        // In a real app, we might trigger a notification here
      }
    });
  }

  void _onPause() {
    _wasTimerRunning = _timer?.isActive ?? false;
    if (_wasTimerRunning) {
      _timer?.cancel();
      state = state.copyWith(isTimerRunning: false);
      _targetEndTime = DateTime.now().add(Duration(seconds: state.secondsRemaining));
    }
  }

  void _onResume() {
    if (_wasTimerRunning && _targetEndTime != null) {
      final remaining = _targetEndTime!.difference(DateTime.now()).inSeconds;
      if (remaining > 0) {
        state = state.copyWith(
          secondsRemaining: remaining,
          isTimerRunning: true,
        );
        _startTimer();
      } else {
        state = state.copyWith(
          secondsRemaining: 0,
          isTimerRunning: false,
        );
      }
    }
  }

  void toggleTimer() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
      state = state.copyWith(isTimerRunning: false);
    } else {
      _startTimer();
    }
  }

  void resetTimer({int minutes = 25}) {
    state = state.copyWith(secondsRemaining: minutes * 60);
  }
}
