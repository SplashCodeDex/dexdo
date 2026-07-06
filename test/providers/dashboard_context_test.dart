import 'package:dexdo/features/home/presentation/providers/dashboard_context.dart';
import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Creates a minimal valid Task for testing Focus Mode.
Task _makeTask({String id = 'test-task-1', String title = 'Test Task'}) {
  return Task(
    id: id,
    title: title,
    icon: Icons.task_alt,
    color: Colors.blue,
  );
}

void main() {
  // DashboardNotifier.build() creates AppLifecycleListener, which needs the
  // Flutter widget binding to be bootstrapped before ProviderContainer can
  // read the provider in a plain unit-test environment.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DashboardNotifier – Focus Mode & Timer State', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state: mode is planning, timer is NOT running', () {
      final state = container.read(dashboardProvider);

      expect(state.mode, DashboardMode.planning);
      expect(state.isTimerRunning, isFalse);
      expect(state.focusTask, isNull);
      expect(state.secondsRemaining, 25 * 60);
    });

    test('enterFocusMode: mode switches to deepWork, timer starts running', () {
      final task = _makeTask();
      container.read(dashboardProvider.notifier).enterFocusMode(task);

      final state = container.read(dashboardProvider);

      expect(state.mode, DashboardMode.deepWork);
      expect(state.focusTask, equals(task));
      expect(state.isTimerRunning, isTrue);
      expect(state.secondsRemaining, 25 * 60);
    });

    test('enterFocusMode: custom minutes set correctly on secondsRemaining', () {
      final task = _makeTask();
      container.read(dashboardProvider.notifier).enterFocusMode(task, minutes: 50);

      final state = container.read(dashboardProvider);

      expect(state.secondsRemaining, 50 * 60);
      expect(state.isTimerRunning, isTrue);
    });

    test('exitFocusMode: resets to planning, clears task, timer stops', () {
      final task = _makeTask();
      container.read(dashboardProvider.notifier).enterFocusMode(task);

      // Verify entered
      expect(container.read(dashboardProvider).mode, DashboardMode.deepWork);

      container.read(dashboardProvider.notifier).exitFocusMode();

      final state = container.read(dashboardProvider);

      expect(state.mode, DashboardMode.planning);
      expect(state.focusTask, isNull);
      expect(state.isTimerRunning, isFalse);
      expect(state.secondsRemaining, 25 * 60);
    });

    test('toggleTimer: pauses running timer (isTimerRunning becomes false)', () {
      final task = _makeTask();
      container.read(dashboardProvider.notifier).enterFocusMode(task);

      // Timer should be running at this point
      expect(container.read(dashboardProvider).isTimerRunning, isTrue);

      // Toggle once → pause
      container.read(dashboardProvider.notifier).toggleTimer();

      expect(container.read(dashboardProvider).isTimerRunning, isFalse);
    });

    test('toggleTimer: resumes paused timer (isTimerRunning becomes true)', () {
      final task = _makeTask();
      container.read(dashboardProvider.notifier).enterFocusMode(task);

      // Pause first
      container.read(dashboardProvider.notifier).toggleTimer();
      expect(container.read(dashboardProvider).isTimerRunning, isFalse);

      // Resume
      container.read(dashboardProvider.notifier).toggleTimer();
      expect(container.read(dashboardProvider).isTimerRunning, isTrue);
    });

    test('resetTimer: updates secondsRemaining without changing timer running state', () {
      final task = _makeTask();
      container.read(dashboardProvider.notifier).enterFocusMode(task);

      // Timer is running
      container.read(dashboardProvider.notifier).resetTimer(minutes: 10);

      final state = container.read(dashboardProvider);
      expect(state.secondsRemaining, 10 * 60);
      // isTimerRunning should not be changed by reset alone (timer was running)
      expect(state.isTimerRunning, isTrue);
    });

    test('DashboardState.copyWith: isTimerRunning can be toggled independently', () {
      const initial = DashboardState(
        mode: DashboardMode.planning,
        secondsRemaining: 25 * 60,
        isTimerRunning: false,
      );

      final updated = initial.copyWith(isTimerRunning: true);

      expect(updated.isTimerRunning, isTrue);
      expect(updated.mode, DashboardMode.planning); // unchanged
      expect(updated.secondsRemaining, 25 * 60);    // unchanged
    });
  });
}
