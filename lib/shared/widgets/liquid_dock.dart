import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:dexdo/core/services/ai_service.dart';
import 'package:dexdo/core/services/audio_service.dart';
import 'package:dexdo/core/services/speech_service.dart';
import 'package:dexdo/core/services/toast_service.dart';
import 'package:dexdo/core/utils/haptics.dart';
import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:dexdo/features/tasks/presentation/providers/task_provider.dart';
import 'package:dexdo/features/tasks/presentation/widgets/date_time_picker_sheet.dart';
import 'package:dexdo/shared/widgets/liquid_dock_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class LiquidDockActiveNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle(bool isActive) {
    state = isActive;
  }
}

/// Provider to coordinate visual active input state of the liquid dock (e.g. for the scrim overlay)
final liquidDockInputActiveProvider = NotifierProvider<LiquidDockActiveNotifier, bool>(() {
  return LiquidDockActiveNotifier();
});

/// Dock animation phases
enum LiquidDockPhase { dock, merging, input, splitting }

/// FAB icon states during the dock lifecycle
enum FabIconState { plus, mic, arrowUp }

/// The Liquid Morphing Dock — a physics-based coalescence animation
/// where the FAB (small droplet) absorbs into the Navbar (large droplet)
/// to form a unified glassmorphic input field.
///
/// Replaces the traditional bottom nav + FAB + modal sheet pattern
/// with a single unified liquid morphing interaction.
class LiquidDock extends ConsumerStatefulWidget {
  const LiquidDock({
    super.key,
    required this.selectedIndex,
    required this.onNavIndexChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onNavIndexChanged;

  @override
  ConsumerState<LiquidDock> createState() => _LiquidDockState();
}

class _LiquidDockState extends ConsumerState<LiquidDock>
    with TickerProviderStateMixin {
  // ── State ──
  LiquidDockPhase _phase = LiquidDockPhase.dock;
  FabIconState _fabIcon = FabIconState.plus;

  // ── Animation Controllers ──
  late AnimationController _mergeController;
  late AnimationController _fabIconController;
  late AnimationController _voiceScaleController;
  late AnimationController _voiceMorphController;

  // ── Text Input ──
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final AIService _aiService = AIService();

  // ── Task attributes ──
  TaskPriority _priority = TaskPriority.low;
  DateTime? _dueDate;
  bool _isAILoading = false;
  String? _suggestedCategory;

  // ── Nav items ──
  static const _navItems = [
    _NavItemData(Icons.space_dashboard_outlined, Icons.space_dashboard_rounded, 'Home'),
    _NavItemData(Icons.calendar_today_outlined, Icons.calendar_today_rounded, 'Schedule'),
    _NavItemData(Icons.check_circle_outline_rounded, Icons.check_circle_rounded, 'Tasks'),
    _NavItemData(Icons.insights_outlined, Icons.insights_rounded, 'Insights'),
  ];

  @override
  void initState() {
    super.initState();

    _mergeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..addStatusListener(_onMergeStatusChanged);

    _fabIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _voiceScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _voiceMorphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _mergeController.removeStatusListener(_onMergeStatusChanged);
    _mergeController.dispose();
    _fabIconController.dispose();
    _voiceScaleController.dispose();
    _voiceMorphController.dispose();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════
  //  Animation Status Handling
  // ═══════════════════════════════════════════════════════════════════

  void _onMergeStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && _phase == LiquidDockPhase.merging) {
      // Merge completed → enter input mode
      setState(() {
        _phase = LiquidDockPhase.input;
        _fabIcon = FabIconState.mic;
      });
      // Haptic: merge complete
      unawaited(AppHaptics.medium());

      // Auto-focus the text input
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    } else if (status == AnimationStatus.dismissed && _phase == LiquidDockPhase.splitting) {
      // Split completed → back to dock mode
      setState(() {
        _phase = LiquidDockPhase.dock;
        _fabIcon = FabIconState.plus;
      });
      // Reset input state
      _textController.clear();
      _priority = TaskPriority.low;
      _dueDate = null;
      _suggestedCategory = null;
      _isAILoading = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  User Interactions
  // ═══════════════════════════════════════════════════════════════════

  void _onFabTap() {
    if (_phase == LiquidDockPhase.dock) {
      // Start merge animation
      setState(() => _phase = LiquidDockPhase.merging);
      ref.read(liquidDockInputActiveProvider.notifier).toggle(true);
      HapticFeedback.lightImpact(); // Haptic: neck forms

      // Schedule a haptic at 40% (neck formation point)
      Future.delayed(const Duration(milliseconds: 180), () {
        if (mounted && _phase == LiquidDockPhase.merging) {
          HapticFeedback.lightImpact();
        }
      });

      _mergeController.forward(from: 0.0);
    } else if (_phase == LiquidDockPhase.input) {
      if (_fabIcon == FabIconState.arrowUp) {
        _submitTask();
      }
      // mic state: no action on tap (mic is for visual state only, voice is long-press)
    }
  }

  void _onFabLongPressStart(LongPressStartDetails details) {
    // Voice input only available in dock mode
    if (_phase != LiquidDockPhase.dock) return;
    _startVoiceListening();
  }

  Future<void> _onFabLongPressEnd(LongPressEndDetails details) async {
    final speechState = ref.read(speechProvider);
    if (!speechState.isListening && !speechState.isProcessing) return;

    // Release voice mode
    ref.read(speechProvider.notifier).setProcessing(true);

    final finalTranscript = speechState.lastWords.trim();
    await ref.read(speechProvider.notifier).stopListening();

    if (finalTranscript.isNotEmpty) {
      unawaited(AppHaptics.success());

      // Parse with Gemini NLP
      final parsed = await ref.read(taskProvider.notifier)
          .parseVoiceCommand(finalTranscript);

      // Create the task with parsed attributes
      await ref.read(taskProvider.notifier).addTask(
        title: parsed.title,
        dueDate: parsed.dueDate,
        priority: parsed.priority,
        category: parsed.category,
      );

      final createdTask = ref.read(taskProvider).tasks.first;

      // Populate subtasks if generated by AI
      if (parsed.subtasks != null && parsed.subtasks!.isNotEmpty) {
        for (var sub in parsed.subtasks!) {
          await ref.read(taskProvider.notifier).addSubtask(createdTask, sub);
        }
      }

      unawaited(AppHaptics.taskCreatedFromVoice());
      ref.read(toastProvider.notifier).showSuccess(
        'Task created: "${parsed.title}"',
        title: 'Voice Task Created',
        actionLabel: 'Undo',
        onAction: () {
          ref.read(taskProvider.notifier).deleteTask(createdTask);
        },
      );
    } else {
      ref.read(toastProvider.notifier).showWarning(
        'No speech recognized. Please try again.',
      );
    }

    ref.read(speechProvider.notifier).setProcessing(false);
    _resetVoice();
  }

  void _dismissDock() {
    FocusScope.of(context).unfocus();
    setState(() => _phase = LiquidDockPhase.splitting);
    ref.read(liquidDockInputActiveProvider.notifier).toggle(false);
    _mergeController.reverse();
  }

  // ═══════════════════════════════════════════════════════════════════
  //  Voice Recording (mirrors SmartFab logic)
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _startVoiceListening() async {
    unawaited(AppHaptics.voiceModeEnter());
    unawaited(AudioService.playVoiceTriggerSound());
    unawaited(_voiceMorphController.forward());
    unawaited(_voiceScaleController.animateTo(1.0, curve: Curves.elasticOut));

    await Future.delayed(const Duration(milliseconds: 400));
    await AudioService.muteSpeechRecognizerBeep();
    await ref.read(speechProvider.notifier).startListening();

    unawaited(Future.delayed(const Duration(milliseconds: 1200), () {
      AudioService.unmuteSpeechRecognizerBeep();
    }));
  }

  void _resetVoice() {
    unawaited(ref.read(speechProvider.notifier).cancelListening());
    unawaited(AudioService.unmuteSpeechRecognizerBeep());
    unawaited(_voiceScaleController.animateTo(0.0, curve: Curves.easeOut));
    unawaited(_voiceMorphController.reverse());
  }

  // ═══════════════════════════════════════════════════════════════════
  //  Text Input Handling
  // ═══════════════════════════════════════════════════════════════════

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    final newIcon = hasText ? FabIconState.arrowUp : FabIconState.mic;
    if (_fabIcon != newIcon && _phase == LiquidDockPhase.input) {
      setState(() => _fabIcon = newIcon);
    }

    // AI category suggestion trigger
    final val = _textController.text;
    if (val.length > 3 && val.endsWith(' ')) {
      _handleAISuggestions();
    }
  }

  Future<void> _handleAISuggestions() async {
    final title = _textController.text.trim();
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

  void _submitTask() {
    final title = _textController.text.trim();
    if (title.isEmpty) return;

    ref.read(taskProvider.notifier).addTask(
      title: title,
      dueDate: _dueDate,
      priority: _priority,
      category: _suggestedCategory,
    );

    unawaited(AppHaptics.success());

    // Trigger reverse split animation
    _dismissDock();
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
    if (picked != null && mounted) {
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

  // ═══════════════════════════════════════════════════════════════════
  //  Build
  // ═══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isInputActive = _phase == LiquidDockPhase.input ||
        _phase == LiquidDockPhase.merging ||
        _phase == LiquidDockPhase.splitting;

    // Listen to the coordinate active input state provider to handle dismissal
    ref.listen<bool>(liquidDockInputActiveProvider, (previous, next) {
      if (!next &&
          (_phase == LiquidDockPhase.input || _phase == LiquidDockPhase.merging)) {
        _dismissDock();
      }
    });

    return AnimatedBuilder(
      animation: _mergeController,
      builder: (context, child) {
        final progress = _mergeController.value;

        // Compute slideT and smoothT for exact visual tracking of the FAB droplet
        final double slideT = Curves.easeInOutCubic.transform(
          (progress / 0.4).clamp(0.0, 1.0),
        );
        final double smoothT = Curves.easeInOutCubic.transform(
          ((progress - 0.4) / 0.6).clamp(0.0, 1.0),
        );

        // Calculate active overlay right-offset to track the background circle
        final double fabRightOffset = progress <= 0.4
            ? LiquidDockPathGenerator.gapWidth * slideT
            : LiquidDockPathGenerator.gapWidth * (1.0 - smoothT);

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              LiquidDockPathGenerator.horizontalPadding,
              0,
              LiquidDockPathGenerator.horizontalPadding,
              // When keyboard is up and we're in input mode, add bottom inset
              isInputActive && bottomInset > 0
                  ? bottomInset + 8
                  : LiquidDockPathGenerator.horizontalPadding,
            ),
            child: SizedBox(
              width: double.infinity,
              height: LiquidDockPathGenerator.dockHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── Shadow layer ──
                  RepaintBoundary(
                    child: CustomPaint(
                      painter: LiquidDockShadowPainter(
                        progress: progress,
                        shadowColor: Colors.black.withValues(alpha: 0.2),
                      ),
                      child: const SizedBox(
                        width: double.infinity,
                        height: LiquidDockPathGenerator.dockHeight,
                      ),
                    ),
                  ),

                  // ── Glassmorphic body (clipped backdrop + fill) ──
                  ClipPath(
                    clipper: LiquidDockClipper(progress: progress),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        height: LiquidDockPathGenerator.dockHeight,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface.withValues(
                            alpha: isDark ? 0.7 : 0.8,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Border stroke ──
                  RepaintBoundary(
                    child: CustomPaint(
                      painter: LiquidDockBorderPainter(
                        progress: progress,
                        borderColor: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.black.withValues(alpha: 0.15),
                      ),
                      child: const SizedBox(
                        width: double.infinity,
                        height: LiquidDockPathGenerator.dockHeight,
                      ),
                    ),
                  ),

                  // ── Content layer ──
                  SizedBox(
                    height: LiquidDockPathGenerator.dockHeight,
                    child: Stack(
                      children: [
                        // Nav items (visible in dock mode, fades out during merge)
                        Opacity(
                          opacity: (1.0 - progress * 2.5).clamp(0.0, 1.0),
                          child: IgnorePointer(
                            ignoring: progress > 0.1,
                            child: Center(
                              child: _buildNavItems(),
                            ),
                          ),
                        ),

                        // Input field (fades in during merge)
                        Opacity(
                          opacity: ((progress - 0.6) / 0.4).clamp(0.0, 1.0),
                          child: IgnorePointer(
                            ignoring: _phase != LiquidDockPhase.input,
                            child: _buildInputField(),
                          ),
                        ),

                        // FAB overlay (always present, changes icon state)
                        Positioned(
                          right: fabRightOffset,
                          top: 0,
                          bottom: 0,
                          child: _buildFabOverlay(progress, isDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  Sub-widgets
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildNavItems() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: _navBarWidth(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_navItems.length, (i) {
            final item = _navItems[i];
            final isSelected = widget.selectedIndex == i;
            return _buildNavItem(
              item.unselectedIcon,
              item.selectedIcon,
              i,
              item.label,
              isSelected,
            );
          }),
        ),
      ),
    );
  }

  double _navBarWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth
        - (LiquidDockPathGenerator.horizontalPadding * 2)
        - LiquidDockPathGenerator.gapWidth
        - LiquidDockPathGenerator.fabDiameter;
  }

  Widget _buildNavItem(
    IconData unselectedIcon,
    IconData selectedIcon,
    int index,
    String label,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        widget.onNavIndexChanged(index);
        HapticFeedback.lightImpact();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 12 : 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isSelected ? selectedIcon : unselectedIcon,
                key: ValueKey(isSelected),
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                size: 24,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: Alignment.centerLeft,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: -0.2,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: LiquidDockPathGenerator.fabDiameter + 8,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text field
          SizedBox(
            height: 32,
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'I want to...',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              onSubmitted: (_) => _submitTask(),
            ),
          ),
          const SizedBox(height: 2),
          // Action chips row
          SizedBox(
            height: 24,
            child: Row(
              children: [
                _buildChip(
                  icon: Icons.calendar_today_rounded,
                  label: _dueDate == null ? 'Date' : _formatDate(_dueDate!),
                  onTap: _selectDate,
                  isSelected: _dueDate != null,
                ),
                const SizedBox(width: 6),
                _buildChip(
                  icon: Icons.priority_high_rounded,
                  label: _priority.label,
                  onTap: _selectPriority,
                  isSelected: _priority != TaskPriority.low,
                  color: _priority.color,
                ),
                if (_suggestedCategory != null) ...[
                  const SizedBox(width: 6),
                  _buildChip(
                    icon: Icons.auto_awesome_rounded,
                    label: _suggestedCategory!,
                    onTap: () => setState(() => _suggestedCategory = null),
                    isSelected: true,
                    color: Colors.purple,
                  ),
                ],
                if (_isAILoading) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isSelected = false,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? theme.colorScheme.primary).withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? (color ?? theme.colorScheme.primary).withValues(alpha: 0.2)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 11,
              color: isSelected
                  ? (color ?? theme.colorScheme.primary)
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? (color ?? theme.colorScheme.primary)
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFabOverlay(double progress, bool isDark) {
    // During voice mode, scale and morph the FAB
    return ListenableBuilder(
      listenable: Listenable.merge([_voiceScaleController, _voiceMorphController]),
      builder: (context, child) {
        final double voiceScale = 1.0 + (_voiceScaleController.value * 0.2);
        final double voiceMorph = _voiceMorphController.value;

        return GestureDetector(
          onTap: _onFabTap,
          onLongPressStart: _onFabLongPressStart,
          onLongPressEnd: _onFabLongPressEnd,
          behavior: HitTestBehavior.opaque,
          child: Transform.scale(
            scale: _phase == LiquidDockPhase.dock ? voiceScale : 1.0,
            child: SizedBox(
              width: LiquidDockPathGenerator.fabDiameter,
              height: LiquidDockPathGenerator.dockHeight,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: _buildFabIcon(voiceMorph, isDark),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFabIcon(double voiceMorph, bool isDark) {
    // Voice morph overrides in dock mode
    if (_phase == LiquidDockPhase.dock && voiceMorph > 0.5) {
      return Icon(
        Icons.mic_none_rounded,
        key: const ValueKey('voice_mic'),
        color: isDark ? Colors.white : Colors.black87,
        size: 28,
      );
    }

    switch (_fabIcon) {
      case FabIconState.plus:
        return Transform.rotate(
          angle: voiceMorph * math.pi / 4,
          child: Icon(
            Icons.add_rounded,
            key: const ValueKey('fab_plus'),
            color: isDark ? Colors.white : Colors.black87,
            size: 32,
          ),
        );
      case FabIconState.mic:
        return Icon(
          Icons.mic_none_rounded,
          key: const ValueKey('fab_mic'),
          color: isDark ? Colors.white : Colors.black87,
          size: 26,
        );
      case FabIconState.arrowUp:
        return Container(
          key: const ValueKey('fab_arrow_up'),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_upward_rounded,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 20,
          ),
        );
    }
  }
}

// ── Helper data class ──
class _NavItemData {
  const _NavItemData(this.unselectedIcon, this.selectedIcon, this.label);

  final IconData unselectedIcon;
  final IconData selectedIcon;
  final String label;
}
