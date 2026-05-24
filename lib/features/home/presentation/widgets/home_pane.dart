import 'package:dexdo/core/theme/theme_provider.dart';
import 'package:dexdo/features/auth/presentation/providers/auth_provider.dart';
import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:dexdo/features/tasks/presentation/providers/task_provider.dart';
import 'package:dexdo/features/tasks/presentation/providers/task_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';

class HomePane extends ConsumerWidget {
  const HomePane({super.key, this.onTaskTap, this.scrollController});
  final Function(Task)? onTaskTap;
  final ScrollController? scrollController;

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
      return t.isStarred;
    }).toList();

    final totalToday = completedToday.length + activeToday.length;
    final progressToday = totalToday == 0 ? 0.0 : completedToday.length / totalToday;

    return CustomScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverAppBar(context, ref, progressToday, completedToday.length, totalToday),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildSectionTitle(context, 'Weekly Completion'),
              const SizedBox(height: 16),
              _buildProductivityChart(context, allTasks),
              const SizedBox(height: 32),
              _buildSectionTitle(context, 'Upcoming Tasks'),
              const SizedBox(height: 16),
              _buildUpcomingTasks(context, ref, activeTasks),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle(context, 'Categories'),
                  if (taskState.selectedCategory != 'All')
                    TextButton(
                      onPressed: () => taskNotifier.setCategory('All'),
                      child: const Text('Clear Filter'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCategoryOverview(context, taskState, taskNotifier),
              const SizedBox(height: 100), // Bottom padding for FAB
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, WidgetRef ref, double progress, int completed, int total) {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) greeting = 'Good Afternoon';
    if (hour >= 17) greeting = 'Good Evening';

    final authState = ref.watch(authStateChangesProvider);
    final user = authState.value;
    final userName = user?.displayName?.split(' ').first ?? 'Friend!';

    final themeNotifier = ref.read(themeNotifierProvider.notifier);

    return SliverAppBar(
      expandedHeight: 280.0,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      // Status bar brightness control
      systemOverlayStyle: Theme.of(context).brightness == Brightness.dark 
          ? SystemUiOverlayStyle.light 
          : SystemUiOverlayStyle.dark,
      actions: [
        // Theme Toggle
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            final isDark = Theme.of(context).brightness == Brightness.dark;
            themeNotifier.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
          },
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.wb_sunny_rounded
                  : Icons.nightlight_round,
              key: ValueKey(Theme.of(context).brightness == Brightness.dark),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.amber[400]
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        // User Avatar
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 8),
          child: authState.when(
            data: (user) => CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(user?.photoURL ??
                  'https://api.dicebear.com/7.x/avataaars/png?seed=${user?.uid ?? "Felix"}'),
            ),
            loading: () => const CircleAvatar(radius: 16, child: SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))),
            error: (_, _) => const CircleAvatar(radius: 16, child: Icon(Icons.error, size: 16)),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
          StretchMode.fadeTitle,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Decorative Background Gradient
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.fromLTRB(
                24, 
                MediaQuery.paddingOf(context).top + 40, 
                24, 
                24
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          greeting,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.stars_rounded,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                total == 0 
                                    ? 'No tasks yet' 
                                    : '$completed/$total Daily Goals',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildAnimatedProgressIndicator(context, progress),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedProgressIndicator(BuildContext context, double progress) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: progress),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer Ring
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 12,
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                strokeCap: StrokeCap.round,
              ),
            ),
            // Inner Circle with Percentage
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(value * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.primary,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      'DONE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Celebrating Icon
            if (value >= 1.0)
              Positioned(
                top: 0,
                right: 0,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 16),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2, // Slightly increased to avoid 'W' looking like 'vv'
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

    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (maxVal == 0 ? 5 : maxVal) * 1.2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Theme.of(context).colorScheme.primary,
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.round().toString(),
                  const TextStyle(
                    color: Colors.white,
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
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: data.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value == 0 ? 0.2 : entry.value, // Minimal height for visibility
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 12,
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: (maxVal == 0 ? 5 : maxVal) * 1.2,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.03),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
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
    final upcoming = sortedTasks.take(3).toList();
    if (upcoming.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.done_all_rounded,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scale(duration: 2.seconds, curve: Curves.easeInOut)
             .moveY(begin: -5, end: 5, duration: 2.seconds, curve: Curves.easeInOut),
            const SizedBox(height: 24),
            Text(
              'All Caught Up!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 8),
            Text(
              'You\'ve completed all your tasks.\nTake a break and recharge.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
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
        borderRadius: BorderRadius.circular(24),
        child: Hero(
          tag: 'task_${task.id}',
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
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
                      Material(
                        color: Colors.transparent,
                        child: Text(
                          task.title.isEmpty ? 'Untitled Task' : task.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Material(
                        color: Colors.transparent,
                        child: Text(
                          task.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
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
          childAspectRatio: 1.1,
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
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: state.selectedCategory == category 
                            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                            : Theme.of(context).dividerColor,
                        width: state.selectedCategory == category ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: state.selectedCategory == category
                              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.02),
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
