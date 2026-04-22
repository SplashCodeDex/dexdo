import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class TaskEditorPane extends StatefulWidget {
  final Task task;

  const TaskEditorPane({
    super.key,
    required this.task,
  });

  @override
  State<TaskEditorPane> createState() => _TaskEditorPaneState();
}

class _TaskEditorPaneState extends State<TaskEditorPane> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _subtaskController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _subtaskController = TextEditingController();
  }

  @override
  void didUpdateWidget(TaskEditorPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id) {
      // Flush changes for the previous task if a debounce was pending
      if (_debounce?.isActive ?? false) {
        _debounce!.cancel();
        Provider.of<TaskProvider>(context, listen: false).updateTask(
          oldWidget.task,
          _titleController.text,
          _descriptionController.text,
        );
      }
      _titleController.text = widget.task.title;
      _descriptionController.text = widget.task.description;
    }
  }

  @override
  void dispose() {
    // Flush any pending changes before disposing
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.updateTask(
        widget.task,
        _titleController.text,
        _descriptionController.text,
      );
    }
    _titleController.dispose();
    _descriptionController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  void _saveChanges(TaskProvider provider) {
    final taskToUpdate = widget.task;
    final newTitle = _titleController.text;
    final newDescription = _descriptionController.text;

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      provider.updateTask(
        taskToUpdate,
        newTitle,
        newDescription,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          bottomLeft: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Action Row
            Row(
              children: [
                _buildStatusChip(taskProvider),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    taskProvider.toggleStarred(widget.task);
                  },
                  icon: Icon(
                    widget.task.isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: widget.task.isStarred ? const Color(0xFFFFB300) : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    taskProvider.deleteTask(widget.task);
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
                  tooltip: 'Delete Task',
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Title Input
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'What needs to be done?',
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                border: InputBorder.none,
              ),
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: widget.task.isCompleted ? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5) : Theme.of(context).colorScheme.onSurface,
                    decoration: widget.task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
              onChanged: (_) => _saveChanges(taskProvider),
            ),
            const SizedBox(height: 24),

            // Metadata Cards
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 160,
                  child: _buildDetailCard(
                    icon: Icons.category_rounded,
                    label: 'Category',
                    child: _buildCategoryDropdown(taskProvider),
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: _buildDetailCard(
                    icon: Icons.calendar_today_rounded,
                    label: 'Due Date',
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: widget.task.dueDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (!context.mounted) return;
                      if (pickedDate != null) {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(widget.task.dueDate ?? DateTime.now()),
                        );
                        if (!context.mounted) return;
                        if (pickedTime != null) {
                          final finalDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                          taskProvider.updateDueDate(widget.task, finalDateTime);
                        } else {
                          taskProvider.updateDueDate(widget.task, pickedDate);
                        }
                      }
                    },
                    child: Text(
                      widget.task.dueDate == null
                          ? 'Set Date'
                          : _formatDate(widget.task.dueDate!),
                      style: TextStyle(
                        color: widget.task.dueDate == null ? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5) : Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: _buildDetailCard(
                    icon: Icons.repeat_rounded,
                    label: 'Recurrence',
                    child: _buildRecurrenceDropdown(taskProvider),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Subtasks Section
            _buildSectionLabel('SUBTASKS (${widget.task.completedSubtaskCount}/${widget.task.subtaskCount})'),
            const SizedBox(height: 12),
            ...widget.task.subtasks.map((subtask) => _buildSubtaskItem(taskProvider, subtask)),
            _buildAddSubtaskField(taskProvider),
            const SizedBox(height: 32),

            // Description Area
            _buildSectionLabel('DESCRIPTION'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Add more details about this task...',
                  border: InputBorder.none,
                ),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                maxLines: 8,
                style: TextStyle(height: 1.6, color: Theme.of(context).colorScheme.onSurface),
                onChanged: (_) => _saveChanges(taskProvider),
              ),
            ),
            const SizedBox(height: 40),
            
            // Bottom Save Indicator
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_done_outlined, size: 16, color: Colors.green.withValues(alpha: 0.7)),
                  const SizedBox(width: 8),
                  Text(
                    'Changes saved automatically',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSubtaskItem(TaskProvider provider, SubTask subtask) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                provider.toggleSubtask(widget.task, subtask);
              },
              child: Icon(
                subtask.isCompleted ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                color: subtask.isCompleted ? Colors.green : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                subtask.title,
                style: TextStyle(
                  color: subtask.isCompleted ? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5) : Theme.of(context).colorScheme.onSurface,
                  decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close_rounded, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
              onPressed: () {
                FocusScope.of(context).unfocus();
                provider.deleteSubtask(widget.task, subtask);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddSubtaskField(TaskProvider provider) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.add_rounded, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _subtaskController,
              decoration: InputDecoration(
                hintText: 'Add a subtask...',
                hintStyle: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                border: InputBorder.none,
              ),
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  provider.addSubtask(widget.task, value);
                  _subtaskController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(TaskProvider provider) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        provider.toggleTask(widget.task);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: widget.task.isCompleted 
              ? Colors.green.withValues(alpha: 0.1) 
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.task.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              size: 18,
              color: widget.task.isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              widget.task.isCompleted ? 'COMPLETED' : 'IN PROGRESS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: widget.task.isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) return 'Today';
    if (taskDate == tomorrow) return 'Tomorrow';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: onTap != null ? Theme.of(context).colorScheme.surface : Colors.transparent,
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                  const SizedBox(width: 8),
                  Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5))),
                ],
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(TaskProvider taskProvider) {
    return InkWell(
      onTap: () => _showCategoryPicker(context, taskProvider),
      borderRadius: BorderRadius.circular(12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.task.category,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildRecurrenceDropdown(TaskProvider taskProvider) {
    String displayVal = widget.task.recurrence ?? 'none';
    displayVal = displayVal[0].toUpperCase() + displayVal.substring(1);
    
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _showRecurrencePicker(context, taskProvider);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            displayVal,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  void _showRecurrencePicker(BuildContext context, TaskProvider taskProvider) {
    const options = ['none', 'daily', 'weekly', 'monthly', 'yearly'];
    
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
            Text(
              'Select Recurrence',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: options.map((option) {
                  final String displayOption = option[0].toUpperCase() + option.substring(1);
                  final bool isSelected = widget.task.recurrence == option;
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        option == 'none' ? Icons.not_interested_rounded : Icons.repeat_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      displayOption,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary 
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () {
                      taskProvider.updateRecurrence(widget.task, option);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context, TaskProvider taskProvider) {
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
            Text(
              'Select Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: taskProvider.categories
                    .where((c) => c != 'All')
                    .map((category) => ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (taskProvider.categoryColors[category] ?? Colors.blue).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              taskProvider.categoryIcons[category] ?? Icons.category_rounded,
                              color: taskProvider.categoryColors[category] ?? Colors.blue,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            category,
                            style: TextStyle(
                              fontWeight: widget.task.category == category ? FontWeight.bold : FontWeight.normal,
                              color: widget.task.category == category 
                                  ? Theme.of(context).colorScheme.primary 
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          trailing: widget.task.category == category
                              ? Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary)
                              : null,
                          onTap: () {
                            taskProvider.updateCategory(widget.task, category);
                            Navigator.pop(context);
                          },
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
