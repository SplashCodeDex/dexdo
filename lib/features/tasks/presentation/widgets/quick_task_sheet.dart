import 'package:dexdo/core/services/ai_service.dart';
import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:dexdo/features/tasks/presentation/providers/task_provider.dart';
import 'package:dexdo/features/tasks/presentation/widgets/date_time_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class QuickTaskSheet extends ConsumerStatefulWidget {
  const QuickTaskSheet({super.key});

  @override
  ConsumerState<QuickTaskSheet> createState() => _QuickTaskSheetState();
}

class _QuickTaskSheetState extends ConsumerState<QuickTaskSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final AIService _aiService = AIService();
  TaskPriority _priority = TaskPriority.low;
  DateTime? _dueDate;
  bool _isAILoading = false;
  String? _suggestedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text.trim().isEmpty) return;
    
    ref.read(taskProvider.notifier).addTask(
          title: _controller.text.trim(),
          dueDate: _dueDate,
          priority: _priority,
          category: _suggestedCategory,
        );
    Navigator.pop(context);
  }

  Future<void> _handleAISuggestions() async {
    final title = _controller.text.trim();
    if (title.isEmpty) return;

    setState(() => _isAILoading = true);
    try {
      final state = ref.read(taskProvider);
      final category = await _aiService.suggestCategory(title, state.categories);
      if (mounted) {
        setState(() {
          _suggestedCategory = category;
          _isAILoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isAILoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, bottomInset + 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'I want to...',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                      fontSize: 18,
                    ),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  onSubmitted: (_) => _submit(),
                  onChanged: (val) {
                    if (val.length > 3 && val.endsWith(' ')) {
                      _handleAISuggestions();
                    }
                  },
                ),
              ),
              if (_isAILoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                onPressed: _submit,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildActionChip(
                icon: Icons.calendar_today_rounded,
                label: _dueDate == null ? 'Set Date' : _formatDate(_dueDate!),
                onTap: _selectDate,
                isSelected: _dueDate != null,
              ),
              const SizedBox(width: 8),
              _buildActionChip(
                icon: Icons.priority_high_rounded,
                label: _priority.label,
                onTap: _selectPriority,
                isSelected: _priority != TaskPriority.low,
                color: _priority.color,
              ),
              if (_suggestedCategory != null) ...[
                const SizedBox(width: 8),
                _buildActionChip(
                  icon: Icons.auto_awesome_rounded,
                  label: _suggestedCategory!,
                  onTap: () => setState(() => _suggestedCategory = null),
                  isSelected: true,
                  color: Colors.purple,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isSelected = false,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? (color ?? theme.colorScheme.primary).withOpacity(0.1)
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? (color ?? theme.colorScheme.primary).withOpacity(0.2)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? (color ?? theme.colorScheme.primary) : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? (color ?? theme.colorScheme.primary) : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DateTimePickerSheet(
        initialDate: _dueDate,
        includeTime: false,
      ),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _selectPriority() {
    final next = TaskPriority.values[(_priority.index + 1) % TaskPriority.values.length];
    setState(() => _priority = next);
    HapticFeedback.lightImpact();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (DateUtils.isSameDay(date, now)) return 'Today';
    return DateFormat('MMM d').format(date);
  }
}
