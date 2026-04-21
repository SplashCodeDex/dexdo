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
      _titleController.text = widget.task.title;
      _descriptionController.text = widget.task.description;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subtaskController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _saveChanges(TaskProvider provider) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      provider.updateTask(
        widget.task,
        _titleController.text,
        _descriptionController.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
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
                    color: widget.task.isStarred ? const Color(0xFFFFB300) : Colors.grey,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    taskProvider.deleteTask(widget.task);
                  },
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  tooltip: 'Delete Task',
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Title Input
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'What needs to be done?',
                hintStyle: TextStyle(color: Colors.black26),
                border: InputBorder.none,
              ),
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: widget.task.isCompleted ? Colors.grey : Colors.black87,
                    decoration: widget.task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
              onChanged: (_) => _saveChanges(taskProvider),
            ),
            const SizedBox(height: 24),

            // Metadata Cards
            Row(
              children: [
                _buildDetailCard(
                  icon: Icons.category_rounded,
                  label: 'Category',
                  child: _buildCategoryDropdown(taskProvider),
                ),
                const SizedBox(width: 16),
                _buildDetailCard(
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
                    if (pickedDate != null) {
                      taskProvider.updateDueDate(widget.task, pickedDate);
                    }
                  },
                  child: Text(
                    widget.task.dueDate == null
                        ? 'Set Date'
                        : _formatDate(widget.task.dueDate!),
                    style: TextStyle(
                      color: widget.task.dueDate == null ? Colors.black26 : Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
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
                color: Colors.grey[100]?.withValues(alpha: 0.5),
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
                style: const TextStyle(height: 1.6, color: Colors.black87),
                onChanged: (_) => _saveChanges(taskProvider),
              ),
            ),
            const SizedBox(height: 40),
            
            // Bottom Save Indicator
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_done_outlined, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Changes saved automatically',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
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
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.black38,
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
          color: Colors.grey[50],
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
                color: subtask.isCompleted ? Colors.green : Colors.grey[400],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                subtask.title,
                style: TextStyle(
                  color: subtask.isCompleted ? Colors.grey : Colors.black87,
                  decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 16, color: Colors.black12),
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
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.add_rounded, size: 20, color: Colors.black26),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _subtaskController,
              decoration: const InputDecoration(
                hintText: 'Add a subtask...',
                hintStyle: TextStyle(fontSize: 14, color: Colors.black26),
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
          color: widget.task.isCompleted ? Colors.green.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.task.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              size: 18,
              color: widget.task.isCompleted ? Colors.green : Colors.blue,
            ),
            const SizedBox(width: 8),
            Text(
              widget.task.isCompleted ? 'COMPLETED' : 'IN PROGRESS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: widget.task.isCompleted ? Colors.green : Colors.blue,
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
            color: onTap != null ? Colors.white : Colors.transparent,
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: Colors.black38),
                  const SizedBox(width: 8),
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.black38)),
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
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: widget.task.category,
        isDense: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
        items: taskProvider.categories
            .where((c) => c != 'All')
            .map((String category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          );
        }).toList(),
        onChanged: (String? newValue) {
          FocusScope.of(context).unfocus();
          if (newValue != null) {
            taskProvider.updateCategory(widget.task, newValue);
          }
        },
      ),
    );
  }
}
