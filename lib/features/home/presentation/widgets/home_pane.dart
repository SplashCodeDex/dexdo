import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../tasks/presentation/providers/task_state.dart';

class HomePane extends ConsumerWidget {
  final Function(Task)? onTaskTap;
  final ScrollController? scrollController;
  const HomePane({super.key, this.onTaskTap, this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskProvider);
    final taskNotifier = ref.read(taskProvider.notifier);
    final activeTasks = taskState.activeTasks;
    final allTasks = taskState.allTasks;
    final now = DateTime.now();
    final completedToday = allTasks.where((t) {
      if (t.isCompleted && t.completionDate != null) {
        return t.completionDate!.year == now.year &&
            t.completionDate!.month == now.month &&
            t.completionDate!.day == now.day;
      }
      return false;
    }).toList();

    final activeToday = allTasks.where((t) {
      if (t.isCompleted) return false;
      if (t.dueDate != null) {
        final taskDate = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
        final todayDate = DateTime(now.year, now.month, now.day);
        return taskDate.isBefore(todayDate) || taskDate.isAtSameMomentAs(todayDate);
      }
      // If a task has no due date but is starred, we can consider it "in focus" for today
      return t.isStarred;
    }).toList();

    final totalToday = completedToday.length + activeToday.length;
    final progressToday = totalToday == 0 ? 0.0 : completedToday.length / totalToday;

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, ref),
          const SizedBox(height: 32),
          _buildProgressCard(context, progressToday, completedToday.length, totalToday),
          const SizedBox(height: 32),
          _buildSectionTitle(context, 'Weekly Completion'),
          const SizedBox(height: 16),
          _buildProductivityChart(context, allTasks),
          const SizedBox(height: 32),
          _buildCategoryFilter(context, taskState, taskNotifier),
          const SizedBox(height: 8),
          _buildSectionTitle(context, 'Upcoming Tasks'),
          const SizedBox(height: 16),
          _buildUpcomingTasks(context, ref, activeTasks),
          const SizedBox(height: 32),
          _buildSectionTitle(context, 'Categories'),
          const SizedBox(height: 16),
          _buildCategoryOverview(context, taskState, taskNotifier),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) greeting = 'Good Afternoon';
    if (hour >= 17) greeting = 'Good Evening';

    final authState = ref.watch(authStateChangesProvider);
    final user = authState.value;
    final userName = user?.displayName?.split(' ').first ?? 'Friend!';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 56,
          height: 56,
        ),
      ],
    );
  }

  Widget _buildProgressCard(BuildContext context, double progress, int completed, int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  total == 0 
                      ? 'No tasks for today' 
                      : 'You\'ve completed $completed of $total tasks today!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${(progress * 100).toInt()}% Done',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Icon(
                progress == 1.0 ? Icons.celebration_rounded : Icons.bolt_rounded,
                color: Colors.white,
                size: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildProductivityChart(BuildContext context, List<Task> tasks) {
    final now = DateTime.now();
    final last7Days = List.generate(7, (index) {
      return now.subtract(Duration(days: 6 - index));
    });

    final data = last7Days.map((day) {
      final completedOnDay = tasks.where((t) {
        if (t.isCompleted && t.completionDate != null) {
          return t.completionDate!.year == day.year &&
              t.completionDate!.month == day.month &&
              t.completionDate!.day == day.day;
        }
        return false;
      }).length;
      return double.parse(completedOnDay.toString());
    }).toList();

    final maxVal = data.isEmpty ? 5.0 : data.reduce((a, b) => a > b ? a : b);
    final interval = maxVal > 0 ? (maxVal / 5).ceilToDouble() : 1.0;

    return Container(
      height: 220,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal + 1,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Theme.of(context).colorScheme.primaryContainer,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.round().toString(),
                  TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 || value.toInt() >= 7) return const SizedBox();
                  final date = last7Days[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('E').format(date).substring(0, 1),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
                reservedSize: 28,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: interval,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.round().toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      fontSize: 10,
                    ),
                  );
                },
                reservedSize: 20,
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Theme.of(context).dividerColor,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: data.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  color: Theme.of(context).colorScheme.primary,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxVal + 1,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, TaskState state, TaskNotifier notifier) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: state.categories.map((category) {
          final isSelected = state.selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  HapticFeedback.selectionClick();
                  notifier.setCategory(category);
                }
              },
              side: BorderSide.none,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              labelStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUpcomingTasks(BuildContext context, WidgetRef ref, List<Task> tasks) {
    final sortedTasks = List<Task>.from(tasks)
      ..sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    final upcoming = sortedTasks.take(5).toList();
    if (upcoming.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          children: [
            Icon(Icons.auto_awesome_rounded, size: 48, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'All caught up!\nEnjoy your free time.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: Column(
        children: upcoming.asMap().entries.map((entry) {
          final index = entry.key;
          final task = entry.value;
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildSimpleTaskTile(context, ref, task),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSimpleTaskTile(BuildContext context, WidgetRef ref, Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          final notifier = ref.read(taskProvider.notifier);
          notifier.setSelectedTask(task);
          if (onTaskTap != null) onTaskTap!(task);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: task.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(task.icon, size: 24, color: task.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title.isEmpty ? 'Untitled Task' : task.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (task.dueDate != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 12, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMM d').format(task.dueDate!),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryOverview(BuildContext context, TaskState state, TaskNotifier notifier) {
    final activeCategories = state.categories.where((c) => c != 'All').toList();
    
    return AnimationLimiter(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
        ),
        itemCount: activeCategories.length,
        itemBuilder: (context, index) {
          final category = activeCategories[index];
          final tasks = state.tasks.where((t) => t.category == category).toList();
          final activeCount = tasks.where((t) => !t.isCompleted).length;
          final totalCount = tasks.length;
          final progress = totalCount == 0 ? 0.0 : (totalCount - activeCount) / totalCount;
  
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.setCategory(category);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).dividerColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: state.categoryColors[category]!.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                state.categoryIcons[category],
                                color: state.categoryColors[category],
                                size: 20,
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: state.categoryColors[category],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          category,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: state.categoryColors[category]!.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(state.categoryColors[category]!),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$activeCount active tasks',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
