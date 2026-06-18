import 'dart:ui';

import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:dexdo/features/tasks/presentation/providers/task_provider.dart';
import 'package:dexdo/features/tasks/presentation/providers/task_state.dart';
import 'package:dexdo/features/tasks/presentation/widgets/task_editor_pane.dart';
import 'package:dexdo/shared/widgets/dexdo_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

class TaskCard extends StatelessWidget {

  const TaskCard({
    super.key,
    required this.task,
    required this.isSelected,
    required this.isSelectionMode,
    required this.isTaskSelected,
    required this.hasSearchQuery,
    required this.notifier,
    required this.isLargeScreen,
    required this.index,
  });
  final Task task;
  final bool isSelected;
  final bool isSelectionMode;
  final bool isTaskSelected;
  final bool hasSearchQuery;
  final TaskNotifier notifier;
  final bool isLargeScreen;
  final int index;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Animate(
      target: task.isCompleted ? 1 : 0,
      effects: [
        CustomEffect(
          duration: 400.ms,
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 1.0 - (value * 0.02), // Slight shrink on completion
              child: child,
            );
          },
        ),
      ],
      child: Slidable(
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
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
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
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
            ),
          ],
        ),
        child: GestureDetector(
          onLongPress: () {
            FocusScope.of(context).unfocus();
            if (!isSelectionMode) {
              _showQuickActions(context, task, notifier);
            }
          },
          onTap: () {
            FocusScope.of(context).unfocus();
            if (isSelectionMode) {
              notifier.toggleTaskSelection(task.id);
            } else {
              notifier.setSelectedTask(task);
              if (!isLargeScreen) {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => TaskEditorPane(task: task),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                );
              }
            }
          },
          child: AnimatedOpacity(
            opacity: task.isCompleted ? 0.6 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Hero(
              tag: 'task_${task.id}',
              child: RepaintBoundary(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: isTaskSelected
                              ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: isDark ? 0.4 : 0.6)
                              : Theme.of(context).colorScheme.surface.withValues(alpha: isDark ? 0.7 : 0.8),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isTaskSelected
                                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.05)),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Professional DexDo Checkbox
                              DexDoCheckBox(
                                value: task.isCompleted,
                                isSelectionMode: isTaskSelected,
                                progress: task.subtasks.isNotEmpty && !task.isCompleted ? task.progress : null,
                                isCircle: task.subtasks.isNotEmpty,
                                activeColor: task.isCompleted ? task.color : null,
                                onChanged: (value) {
                                  FocusScope.of(context).unfocus();
                                  if (isSelectionMode) {
                                    notifier.toggleTaskSelection(task.id);
                                  } else {
                                    HapticFeedback.lightImpact();
                                    notifier.toggleTask(task);
                                  }
                                },
                              ),
                              const SizedBox(width: 18),
                              // Text content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        if (task.priority != TaskPriority.medium)
                                          Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: Container(
                                              width: 4,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                color: task.priority.color,
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                          ),
                                        Expanded(
                                          child: Material(
                                            color: Colors.transparent,
                                            child: Text(
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
                                          ),
                                        ),
                                      ],
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
                                            borderRadius: BorderRadius.circular(24),
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
                              if (!hasSearchQuery && !isSelectionMode)
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showQuickActions(BuildContext context, Task task, TaskNotifier notifier) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildActionItem(
              icon: task.isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
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

@widgetbook.UseCase(
  name: 'Default',
  type: TaskCard,
)
Widget buildTaskCardUseCase(BuildContext context) {
  // Create a mock task
  final task = Task(
    id: '1',
    title: context.knobs.string(label: 'Title', initialValue: 'Finish Design System'),
    description: 'Highly detailed design for DeXDo 2026',
    category: context.knobs.string(label: 'Category', initialValue: 'Design'),
    priority: context.knobs.object.dropdown<TaskPriority>(
      label: 'Priority',
      options: TaskPriority.values,
      initialOption: TaskPriority.high,
    ),
    isCompleted: context.knobs.boolean(label: 'Completed', initialValue: false),
    isStarred: context.knobs.boolean(label: 'Starred', initialValue: true),
    dueDate: DateTime.now().add(const Duration(days: 1)),
  );

  return Padding(
    padding: const EdgeInsets.all(24.0),
    child: Center(
      child: TaskCard(
        task: task,
        isSelected: false,
        isSelectionMode: false,
        isTaskSelected: false,
        hasSearchQuery: false,
        notifier: TaskNotifierMock(),
        isLargeScreen: false,
        index: 0,
      ),
    ),
  );
}

// Simple Mock for Widgetbook
class TaskNotifierMock extends TaskNotifier {
  TaskNotifierMock() : super();
  @override
  TaskState build() => TaskState();
  @override
  Future<void> toggleTask(Task task) async {}
  @override
  Future<void> deleteTask(Task task) async {}
  @override
  Future<void> toggleStarred(Task task) async {}
}
