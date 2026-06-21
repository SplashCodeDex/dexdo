import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:dexdo/core/services/audio_service.dart';
import 'package:dexdo/core/services/speech_service.dart';
import 'package:dexdo/core/services/toast_service.dart';
import 'package:dexdo/core/utils/haptics.dart';
import 'package:dexdo/features/tasks/domain/entities/task.dart';
import 'package:dexdo/features/tasks/presentation/providers/task_provider.dart';
import 'package:dexdo/features/tasks/presentation/widgets/quick_task_sheet.dart';
import 'package:dexdo/features/tasks/presentation/widgets/template_picker_sheet.dart';
import 'package:dexdo/shared/widgets/radial_menu_item.dart';
import 'package:dexdo/shared/widgets/voice_preview_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SmartFabPhase { idle, level1, level2 }

class SmartFab extends ConsumerStatefulWidget {
  const SmartFab({super.key});

  @override
  ConsumerState<SmartFab> createState() => _SmartFabState();
}

class _SmartFabState extends ConsumerState<SmartFab> with TickerProviderStateMixin {
  SmartFabPhase _phase = SmartFabPhase.idle;
  Timer? _level2Timer;
  Offset _dragOffset = Offset.zero;
  int _hoveredItemIndex = -1;
  bool _isProcessingAI = false;

  // Animation Controllers
  late AnimationController _scaleController;
  late AnimationController _radialController;
  late AnimationController _morphController;

  // Staggered scales for radial items
  final List<Animation<double>> _itemScaleAnimations = [];

  // Radial angles & items configuration (fanning out into the top-left quadrant)
  final List<double> _radialAngles = [-1.4, -1.9, -2.4, -2.9];
  final double _radialDistance = 110.0;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _radialController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Staggered scale animations for radial items
    for (int i = 0; i < 4; i++) {
      final start = 0.1 * i;
      final end = (start + 0.5).clamp(0.0, 1.0);
      _itemScaleAnimations.add(
        CurvedAnimation(
          parent: _radialController,
          curve: Interval(start, end, curve: Curves.elasticOut),
        ),
      );
    }
  }

  @override
  void dispose() {
    _level2Timer?.cancel();
    _scaleController.dispose();
    _radialController.dispose();
    _morphController.dispose();
    super.dispose();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    if (_phase != SmartFabPhase.idle) return;

    setState(() {
      _phase = SmartFabPhase.level1;
      _dragOffset = Offset.zero;
      _hoveredItemIndex = -1;
    });

    _scaleController.animateTo(0.85, curve: Curves.easeOutBack);
    _radialController.forward();

    // Schedule transition to Level 2 (Voice input) after 1.5 seconds of holding
    _level2Timer = Timer(const Duration(milliseconds: 1500), () {
      _transitionToLevel2();
    });
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (_phase == SmartFabPhase.idle) return;

    // Track touch position relative to the start position (FAB center)
    setState(() {
      _dragOffset = details.localOffsetFromOrigin;
    });

    // Check if dragging towards any radial menu item (if in Level 1)
    if (_phase == SmartFabPhase.level1) {
      final double distance = _dragOffset.distance;
      if (distance > 50 && distance < 170) {
        final double dragAngle = math.atan2(_dragOffset.dy, _dragOffset.dx);
        
        int bestIndex = -1;
        double minDiff = double.infinity;

        for (int i = 0; i < 4; i++) {
          final diff = (dragAngle - _radialAngles[i]).abs();
          if (diff < minDiff) {
            minDiff = diff;
            bestIndex = i;
          }
        }

        // Limit angle difference to accept selection (approx 35 degrees)
        if (minDiff < 0.6) {
          if (_hoveredItemIndex != bestIndex) {
            AppHaptics.light();
            setState(() {
              _hoveredItemIndex = bestIndex;
            });
          }
        } else {
          setState(() {
            _hoveredItemIndex = -1;
          });
        }
      } else {
        setState(() {
          _hoveredItemIndex = -1;
        });
      }
    }
  }

  Future<void> _onLongPressEnd(LongPressEndDetails details) async {
    _level2Timer?.cancel();

    if (_phase == SmartFabPhase.level1) {
      final int selectedIndex = _hoveredItemIndex;
      _resetFab();

      if (selectedIndex != -1) {
        _executeRadialAction(selectedIndex);
      }
    } else if (_phase == SmartFabPhase.level2) {
      // Release voice mode
      setState(() {
        _isProcessingAI = true;
      });

      // Stop listening and capture transcript
      final speechState = ref.read(speechProvider);
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

      setState(() {
        _isProcessingAI = false;
      });
      _resetFab();
    }
  }

  Future<void> _transitionToLevel2() async {
    _level2Timer?.cancel();
    if (_phase != SmartFabPhase.level1) return;

    setState(() {
      _phase = SmartFabPhase.level2;
      _hoveredItemIndex = -1;
    });

    unawaited(AppHaptics.voiceModeEnter());
    unawaited(AudioService.playVoiceTriggerSound());
    unawaited(_morphController.forward());
    unawaited(_scaleController.animateTo(1.2, curve: Curves.elasticOut)); // Grow the mic FAB slightly
    unawaited(_radialController.reverse()); // Collapse radial items
    // Start voice recording
    await ref.read(speechProvider.notifier).startListening();
  }

  void _resetFab() {
    _level2Timer?.cancel();
    unawaited(ref.read(speechProvider.notifier).cancelListening());
    
    unawaited(_scaleController.animateTo(0.0, curve: Curves.easeOut).then((_) {
      _scaleController.value = 0.0;
    }));
    unawaited(_radialController.reverse());
    unawaited(_morphController.reverse());

    setState(() {
      _phase = SmartFabPhase.idle;
      _hoveredItemIndex = -1;
      _dragOffset = Offset.zero;
    });
  }

  void _executeRadialAction(int index) {
    switch (index) {
      case 0: // Create Event
        // Navigate or show date picker dialog directly
        _showDatePickerAndCreateTask();
        break;
      case 1: // New Note / Journal Entry
        // Open Note category editor sheet
        ref.read(taskProvider.notifier).addTask(title: 'New Note', category: 'Personal');
        ref.read(toastProvider.notifier).showInfo(
          'Note task placeholder created',
          title: 'Note Created',
        );
        break;
      case 2: // New Folder / Project
        _showNewCategoryDialog();
        break;
      case 3: // Use a Template
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const TemplatePickerSheet(),
        );
        break;
    }
  }

  Future<void> _showDatePickerAndCreateTask() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (!mounted) return;
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      final DateTime finalDateTime = time != null
          ? DateTime(picked.year, picked.month, picked.day, time.hour, time.minute)
          : DateTime(picked.year, picked.month, picked.day, 9, 0);

      await ref.read(taskProvider.notifier).addTask(
        title: 'New Calendar Event',
        dueDate: finalDateTime,
        priority: TaskPriority.medium,
        category: 'Work',
      );

      ref.read(toastProvider.notifier).showSuccess(
        'Created calendar task synced for ${picked.toLocal().toString().split(' ')[0]}',
        title: 'Calendar Task Created',
      );
    }
  }

  void _showNewCategoryDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Folder/Category'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter category name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                ref.read(taskProvider.notifier).addCategory(
                  name,
                  Icons.folder_open_rounded,
                  Theme.of(context).colorScheme.primary,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final speechState = ref.watch(speechProvider);
    final taskState = ref.watch(taskProvider);

    // List of radial actions
    final List<Map<String, dynamic>> items = [
      {'icon': Icons.calendar_today_rounded, 'label': 'Event', 'color': Colors.blue},
      {'icon': Icons.note_alt_rounded, 'label': 'Note', 'color': Colors.teal},
      {'icon': Icons.folder_rounded, 'label': 'Folder', 'color': Colors.purple},
      {'icon': Icons.auto_awesome_motion_rounded, 'label': 'Template', 'color': Colors.orange},
    ];

    // FAB Button size mapping
    const double fabSize = 56.0;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [


        // RADIAL MENU ITEMS (Level 1)
        if (_phase == SmartFabPhase.level1)
          ...List.generate(4, (index) {
            final angle = _radialAngles[index];
            final bool isHovered = _hoveredItemIndex == index;

            // Calculate translation offset when fanned out
            final offset = Offset.fromDirection(angle, _radialDistance * _radialController.value);

            return Positioned(
              left: offset.dx + (fabSize / 2) - 27.0, // center on FAB
              top: offset.dy + (fabSize / 2) - 38.0,
              child: RadialMenuItem(
                icon: items[index]['icon'] as IconData,
                label: items[index]['label'] as String,
                color: items[index]['color'] as Color,
                scale: isHovered ? 1.25 : 1.0,
                opacity: _radialController.value,
                onTap: () {
                  _resetFab();
                  _executeRadialAction(index);
                },
              ),
            );
          }),

        // FLOATING VOICE PREVIEW WINDOW (Level 2)
        if (_phase == SmartFabPhase.level2)
          Positioned(
            bottom: 100,
            right: 0,
            child: IgnorePointer(
              ignoring: _isProcessingAI,
              child: VoicePreviewWindow(
                transcript: speechState.lastWords,
                categories: taskState.categories,
                isProcessing: _isProcessingAI,
              ),
            ),
          ),

        // MASTER FAB GESTURE WRAPPER
        GestureDetector(
          onLongPressStart: _onLongPressStart,
          onLongPressMoveUpdate: _onLongPressMoveUpdate,
          onLongPressEnd: _onLongPressEnd,
          onTap: () {
            // Tap behaviour (Default QuickTaskSheet bottom sheet)
            FocusScope.of(context).unfocus();
            HapticFeedback.mediumImpact();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const QuickTaskSheet(),
            );
          },
          child: ListenableBuilder(
            listenable: ListNotifier([_scaleController, _morphController]),
            builder: (context, child) {
              final double scale = 1.0 + (_scaleController.value * 0.2); // grows slightly in Level 2
              final double morph = _morphController.value;

              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: fabSize,
                  height: fabSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.25),
                          border: Border.all(
                            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
                            width: 1.0,
                          ),
                        ),
                        child: Center(
                          child: morph > 0.5
                              ? Icon(
                                  Icons.mic_none_rounded, // professional vertical mic icon
                                  color: isDark ? Colors.white : Colors.black87,
                                  size: 28,
                                )
                              : Transform.rotate(
                                  angle: morph * math.pi / 4, // rotate add icon slightly, leaving mic unrotated
                                  child: Icon(
                                    Icons.add_rounded,
                                    color: isDark ? Colors.white : Colors.black87,
                                    size: 32,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Utility class to listen to multiple animation controllers
class ListNotifier extends ChangeNotifier {
  ListNotifier(this.listenables) {
    for (final listenable in listenables) {
      listenable.addListener(notifyListeners);
    }
  }

  final List<Listenable> listenables;

  @override
  void dispose() {
    for (final listenable in listenables) {
      listenable.removeListener(notifyListeners);
    }
    super.dispose();
  }
}
