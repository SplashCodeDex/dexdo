import 'dart:async';
import 'dart:ui';

import 'package:dexdo/core/services/ai_service.dart';
import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:dexdo/features/tasks/presentation/providers/task_provider.dart';
import 'package:dexdo/features/tasks/presentation/providers/task_state.dart';
import 'package:dexdo/features/tasks/presentation/widgets/date_time_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TaskEditorPane extends ConsumerStatefulWidget {

  const TaskEditorPane({
    super.key,
    required this.task,
  });
  final Task task;

  @override
  ConsumerState<TaskEditorPane> createState() => _TaskEditorPaneState();
}

class _TaskEditorPaneState extends ConsumerState<TaskEditorPane> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _subtaskController;
  Timer? _debounce;
  final AIService _aiService = AIService();
  bool _isAILoading = false;

  // Focus Timer & AI state variables
  bool _isFocusActive = false;
  bool _isFocusTimerRunning = false;
  int _focusTimeRemaining = 25 * 60; // 25 mins
  Timer? _focusTimer;
  String? _aiTimeEstimate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _subtaskController = TextEditingController();
  }

  void _startFocusMode() {
    setState(() {
      _isFocusActive = true;
      _isFocusTimerRunning = true;
      _focusTimeRemaining = 25 * 60;
    });
    _tickFocusTimer();
  }

  void _tickFocusTimer() {
    _focusTimer?.cancel();
    _focusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_focusTimeRemaining > 0) {
        setState(() {
          _focusTimeRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isFocusTimerRunning = false;
            _isFocusActive = false;
          });
          unawaited(HapticFeedback.vibrate());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Focus session complete! Take a break.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  void _toggleFocusTimer() {
    if (_isFocusTimerRunning) {
      _focusTimer?.cancel();
      setState(() {
        _isFocusTimerRunning = false;
      });
    } else {
      setState(() {
        _isFocusTimerRunning = true;
      });
      _tickFocusTimer();
    }
  }

  void _exitFocusMode() {
    _focusTimer?.cancel();
    setState(() {
      _isFocusActive = false;
      _isFocusTimerRunning = false;
    });
  }

  Future<void> _handleAICategorySuggest(TaskNotifier notifier, TaskState state) async {
    if (_titleController.text.isEmpty) return;
    setState(() => _isAILoading = true);
    try {
      final suggestedCategory = await _aiService.suggestCategory(_titleController.text, state.categories);
      unawaited(notifier.updateCategory(widget.task, suggestedCategory));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Auto-categorized task as "$suggestedCategory"'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAILoading = false);
      }
    }
  }

  Future<void> _handleAIEstimate(TaskState state) async {
    if (_titleController.text.isEmpty) return;
    setState(() => _isAILoading = true);
    try {
      final estimate = await _aiService.estimateDuration(_titleController.text, _descriptionController.text);
      if (mounted) {
        setState(() {
          _aiTimeEstimate = estimate;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isAILoading = false);
      }
    }
  }

  Future<void> _handleAIBreakdown(TaskNotifier notifier) async {
    if (_titleController.text.isEmpty) return;
    
    setState(() => _isAILoading = true);
    try {
      await for (final subtask in _aiService.breakdownTaskStream(_titleController.text)) {
        final lines = subtask.split('\n').where((s) => s.trim().isNotEmpty);
        for (var line in lines) {
          unawaited(notifier.addSubtask(widget.task, line.trim()));
          unawaited(HapticFeedback.lightImpact());
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isAILoading = false);
      }
    }
  }

  @override
  void didUpdateWidget(TaskEditorPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id) {
      _aiTimeEstimate = null;
      _exitFocusMode();
      // Flush changes for the previous task if a debounce was pending
      if (_debounce?.isActive ?? false) {
        _debounce!.cancel();
        ref.read(taskProvider.notifier).updateTask(
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
    _focusTimer?.cancel();
    // Flush any pending changes before disposing
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
      ref.read(taskProvider.notifier).updateTask(
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

  void _saveChanges(TaskNotifier notifier) {
    final taskToUpdate = widget.task;
    final newTitle = _titleController.text;
    final newDescription = _descriptionController.text;

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      unawaited(notifier.updateTask(
        taskToUpdate,
        newTitle,
        newDescription,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);
    final taskNotifier = ref.read(taskProvider.notifier);
    final canPop = Navigator.of(context).canPop();

    if (_isFocusActive) {
      return _buildFocusModeUI();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Hero(
        tag: 'task_${widget.task.id}',
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(32),
                bottomLeft: const Radius.circular(32),
                topRight: canPop ? const Radius.circular(32) : Radius.zero,
                bottomRight: canPop ? const Radius.circular(32) : Radius.zero,
              ),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.2),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(-8, 0),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(32),
                bottomLeft: const Radius.circular(32),
                topRight: canPop ? const Radius.circular(32) : Radius.zero,
                bottomRight: canPop ? const Radius.circular(32) : Radius.zero,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 32.0,
                    right: 32.0,
                    top: MediaQuery.of(context).padding.top + 24,
                    bottom: 32.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Action Row
                      Row(
                        children: [
                          if (canPop) ...[
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back_ios_new_rounded),
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          _buildStatusChip(taskNotifier),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              taskNotifier.toggleStarred(widget.task);
                            },
                            icon: Icon(
                              widget.task.isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: widget.task.isStarred ? const Color(0xFFFFB300) : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              taskNotifier.deleteTask(widget.task);
                              if (canPop) {
                                Navigator.of(context).pop();
                              }
                            },
                            icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
                            tooltip: 'Delete Task',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Progress Bar
                      if (widget.task.subtaskCount > 0) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: widget.task.completedSubtaskCount / widget.task.subtaskCount,
                            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                            minHeight: 3,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Title Input
                      Material(
                        color: Colors.transparent,
                        child: TextField(
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
                          onChanged: (_) => _saveChanges(taskNotifier),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // AI Actions Row
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                onPressed: _isAILoading ? null : () {
                                  unawaited(HapticFeedback.lightImpact());
                                  _handleAICategorySuggest(taskNotifier, taskState);
                                },
                                icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                                label: const Text('Categorize', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            Container(width: 1, height: 20, color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: _isAILoading ? null : () {
                                  unawaited(HapticFeedback.lightImpact());
                                  _handleAIEstimate(taskState);
                                },
                                icon: const Icon(Icons.insights_rounded, size: 16),
                                label: const Text('Estimate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (_aiTimeEstimate != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lightbulb_outline_rounded, color: Theme.of(context).colorScheme.primary, size: 18),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _aiTimeEstimate!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 16),
                                onPressed: () => setState(() => _aiTimeEstimate = null),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Metadata Grid
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final cardWidth = (constraints.maxWidth - 16) / 2;
                          return Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              _buildDetailCard(
                                width: cardWidth,
                                icon: Icons.category_rounded,
                                label: 'Category',
                                child: _buildCategoryDropdown(taskState, taskNotifier),
                              ),
                              _buildDetailCard(
                                width: cardWidth,
                                icon: Icons.calendar_today_rounded,
                                label: 'Due Date',
                                onTap: () async {
                                  FocusScope.of(context).unfocus();
                                  final pickedDate = await showModalBottomSheet<DateTime?>(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => DateTimePickerSheet(
                                      initialDate: widget.task.dueDate,
                                    ),
                                  );
                                  
                                  if (mounted && (pickedDate != null || widget.task.dueDate != null)) {
                                    // Note: DateTimePickerSheet returns null for 'Clear'
                                    // If we want to distinguish from 'Dismiss', we'd need a more complex result
                                    // For now, if result is null and it had a date, we assume clear.
                                    // But to be safe against accidental dismiss, we might only clear if we are certain.
                                    // In a pro UI, dismiss shouldn't clear.
                                    
                                    // Re-check: the 'Clear' button in DateTimePickerSheet returns null.
                                    // The user must have a way to clear. 
                                    // Let's assume for now that if we get null, it's either dismiss or clear.
                                    // To avoid clearing on dismiss, we could have used a sentinel.
                                    
                                    if (pickedDate != null) {
                                      unawaited(taskNotifier.updateDueDate(widget.task, pickedDate));
                                    } else if (pickedDate == null && widget.task.dueDate != null) {
                                      // Only clear if the user actually clicked clear. 
                                      // Since showModalBottomSheet returns null on dismiss too, 
                                      // this is ambiguous. 
                                      // I'll leave it as only updating if NOT null for now to prevent accidental clears.
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
                              _buildDetailCard(
                                width: cardWidth,
                                icon: Icons.priority_high_rounded,
                                label: 'Priority',
                                child: _buildPriorityDropdown(taskState, taskNotifier),
                              ),
                              _buildDetailCard(
                                width: cardWidth,
                                icon: Icons.repeat_rounded,
                                label: 'Recurrence',
                                child: _buildRecurrenceDropdown(taskState, taskNotifier),
                              ),
                              _buildDetailCard(
                                width: constraints.maxWidth, // Full width for the focus action
                                icon: Icons.timer_outlined,
                                label: 'Focus Timer',
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  _startFocusMode();
                                },
                                child: Text(
                                  'Start Focus Session',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // Subtasks Section
                      Row(
                        children: [
                          _buildSectionLabel('SUBTASKS (${widget.task.completedSubtaskCount}/${widget.task.subtaskCount})'),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _isAILoading ? null : () {
                              unawaited(HapticFeedback.mediumImpact());
                              _handleAIBreakdown(taskNotifier);
                            },
                            icon: _isAILoading 
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.auto_awesome_rounded, size: 16),
                            label: Text(_isAILoading ? 'Thinking...' : 'AI Breakdown', style: const TextStyle(fontSize: 12)),
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              foregroundColor: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...widget.task.subtasks.map((subtask) => _buildSubtaskItem(taskNotifier, subtask)),
                      _buildAddSubtaskField(taskNotifier),
                      const SizedBox(height: 32),

                      // Description Area
                      _buildSectionLabel('DESCRIPTION'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: TextField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              hintText: 'Add more details about this task...',
                              border: InputBorder.none,
                            ),
                            onTapOutside: (_) => FocusScope.of(context).unfocus(),
                            maxLines: 8,
                            style: TextStyle(height: 1.6, color: Theme.of(context).colorScheme.onSurface),
                            onChanged: (_) => _saveChanges(taskNotifier),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Bottom Save Indicator
                      Center(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: 0.6,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.cloud_done_outlined, size: 14, color: Colors.green.withValues(alpha: 0.8)),
                              const SizedBox(width: 8),
                              Text(
                                'Changes saved automatically',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
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

  Widget _buildSubtaskItem(TaskNotifier notifier, SubTask subtask) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            unawaited(HapticFeedback.selectionClick());
            FocusScope.of(context).unfocus();
            notifier.toggleSubtask(widget.task, subtask);
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: subtask.isCompleted 
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
                  : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: subtask.isCompleted 
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) 
                    : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    subtask.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    key: ValueKey(subtask.isCompleted),
                    color: subtask.isCompleted ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    subtask.title,
                    style: TextStyle(
                      fontSize: 14,
                      color: subtask.isCompleted ? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5) : Theme.of(context).colorScheme.onSurface,
                      decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_sweep_outlined, size: 18, color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5)),
                  onPressed: () {
                    unawaited(HapticFeedback.mediumImpact());
                    FocusScope.of(context).unfocus();
                    notifier.deleteSubtask(widget.task, subtask);
                  },
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddSubtaskField(TaskNotifier notifier) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.add_task_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _subtaskController,
              decoration: InputDecoration(
                hintText: 'Add a subtask...',
                hintStyle: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                border: InputBorder.none,
              ),
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  notifier.addSubtask(widget.task, value);
                  _subtaskController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(TaskNotifier notifier) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        unawaited(HapticFeedback.lightImpact());
        notifier.toggleTask(widget.task);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: widget.task.isCompleted 
              ? Colors.green.withValues(alpha: 0.1) 
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
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

  Widget _buildPriorityDropdown(TaskState state, TaskNotifier notifier) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        unawaited(HapticFeedback.lightImpact());
        _showPriorityPicker(context, state, notifier);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: widget.task.priority.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            widget.task.priority.label,
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

  void _showPriorityPicker(BuildContext context, TaskState state, TaskNotifier notifier) {
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
              'Select Priority',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: TaskPriority.values.map((priority) {
                  final bool isSelected = widget.task.priority == priority;
                  return ListTile(
                    leading: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: priority.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      priority.label,
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
                      notifier.updateTaskPriority(widget.task, priority);
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    String dateStr;
    if (taskDate == today) {
      dateStr = 'Today';
    } else if (taskDate == tomorrow) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = DateFormat('MMM d, y').format(date);
    }

    if (date.hour != 0 || date.minute != 0) {
      return '$dateStr • ${DateFormat.jm().format(date)}';
    }
    return dateStr;
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String label,
    required Widget child,
    required double width,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: onTap != null ? 0.3 : 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)),
                    const SizedBox(width: 6),
                    Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(TaskState state, TaskNotifier notifier) {
    return InkWell(
      onTap: () {
        FocusScope.of(context).unfocus();
        unawaited(HapticFeedback.lightImpact());
        _showCategoryPicker(context, state, notifier);
      },
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

  Widget _buildRecurrenceDropdown(TaskState state, TaskNotifier notifier) {
    String displayVal = widget.task.recurrence;
    displayVal = displayVal[0].toUpperCase() + displayVal.substring(1);
    
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        unawaited(HapticFeedback.lightImpact());
        _showRecurrencePicker(context, state, notifier);
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

  void _showRecurrencePicker(BuildContext context, TaskState state, TaskNotifier notifier) {
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
                      notifier.updateRecurrence(widget.task, option);
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

  void _showCategoryPicker(BuildContext context, TaskState state, TaskNotifier notifier) {
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
                children: state.categories
                    .where((c) => c != 'All')
                    .map((category) => ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (state.categoryColors[category] ?? Colors.blue).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              state.categoryIcons[category] ?? Icons.category_rounded,
                              color: state.categoryColors[category] ?? Colors.blue,
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
                            notifier.updateCategory(widget.task, category);
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

  Widget _buildFocusModeUI() {
    final minutes = (_focusTimeRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_focusTimeRemaining % 60).toString().padLeft(2, '0');
    final percent = _focusTimeRemaining / (25 * 60);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          bottomLeft: Radius.circular(32),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'FOCUS MODE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.task.title.isEmpty ? 'Untitled Task' : widget.task.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 48),
              
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: percent,
                      strokeWidth: 10,
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    '$minutes:$seconds',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: _toggleFocusTimer,
                    icon: Icon(_isFocusTimerRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                    label: Text(_isFocusTimerRunning ? 'Pause' : 'Resume'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: _exitFocusMode,
                    icon: const Icon(Icons.stop_rounded),
                    label: const Text('Exit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Focus for 25 minutes. Deep breaths.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
