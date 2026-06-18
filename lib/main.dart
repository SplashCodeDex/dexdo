import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:dexdo/core/app_bootstrap.dart';
import 'package:dexdo/core/theme/app_theme.dart';
import 'package:dexdo/core/theme/theme_provider.dart';
import 'package:dexdo/features/auth/presentation/providers/auth_provider.dart';
import 'package:dexdo/core/widgets/deferred_widget.dart';
import 'package:dexdo/features/calendar/presentation/widgets/calendar_pane.dart' deferred as calendar_pane;
import 'package:dexdo/features/home/presentation/widgets/home_pane.dart';
import 'package:dexdo/features/home/presentation/widgets/statistics_pane.dart' deferred as statistics_pane;
import 'package:dexdo/features/settings/presentation/widgets/settings_pane.dart' deferred as settings_pane;
import 'package:dexdo/features/tasks/presentation/providers/task_provider.dart';
import 'package:dexdo/features/tasks/presentation/providers/task_state.dart';
import 'package:dexdo/features/tasks/presentation/widgets/quick_task_sheet.dart';
import 'package:dexdo/features/tasks/presentation/widgets/task_editor_pane.dart';
import 'package:dexdo/features/tasks/presentation/widgets/task_list_pane.dart';
import 'package:dexdo/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable Edge-to-Edge mode to "get rid of" the status bar background
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  
  runApp(
    const rp.ProviderScope(
      child: DeXDoApp(),
    ),
  );
}

class DeXDoApp extends rp.ConsumerWidget {
  const DeXDoApp({super.key});

  @override
  Widget build(BuildContext context, rp.WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)?.appTitle ?? 'DeXDo',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const BootstrapScreen(),
    );
  }
}

class HomeScreen extends rp.ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  rp.ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class NewTaskIntent extends Intent {
  const NewTaskIntent();
}

class DeleteSelectedIntent extends Intent {
  const DeleteSelectedIntent();
}

class _HomeScreenState extends rp.ConsumerState<HomeScreen> {
  int _selectedIndex = 2; // Default to 'Tasks' icon

  Widget _buildBody(bool isLargeScreen, TaskState taskState, TaskNotifier notifier) {
    if (isLargeScreen) {
      return Row(
        children: [
          // Sidebar Navigation for Desktop
          _buildDesktopNavigationRail(),
          VerticalDivider(width: 1, color: Theme.of(context).dividerColor),
          
          // Content Area
          Expanded(
            child: _buildMainContent(isLargeScreen),
          ),
        ],
      );
    }

    return _buildMainContent(isLargeScreen);
  }

  Widget _buildDesktopNavigationRail() {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        FocusScope.of(context).unfocus();
        HapticFeedback.selectionClick();
        setState(() => _selectedIndex = index);
      },
      labelType: NavigationRailLabelType.selected,
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
      indicatorColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      selectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      unselectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurfaceVariant),
      selectedLabelTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
      unselectedLabelTextStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month_rounded),
          label: Text('Calendar'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.list_alt_rounded),
          selectedIcon: Icon(Icons.list_alt_rounded),
          label: Text('Tasks'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.insights_outlined),
          selectedIcon: Icon(Icons.insights_rounded),
          label: Text('Insights'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings_rounded),
          label: Text('Settings'),
        ),
      ],
    );
  }

  Widget _buildMainContent(bool isLargeScreen) {
    if (_selectedIndex != 2) {
      Widget content;
      switch (_selectedIndex) {
        case 0:
          content = HomePane(
            onTaskTap: (task) => setState(() => _selectedIndex = 2),
          );
          break;
        case 1:
          content = DeferredWidget(
            libraryKey: 'calendar',
            libraryLoader: calendar_pane.loadLibrary,
            builder: () => calendar_pane.CalendarPane(
              onTaskTap: (task) => setState(() => _selectedIndex = 2),
            ),
          );
          break;
        case 3:
          content = DeferredWidget(
            libraryKey: 'statistics',
            libraryLoader: statistics_pane.loadLibrary,
            builder: () => statistics_pane.StatisticsPane(),
          );
          break;
        case 4:
          content = DeferredWidget(
            libraryKey: 'settings',
            libraryLoader: settings_pane.loadLibrary,
            builder: () => settings_pane.SettingsPane(),
          );
          break;
        default:
          content = const Center(child: Text('Coming Soon'));
      }

      return PageTransitionSwitcher(
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
          return SharedAxisTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: content,
        ),
      );
    }

    if (isLargeScreen) {
      return Row(
        children: [
          const Expanded(
            flex: 2,
            child: TaskListPane(),
          ),
          VerticalDivider(width: 1, color: Theme.of(context).dividerColor),
          Expanded(
            flex: 3,
            child: Container(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
              child: rp.Consumer(
                builder: (context, ref, _) {
                  final selectedTask = ref.watch(taskProvider.select((s) => s.selectedTask));
                  return PageTransitionSwitcher(
                    transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                      return SharedAxisTransition(
                        animation: primaryAnimation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: SharedAxisTransitionType.horizontal,
                        child: child,
                      );
                    },
                    child: selectedTask != null
                        ? TaskEditorPane(
                            key: ValueKey(selectedTask.id),
                            task: selectedTask,
                          )
                        : const Center(
                            key: ValueKey('empty_editor'),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit_note_rounded, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'Select a task to view details',
                                  style: TextStyle(color: Colors.grey, fontSize: 16),
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
      );
    }

    return const TaskListPane();
  }

  @override
  Widget build(BuildContext context) {
    final taskNotifier = ref.read(taskProvider.notifier);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN): const NewTaskIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyN): const NewTaskIntent(),
        LogicalKeySet(LogicalKeyboardKey.delete): const DeleteSelectedIntent(),
        LogicalKeySet(LogicalKeyboardKey.backspace): const DeleteSelectedIntent(),
      },
      child: Actions(
        actions: {
          NewTaskIntent: CallbackAction<NewTaskIntent>(
            onInvoke: (NewTaskIntent intent) {
              FocusScope.of(context).unfocus();
              HapticFeedback.mediumImpact();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const QuickTaskSheet(),
              );
              if (_selectedIndex != 2) {
                setState(() => _selectedIndex = 2);
              }
              return null;
            },
          ),
          DeleteSelectedIntent: CallbackAction<DeleteSelectedIntent>(
            onInvoke: (DeleteSelectedIntent intent) {
              FocusScope.of(context).unfocus();
              final state = ref.read(taskProvider);
              if (state.isSelectionMode) {
                taskNotifier.deleteSelectedTasks();
              } else if (state.selectedTask != null) {
                taskNotifier.deleteTask(state.selectedTask!);
              }
              return null;
            },
          ),
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLargeScreen = constraints.maxWidth > 600;

            return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: Scaffold(
            extendBody: true,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: rp.Consumer(
                builder: (context, ref, _) {
                  final isSelectionMode = ref.watch(taskProvider.select((s) => s.isSelectionMode));
                  if (_selectedIndex == 0 && !isSelectionMode) return const SizedBox.shrink();

                  final selectedTaskIds = ref.watch(taskProvider.select((s) => s.selectedTaskIds));
                  final hasCompleted = ref.watch(taskProvider.select((s) => s.hasCompleted));
                  final categories = ref.watch(taskProvider.select((s) => s.categories));

                  return AppBar(
                    leading: isSelectionMode
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        taskNotifier.clearSelection();
                      },
                    )
                  : null,
              title: isSelectionMode
                  ? Text('${selectedTaskIds.length} Selected')
                  : null,
              actions: [
                if (isSelectionMode) ...[
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      HapticFeedback.heavyImpact();
                      taskNotifier.deleteSelectedTasks();
                    },
                    tooltip: 'Delete Selected',
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      HapticFeedback.mediumImpact();
                      taskNotifier.markSelectedAsCompleted(true);
                    },
                    tooltip: 'Mark Completed',
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.move_to_inbox_outlined),
                    tooltip: 'Move to Category',
                    onSelected: (category) {
                      FocusScope.of(context).unfocus();
                      taskNotifier.moveSelectedToCategory(category);
                    },
                    itemBuilder: (context) => categories
                        .where((c) => c != 'All')
                        .map((c) => PopupMenuItem(value: c, child: Text(c)))
                        .toList(),
                  ),
                  if (selectedTaskIds.length > 1)
                    IconButton(
                      icon: const Icon(Icons.auto_awesome_rounded),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        taskNotifier.breakdownSelectedTasks();
                      },
                      tooltip: 'AI Roadmap',
                    ),
                ] else ...[
                  // Premium Theme Toggle
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      themeNotifier.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.amber.withValues(alpha: 0.1) 
                            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: RotationTransition(
                              turns: animation,
                              child: FadeTransition(opacity: animation, child: child),
                            ),
                          );
                        },
                        child: Icon(
                          Theme.of(context).brightness == Brightness.dark
                              ? Icons.wb_sunny_rounded 
                              : Icons.nightlight_round,
                          key: ValueKey(Theme.of(context).brightness == Brightness.dark),
                          size: 20,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.amber[400] 
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (hasCompleted && _selectedIndex == 2)
                    IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        taskNotifier.clearCompleted();
                      },
                      icon: const Icon(Icons.delete_sweep_outlined),
                      tooltip: 'Clear Done',
                    ),
                  if (_selectedIndex != 0)
                    rp.Consumer(
                      builder: (context, ref, child) {
                        final authState = ref.watch(authStateChangesProvider);
                        return authState.when(
                          data: (user) => CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(user?.photoURL ?? 'https://api.dicebear.com/7.x/avataaars/png?seed=${user?.uid ?? "Felix"}'),
                          ),
                          loading: () => const CircleAvatar(radius: 18, child: CircularProgressIndicator()),
                          error: (_, _) => const CircleAvatar(radius: 18, child: Icon(Icons.error)),
                        );
                      }
                    ),
                ],
                const SizedBox(width: 16),
              ],
            );
          }),
        ),
            body: rp.Consumer(
              builder: (context, ref, _) {
                final isAILoading = ref.watch(taskProvider.select((s) => s.isAILoading));
                return Stack(
                  children: [
                    _buildMainContent(isLargeScreen)
                        .animate()
                        .fadeIn(duration: 400.ms, curve: Curves.easeOut),
                    if (isAILoading)
                      Container(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                'AI is generating your roadmap...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            bottomNavigationBar: !isLargeScreen ? _buildBottomNav() : null,
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                HapticFeedback.mediumImpact();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const QuickTaskSheet(),
                );
                if (_selectedIndex != 2) {
                  setState(() => _selectedIndex = 2);
                }
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
              highlightElevation: 0,
              child: const Icon(Icons.add, size: 32),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          ),
        );
      },
    ),
  ),
);
  }

  Widget _buildBottomNav() {
    final Brightness brightness = Theme.of(context).brightness;
    final bool isDark = brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: RepaintBoundary(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: isDark ? 0.7 : 0.8),
                  borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark 
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.space_dashboard_outlined, Icons.space_dashboard_rounded, 0, 'Home'),
                  _buildNavItem(Icons.calendar_today_outlined, Icons.calendar_today_rounded, 1, 'Schedule'),
                  _buildNavItem(Icons.check_circle_outline_rounded, Icons.check_circle_rounded, 2, 'Tasks'),
                  _buildNavItem(Icons.insights_outlined, Icons.insights_rounded, 3, 'Insights'),
                  _buildNavItem(Icons.tune_outlined, Icons.tune_rounded, 4, 'Settings'),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildNavItem(IconData unselectedIcon, IconData selectedIcon, int index, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() => _selectedIndex = index);
        HapticFeedback.lightImpact();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 18 : 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100), // Perfect pill shape
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
                        letterSpacing: -0.2, // Tighter typography for pills
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
}
