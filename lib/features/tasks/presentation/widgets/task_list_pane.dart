import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';
import '../providers/task_state.dart';
import 'category_dialog.dart';
import 'task_editor_pane.dart';

class TaskListPane extends ConsumerStatefulWidget {
  const TaskListPane({super.key});

  @override
  ConsumerState<TaskListPane> createState() => _TaskListPaneState();
}

class _TaskListPaneState extends ConsumerState<TaskListPane> {
  late TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Use Future.microtask or ref.read in a post-frame callback if initialization is needed
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskState = ref.read(taskProvider);
      _searchController.text = taskState.searchQuery;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);
    final taskNotifier = ref.read(taskProvider.notifier);
    final activeTasks = taskState.activeTasks;
    final completedTasks = taskState.completedTasks;
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: innerBoxIsScrolled ? 2 : 0,
            shadowColor: Colors.black.withValues(alpha: 0.1),
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildSearchBar(context, taskState, taskNotifier),
                  _buildCategoryHeader(context, taskState, taskNotifier),
                ],
              ),
            ),
          ),
        ];
      },
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: (activeTasks.isEmpty && completedTasks.isEmpty)
            ? _buildEmptyState(taskState)
            : ReorderableListView(
                key: ValueKey('list_${taskState.selectedCategory}'),
                buildDefaultDragHandles: false,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                proxyDecorator: (Widget child, int index, Animation<double> animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (BuildContext context, Widget? child) {
                      final double animValue = Curves.easeInOut.transform(animation.value);
                      final double scale = Tween<double>(begin: 1.0, end: 1.02).transform(animValue);
                      return Transform.scale(
                        scale: scale,
                        child: Material(
                          elevation: Tween<double>(begin: 0, end: 12).transform(animValue),
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          shadowColor: Colors.black.withValues(alpha: 0.15),
                          child: child,
                        ),
                      );
                    },
                    child: child,
                  );
                },
                onReorder: (oldIndex, newIndex) {
                  if (taskState.searchQuery.isEmpty) {
                    HapticFeedback.mediumImpact();
                    // taskNotifier.reorderTasks(oldIndex, newIndex);
                  }
                },
                children: [
                  if (activeTasks.isNotEmpty) ...[
                    ...activeTasks.asMap().entries.map((entry) {
                      final task = entry.value;
                      return AnimationConfiguration.staggeredList(
                        key: ValueKey(task.id),
                        position: entry.key,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _buildTaskCard(context, task, task.id == taskState.selectedTask?.id, taskState, taskNotifier, isLargeScreen, entry.key),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                  if (completedTasks.isNotEmpty) ...[
                    _buildSectionHeader('Completed', completedTasks.length),
                    ...completedTasks.asMap().entries.map((entry) {
                      final task = entry.value;
                      final headerOffset = activeTasks.isEmpty ? 1 : 1;
                      final absoluteIndex = activeTasks.length + headerOffset + entry.key;
                      return AnimationConfiguration.staggeredList(
                        key: ValueKey(task.id),
                        position: absoluteIndex,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _buildTaskCard(context, task, task.id == taskState.selectedTask?.id, taskState, taskNotifier, isLargeScreen, absoluteIndex),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, TaskState state, TaskNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) => notifier.setSearchQuery(value),
        onSubmitted: (_) => _searchFocusNode.unfocus(),
        onTapOutside: (_) => _searchFocusNode.unfocus(),
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: state.searchQuery.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 20),
                onPressed: () {
                  _searchController.clear();
                  notifier.setSearchQuery('');
                  _searchFocusNode.unfocus();
                },
              )
            : null,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      key: ValueKey('header_$title'),
      padding: const EdgeInsets.only(top: 8, bottom: 16, left: 4),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Divider(color: Theme.of(context).dividerColor, thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, TaskState state, TaskNotifier notifier) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      child: Row(
        children: [
          for (var category in state.categories)
            Builder(
              builder: (context) {
                final isSelected = state.selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      HapticFeedback.selectionClick();
                      notifier.setCategory(category);
                    },
                    onLongPress: () {
                      FocusScope.of(context).unfocus();
                      if (category != 'All' && category != 'Personal') {
                        HapticFeedback.heavyImpact();
                        showDialog(
                          context: context,
                          builder: (context) => CategoryDialog(
                            initialName: category,
                            initialIcon: state.categoryIcons[category],
                            initialColor: state.categoryColors[category],
                          ),
                        );
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primaryContainer 
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected 
                              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) 
                              : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                        boxShadow: [
                          if (!isSelected)
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Row(
                        children: [
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(
                                state.categoryIcons[category],
                                size: 18,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          Text(
                            category,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.onPrimaryContainer 
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          // Add Category Button
          IconButton(
            onPressed: () {
              FocusScope.of(context).unfocus();
              showDialog(
                context: context,
                builder: (context) => const CategoryDialog(),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.blue, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(TaskState state) {
    return Center(
      key: const ValueKey('empty_state'),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(seconds: 2),
        curve: Curves.easeInOutSine,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 10 * (0.5 - (0.5 - value).abs()) * 2 - 10),
            child: child,
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: SvgPicture.asset(
                'assets/images/logo2DexDoNo.svg',
                height: 180,
                colorFilter: ColorFilter.mode(
                  Colors.blue.withValues(alpha: 0.15),
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'All Caught Up!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have no tasks in ${state.selectedCategory}.\nTap + to plant a new one.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6), 
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    Task task,
    bool isSelected,
    TaskState state,
    TaskNotifier notifier,
    bool isLargeScreen,
    int index,
  ) {
    return Slidable(
      key: Key(task.id),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) {
              FocusScope.of(context).unfocus();
              HapticFeedback.heavyImpact();
              notifier.deleteTask(task);
            },
            backgroundColor: const Color(0xFFE53935),
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Delete',
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
        ],
      ),
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) {
              FocusScope.of(context).unfocus();
              HapticFeedback.mediumImpact();
              notifier.toggleTask(task);
            },
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: task.isCompleted ? Icons.undo_rounded : Icons.check_circle_outline,
            label: task.isCompleted ? 'Undo' : 'Complete',
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
          ),
        ],
      ),
      child: GestureDetector(
        onLongPress: () {
          FocusScope.of(context).unfocus();
          if (!state.isSelectionMode) {
            _showQuickActions(context, task, state, notifier);
          }
        },
        onTap: () {
          FocusScope.of(context).unfocus();
          if (state.isSelectionMode) {
            notifier.toggleTaskSelection(task.id);
          } else {
            notifier.setSelectedTask(task);
            if (!isLargeScreen) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(title: const Text('Edit Task')),
                    body: TaskEditorPane(task: task),
                  ),
                ),
              );
            }
          }
        },
        child: AnimatedOpacity(
          opacity: task.isCompleted ? 0.6 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: state.selectedTaskIds.contains(task.id)
                ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5)
                : (isSelected 
                    ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.15) 
                    : Theme.of(context).colorScheme.surface),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: state.selectedTaskIds.contains(task.id)
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                  : (isSelected 
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3) 
                      : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.2)),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08) 
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: isSelected ? 15 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Selection Checkbox with Progress Ring for Subtasks
                GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    if (state.isSelectionMode) {
                      notifier.toggleTaskSelection(task.id);
                    } else {
                      HapticFeedback.lightImpact();
                      notifier.toggleTask(task);
                    }
                  },
                  onLongPress: () {
                    FocusScope.of(context).unfocus();
                    if (!state.isSelectionMode) {
                      HapticFeedback.heavyImpact();
                      notifier.toggleTaskSelection(task.id);
                    }
                  },
                  child: AnimatedScale(
                    scale: task.isCompleted || state.selectedTaskIds.contains(task.id) ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOutBack,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (task.subtasks.isNotEmpty && !task.isCompleted)
                          SizedBox(
                            width: 34,
                            height: 34,
                            child: CircularProgressIndicator(
                              value: task.progress,
                              strokeWidth: 2.5,
                              backgroundColor: task.color.withValues(alpha: 0.15),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                task.progress == 1.0 ? Colors.green : task.color,
                              ),
                            ),
                          ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: state.selectedTaskIds.contains(task.id)
                                ? Theme.of(context).colorScheme.primary
                                : (task.isCompleted ? task.color.withValues(alpha: 0.15) : Colors.transparent),
                            shape: task.subtasks.isNotEmpty ? BoxShape.circle : BoxShape.rectangle,
                            borderRadius: task.subtasks.isNotEmpty ? null : BorderRadius.circular(8),
                            border: Border.all(
                              color: state.selectedTaskIds.contains(task.id)
                                  ? Theme.of(context).colorScheme.primary
                                  : (task.isCompleted ? task.color : Theme.of(context).colorScheme.outline.withValues(alpha: 0.4)),
                              width: (state.selectedTaskIds.contains(task.id) || task.isCompleted) ? 0 : 1.5,
                            ),
                          ),
                          child: state.selectedTaskIds.contains(task.id)
                              ? Icon(Icons.check, size: 16, color: Theme.of(context).colorScheme.onPrimary)
                              : (task.isCompleted ? Icon(Icons.check, size: 16, color: task.color) : null),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        task.title.isEmpty ? 'New Task' : task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: task.isCompleted 
                              ? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5) 
                              : Theme.of(context).colorScheme.onSurface,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: task.isCompleted 
                                  ? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.1) 
                                  : task.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  task.icon, 
                                  size: 12, 
                                  color: task.isCompleted 
                                      ? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5) 
                                      : task.color
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  task.category,
                                  style: TextStyle(
                                    color: task.isCompleted 
                                        ? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5) 
                                        : task.color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (task.subtasks.isNotEmpty)
                            _buildInfoChip(
                              context,
                              Icons.checklist_rounded,
                              '${task.completedSubtaskCount}/${task.subtasks.length}',
                              task.progress == 1.0 
                                  ? Colors.green 
                                  : (task.isCompleted ? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5) : Theme.of(context).colorScheme.primary),
                            ),
                          if (task.dueDate != null) 
                            _buildDueDateChip(context, task.dueDate!, task.isCompleted),
                          if (task.attachmentCount > 0)
                            _buildInfoChip(
                              context,
                              Icons.attach_file_rounded,
                              '${task.attachmentCount}',
                              Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Star
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    task.isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: task.isStarred ? const Color(0xFFFFB300) : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    size: 24,
                  ),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    notifier.toggleStarred(task);
                  },
                ),
                if (state.searchQuery.isEmpty && !state.isSelectionMode)
                  ReorderableDragStartListener(
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        size: 26,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  void _showQuickActions(BuildContext context, Task task, TaskState state, TaskNotifier notifier) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildActionItem(
              icon: Icons.copy_rounded,
              color: Colors.blue,
              label: 'Duplicate Task',
              onTap: () {
                Navigator.pop(context);
                // notifier.duplicateTask(task);
              },
            ),
            _buildActionItem(
              icon: task.isStarred ? Icons.star_outline_rounded : Icons.star_rounded,
              color: const Color(0xFFFFB300),
              label: task.isStarred ? 'Unstar Task' : 'Star Task',
              onTap: () {
                Navigator.pop(context);
                notifier.toggleStarred(task);
              },
            ),
            _buildActionItem(
              icon: task.isCompleted ? Icons.radio_button_unchecked_rounded : Icons.check_circle_outline_rounded,
              color: Colors.green,
              label: task.isCompleted ? 'Mark as Pending' : 'Mark as Completed',
              onTap: () {
                Navigator.pop(context);
                notifier.toggleTask(task);
              },
            ),
            const Divider(height: 32, indent: 24, endIndent: 24),
            _buildActionItem(
              icon: Icons.delete_outline_rounded,
              color: Colors.red,
              label: 'Delete Task',
              onTap: () {
                Navigator.pop(context);
                notifier.deleteTask(task);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDueDateChip(BuildContext context, DateTime date, bool isCompleted) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);
    final isOverdue = taskDate.isBefore(today);
    final isToday = taskDate.isAtSameMomentAs(today);

    Color color = Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6);
    String label = '${date.day}/${date.month}';

    if (!isCompleted) {
      if (isOverdue) {
        color = Theme.of(context).colorScheme.error;
        label = 'Overdue';
      } else if (isToday) {
        color = Theme.of(context).colorScheme.primary;
        label = 'Today';
      }
    }

    return _buildInfoChip(context, Icons.calendar_today_rounded, label, color);
  }
}

