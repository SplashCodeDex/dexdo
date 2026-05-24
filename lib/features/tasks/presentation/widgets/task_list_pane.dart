import 'package:dexdo/features/tasks/presentation/providers/task_provider.dart';
import 'package:dexdo/features/tasks/presentation/providers/task_state.dart';
import 'package:dexdo/features/tasks/presentation/widgets/category_dialog.dart';
import 'package:dexdo/features/tasks/presentation/widgets/task_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
            expandedHeight: 220,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildSearchBar(context, taskState, taskNotifier),
                  _buildSortAndFilterRow(context, taskState, taskNotifier),
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
                          borderRadius: BorderRadius.circular(24),
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
                    taskNotifier.reorderTasks(oldIndex, newIndex);
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
                              child: TaskCard(
                                task: task,
                                isSelected: task.id == taskState.selectedTask?.id,
                                state: taskState,
                                notifier: taskNotifier,
                                isLargeScreen: isLargeScreen,
                                index: entry.key,
                              ),
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
                              child: TaskCard(
                                task: task,
                                isSelected: task.id == taskState.selectedTask?.id,
                                state: taskState,
                                notifier: taskNotifier,
                                isLargeScreen: isLargeScreen,
                                index: absoluteIndex,
                              ),
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
            borderRadius: BorderRadius.circular(24),
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
              borderRadius: BorderRadius.circular(24),
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

  Widget _buildSortAndFilterRow(BuildContext context, TaskState state, TaskNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Text(
            'Sort by:',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          _buildSortChip(context, 'Date', TaskSortOption.dueDate, state, notifier),
          _buildSortChip(context, 'Priority', TaskSortOption.priority, state, notifier),
          _buildSortChip(context, 'Title', TaskSortOption.title, state, notifier),
          const Spacer(),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(
              state.sortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => notifier.setSortOption(state.sortOption),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(BuildContext context, String label, TaskSortOption option, TaskState state, TaskNotifier notifier) {
    final isSelected = state.sortOption == option;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => notifier.setSortOption(option),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) 
                  : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
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
                        borderRadius: BorderRadius.circular(24),
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
                                state.categoryIcons[category] ?? Icons.category_rounded,
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
}
