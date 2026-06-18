import 'package:dexdo/features/home/presentation/providers/dashboard_context.dart';
import 'package:dexdo/features/tasks/presentation/providers/task_provider.dart';
import 'package:dexdo/features/tasks/presentation/widgets/task_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdaptiveDashboard extends ConsumerWidget {
  const AdaptiveDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(dashboardProvider.select((s) => s.mode));

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      child: _buildLayout(context, mode),
    );
  }

  Widget _buildLayout(BuildContext context, DashboardMode mode) {
    switch (mode) {
      case DashboardMode.deepWork:
        return const _DeepWorkLayout(key: ValueKey('deepWork'));
      case DashboardMode.planning:
        return const Center(key: ValueKey('planning'), child: Text('Dashboard Ready'));
    }
  }
}

class _DeepWorkLayout extends ConsumerWidget {
  const _DeepWorkLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusTask = ref.watch(dashboardProvider.select((s) => s.focusTask));

    if (focusTask == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No task selected for focus.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(dashboardProvider.notifier).exitFocusMode(),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'CURRENT MISSION',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4.0,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 48),
              const _TimerDisplay(),
              const SizedBox(height: 64),
              TaskCard(
                task: focusTask,
                isSelected: false,
                isSelectionMode: false,
                isTaskSelected: false,
                hasSearchQuery: false,
                notifier: ref.read(taskProvider.notifier),
                isLargeScreen: false,
                index: 0,
              ),
              const SizedBox(height: 64),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    onPressed: () => ref.read(dashboardProvider.notifier).toggleTimer(),
                    icon: const Icon(Icons.pause_rounded),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ),
                  const SizedBox(width: 32),
                  OutlinedButton.icon(
                    onPressed: () => ref.read(dashboardProvider.notifier).exitFocusMode(),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Exit Focus'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerDisplay extends ConsumerWidget {
  const _TimerDisplay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final secondsRemaining = ref.watch(dashboardProvider.select((s) => s.secondsRemaining));
    final minutes = (secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsRemaining % 60).toString().padLeft(2, '0');

    return Text(
      '$minutes:$seconds',
      style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 80,
            fontFamily: 'monospace',
            letterSpacing: -2,
          ),
    );
  }
}
