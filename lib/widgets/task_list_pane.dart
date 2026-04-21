import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'category_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'task_editor_pane.dart';
import '../models/task.dart';

class TaskListPane extends StatefulWidget {
  const TaskListPane({super.key});

  @override
  State<TaskListPane> createState() => _TaskListPaneState();
}

class _TaskListPaneState extends State<TaskListPane> {
  late TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    _searchController = TextEditingController(text: taskProvider.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final activeTasks = taskProvider.activeTasks;
    final completedTasks = taskProvider.completedTasks;
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Column(
      children: [
        _buildSearchBar(context, taskProvider),
        _buildCategoryHeader(context, taskProvider),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: (activeTasks.isEmpty && completedTasks.isEmpty)
                ? _buildEmptyState(taskProvider)
                : ReorderableListView(
                    key: ValueKey('list_${taskProvider.selectedCategory}'),
                    buildDefaultDragHandles: taskProvider.searchQuery.isEmpty,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    onReorder: (oldIndex, newIndex) {
                      if (taskProvider.searchQuery.isEmpty) {
                        taskProvider.reorderTasks(oldIndex, newIndex);
                      }
                    },
                    children: [
                      if (activeTasks.isNotEmpty) ...[
                        ...activeTasks.asMap().entries.map((entry) {
                          final task = entry.value;
                          return Padding(
                            key: ValueKey(task.id),
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildTaskCard(context, task, task.id == taskProvider.selectedTask?.id, taskProvider, isLargeScreen),
                          );
                        }),
                      ],
                      if (completedTasks.isNotEmpty) ...[
                        _buildSectionHeader('Completed', completedTasks.length),
                        ...completedTasks.asMap().entries.map((entry) {
                          final task = entry.value;
                          return Padding(
                            key: ValueKey(task.id),
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildTaskCard(context, task, task.id == taskProvider.selectedTask?.id, taskProvider, isLargeScreen),
                          );
                        }),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, TaskProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) => provider.setSearchQuery(value),
        onSubmitted: (_) => _searchFocusNode.unfocus(),
        onTapOutside: (_) => _searchFocusNode.unfocus(),
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: provider.searchQuery.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 20),
                onPressed: () {
                  _searchController.clear();
                  provider.setSearchQuery('');
                  _searchFocusNode.unfocus();
                },
              )
            : null,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
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
              borderRadius: BorderRadius.circular(10),
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

  Widget _buildCategoryHeader(BuildContext context, TaskProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          for (var category in provider.categories)
            Builder(
              builder: (context) {
                final isSelected = provider.selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      provider.setCategory(category);
                    },
                    onLongPress: () {
                      FocusScope.of(context).unfocus();
                      if (category != 'All' && category != 'Personal') {
                        HapticFeedback.heavyImpact();
                        showDialog(
                          context: context,
                          builder: (context) => CategoryDialog(
                            initialName: category,
                            initialIcon: provider.categoryIcons[category],
                            initialColor: provider.categoryColors[category],
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
                        borderRadius: BorderRadius.circular(30),
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
                                provider.categoryIcons[category],
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

  Widget _buildEmptyState(TaskProvider taskProvider) {
    return Center(
      key: const ValueKey('empty_state'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/logo2DexDoNo.svg',
            height: 180,
            colorFilter: ColorFilter.mode(
              Colors.blue.withValues(alpha: 0.1),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'No tasks in ${taskProvider.selectedCategory}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first task',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    Task task,
    bool isSelected,
    TaskProvider taskProvider,
    bool isLargeScreen,
  ) {
    return Slidable(
      key: Key(task.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) {
              FocusScope.of(context).unfocus();
              taskProvider.deleteTask(task);
            },
            backgroundColor: const Color(0xFFE53935),
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Delete',
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
        ],
      ),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) {
              FocusScope.of(context).unfocus();
              taskProvider.toggleTask(task);
            },
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: task.isCompleted ? Icons.undo_rounded : Icons.check_circle_outline,
            label: task.isCompleted ? 'Undo' : 'Complete',
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomLeft: Radius.circular(24),
            ),
          ),
        ],
      ),
      child: GestureDetector(
        onLongPress: () {
          FocusScope.of(context).unfocus();
          if (!taskProvider.isSelectionMode) {
            _showQuickActions(context, task, taskProvider);
          }
        },
        onTap: () {
          FocusScope.of(context).unfocus();
          if (taskProvider.isSelectionMode) {
            taskProvider.toggleTaskSelection(task.id);
          } else {
            taskProvider.setSelectedTask(task);
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: taskProvider.selectedTaskIds.contains(task.id)
                ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5)
                : (isSelected 
                    ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2) 
                    : Theme.of(context).colorScheme.surface),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: taskProvider.selectedTaskIds.contains(task.id)
                  ? Theme.of(context).colorScheme.primary
                  : (isSelected 
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3) 
                      : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08) 
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: isSelected ? 20 : 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Row(
              children: [
                // Selection Checkbox or Custom Checkbox
                GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    if (taskProvider.isSelectionMode) {
                      taskProvider.toggleTaskSelection(task.id);
                    } else {
                      taskProvider.toggleTask(task);
                    }
                  },
                  onLongPress: () {
                    FocusScope.of(context).unfocus();
                    if (!taskProvider.isSelectionMode) {
                      HapticFeedback.heavyImpact();
                      taskProvider.toggleTaskSelection(task.id);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: taskProvider.selectedTaskIds.contains(task.id)
                          ? Theme.of(context).colorScheme.primary
                          : (task.isCompleted ? task.color : Colors.transparent),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: taskProvider.selectedTaskIds.contains(task.id)
                            ? Theme.of(context).colorScheme.primary
                            : (task.isCompleted ? task.color : Theme.of(context).colorScheme.outline),
                        width: 2,
                      ),
                    ),
                    child: taskProvider.selectedTaskIds.contains(task.id)
                        ? Icon(Icons.check, size: 18, color: Theme.of(context).colorScheme.onPrimary)
                        : (task.isCompleted ? const Icon(Icons.check, size: 18, color: Colors.white) : null),
                  ),
                ),
                const SizedBox(width: 16),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title.isEmpty ? 'New Task' : task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: task.isCompleted 
                              ? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5) 
                              : Theme.of(context).colorScheme.onSurface,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(task.icon, size: 14, color: task.color.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Text(
                            task.category,
                            style: TextStyle(
                              color: task.color.withValues(alpha: 0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (task.attachmentCount > 0 || task.subtasks.isNotEmpty || task.dueDate != null) ...[
                            const SizedBox(width: 12),
                            Text('•', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2))),
                            const SizedBox(width: 12),
                            if (task.dueDate != null) ...[
                              _buildDueDateBadge(task.dueDate!),
                              const SizedBox(width: 12),
                            ],
                            if (task.attachmentCount > 0) ...[
                              Icon(Icons.attach_file_rounded, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                              Text(' ${task.attachmentCount} ', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5))),
                            ],
                            if (task.subtasks.isNotEmpty) ...[
                              Icon(
                                task.progress == 1.0 ? Icons.check_circle_outline : Icons.checklist_rounded, 
                                size: 14, 
                                color: task.progress == 1.0 ? Colors.green : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                              ),
                              Text(
                                ' ${task.completedSubtaskCount}/${task.subtasks.length}', 
                                style: TextStyle(
                                  fontSize: 11, 
                                  color: task.progress == 1.0 ? Colors.green : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                  fontWeight: task.progress == 1.0 ? FontWeight.bold : FontWeight.normal,
                                )
                              ),
                            ],
                          ],
                        ],
                      ),
                      if (task.subtasks.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: task.progress,
                            backgroundColor: task.color.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              task.isCompleted ? Colors.grey[300]! : task.color
                            ),
                            minHeight: 3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Star
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    task.isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: task.isStarred ? const Color(0xFFFFB300) : Colors.grey[200],
                    size: 26,
                  ),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    taskProvider.toggleStarred(task);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQuickActions(BuildContext context, Task task, TaskProvider provider) {
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
                provider.duplicateTask(task);
              },
            ),
            _buildActionItem(
              icon: task.isStarred ? Icons.star_outline_rounded : Icons.star_rounded,
              color: const Color(0xFFFFB300),
              label: task.isStarred ? 'Unstar Task' : 'Star Task',
              onTap: () {
                Navigator.pop(context);
                provider.toggleStarred(task);
              },
            ),
            _buildActionItem(
              icon: task.isCompleted ? Icons.radio_button_unchecked_rounded : Icons.check_circle_outline_rounded,
              color: Colors.green,
              label: task.isCompleted ? 'Mark as Pending' : 'Mark as Completed',
              onTap: () {
                Navigator.pop(context);
                provider.toggleTask(task);
              },
            ),
            const Divider(height: 32, indent: 24, endIndent: 24),
            _buildActionItem(
              icon: Icons.delete_outline_rounded,
              color: Colors.red,
              label: 'Delete Task',
              onTap: () {
                Navigator.pop(context);
                provider.deleteTask(task);
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

  Widget _buildDueDateBadge(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);
    final isOverdue = taskDate.isBefore(today);
    final isToday = taskDate.isAtSameMomentAs(today);

    Color color = Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
    String label = '${date.day}/${date.month}';

    if (isOverdue) {
      color = Theme.of(context).colorScheme.error;
      label = 'Overdue';
    } else if (isToday) {
      color = Theme.of(context).colorScheme.primary;
      label = 'Today';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calendar_today_rounded, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: isOverdue || isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
