import 'dart:ui';
import 'package:dexdo/core/services/toast_service.dart';
import 'package:dexdo/features/tasks/domain/entities/task_templates.dart';
import 'package:dexdo/features/tasks/presentation/providers/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TemplatePickerSheet extends ConsumerStatefulWidget {
  const TemplatePickerSheet({super.key});

  @override
  ConsumerState<TemplatePickerSheet> createState() => _TemplatePickerSheetState();
}

class _TemplatePickerSheetState extends ConsumerState<TemplatePickerSheet> {
  final TextEditingController _aiController = TextEditingController();
  final TextEditingController _customNameController = TextEditingController();
  final List<TextEditingController> _subtaskControllers = [TextEditingController()];
  bool _isCreatingCustom = false;
  String _selectedCategoryForCustom = 'Personal';

  @override
  void dispose() {
    _aiController.dispose();
    _customNameController.dispose();
    for (var c in _subtaskControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);
    final templates = taskState.templates;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        decoration: BoxDecoration(
          color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.85),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
            width: 1.0,
          ),
        ),
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white30 : Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isCreatingCustom ? 'Create Custom Template' : 'Choose a Template',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                if (!_isCreatingCustom)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isCreatingCustom = true;
                      });
                    },
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                    label: const Text('Custom'),
                  )
                else
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isCreatingCustom = false;
                      });
                    },
                    child: const Text('Back'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (_isCreatingCustom)
              _buildCustomTemplateCreator(taskState.categories, isDark, colorScheme)
            else ...[
              // AI Generator section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: isDark 
                        ? [colorScheme.primary.withValues(alpha: 0.15), colorScheme.secondary.withValues(alpha: 0.05)]
                        : [colorScheme.primary.withValues(alpha: 0.08), colorScheme.secondary.withValues(alpha: 0.02)],
                  ),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _aiController,
                        decoration: InputDecoration(
                          hintText: 'Enter topic (e.g. "Moving App Checklist")',
                          hintStyle: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.black38),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.auto_awesome, color: colorScheme.primary, size: 20),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    taskState.isAILoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : TextButton(
                            onPressed: () async {
                              final text = _aiController.text.trim();
                              if (text.isEmpty) return;
                              FocusScope.of(context).unfocus();
                              final messenger = ScaffoldMessenger.of(context);
                              await ref.read(taskProvider.notifier).addTemplateFromAI(text);
                              if (!mounted) return;
                              _aiController.clear();
                              messenger.showSnackBar(
                                SnackBar(content: Text('AI generated template for "$text"')),
                              );
                            },
                            child: const Text('AI Generate'),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Templates List
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 350),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: templates.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final template = templates[index];
                      final isDefault = template.id.startsWith('template_grocery') ||
                                        template.id.startsWith('template_morning') ||
                                        template.id.startsWith('template_weekly_review') ||
                                        template.id.startsWith('template_workout');

                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04),
                          border: Border.all(
                            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                          ),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                              child: Icon(template.icon, color: colorScheme.primary),
                            ),
                            title: Text(
                              template.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${template.category} • ${template.subtaskTitles.length} items',
                              style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
                            ),
                            trailing: !isDefault
                                ? IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                    onPressed: () {
                                      ref.read(taskProvider.notifier).deleteTemplate(template.id);
                                    },
                                  )
                                : null,
                            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            children: [
                              ...template.subtaskTitles.map((title) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_box_outline_blank_rounded, size: 16, color: colorScheme.primary.withValues(alpha: 0.6)),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            title,
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  minimumSize: const Size(double.infinity, 44),
                                  elevation: 0,
                                ),
                                onPressed: () async {
                                  await ref.read(taskProvider.notifier).createTaskFromTemplate(template);
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                  final createdTask = ref.read(taskProvider).tasks.first;
                                  ref.read(toastProvider.notifier).showSuccess(
                                    'Created task checklist from "${template.name}"',
                                    title: 'Template Applied',
                                    actionLabel: 'Undo',
                                    onAction: () {
                                      ref.read(taskProvider.notifier).deleteTask(createdTask);
                                    },
                                  );
                                },
                                child: const Text('Use Template', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTemplateCreator(List<String> categories, bool isDark, ColorScheme colorScheme) {
    final cleanCategories = categories.where((c) => c != 'All').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Name Field
        TextField(
          controller: _customNameController,
          decoration: InputDecoration(
            labelText: 'Template Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.label_outline_rounded),
          ),
        ),
        const SizedBox(height: 12),

        // Category Picker
        DropdownButtonFormField<String>(
          initialValue: _selectedCategoryForCustom,
          decoration: InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.category_outlined),
          ),
          items: cleanCategories.map((c) {
            return DropdownMenuItem<String>(
              value: c,
              child: Text(c),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedCategoryForCustom = val;
              });
            }
          },
        ),
        const SizedBox(height: 16),

        // Subtasks Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Subtask Items',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              onPressed: () {
                setState(() {
                  _subtaskControllers.add(TextEditingController());
                });
              },
            ),
          ],
        ),

        // Subtask Input Fields
        Container(
          constraints: const BoxConstraints(maxHeight: 180),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: _subtaskControllers.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subtaskControllers[index],
                      decoration: InputDecoration(
                        hintText: 'Item ${index + 1}',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  if (_subtaskControllers.length > 1)
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent),
                      onPressed: () {
                        setState(() {
                          _subtaskControllers[index].dispose();
                          _subtaskControllers.removeAt(index);
                        });
                      },
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Save Button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 46),
            elevation: 0,
          ),
          onPressed: () async {
            final name = _customNameController.text.trim();
            if (name.isEmpty) return;

            final subtaskTitles = _subtaskControllers
                .map((c) => c.text.trim())
                .where((t) => t.isNotEmpty)
                .toList();

            if (subtaskTitles.isEmpty) return;

            final template = TaskTemplate(
              id: 'template_custom_${DateTime.now().millisecondsSinceEpoch}',
              name: name,
              icon: Icons.checklist_rtl_rounded,
              category: _selectedCategoryForCustom,
              subtaskTitles: subtaskTitles,
            );

            await ref.read(taskProvider.notifier).saveTemplate(template);
            setState(() {
              _isCreatingCustom = false;
              _customNameController.clear();
              for (var c in _subtaskControllers) {
                c.dispose();
              }
              _subtaskControllers.clear();
              _subtaskControllers.add(TextEditingController());
            });
          },
          child: const Text('Save Template', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
