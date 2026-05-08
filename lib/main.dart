import 'dart:ui';
import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'features/tasks/presentation/providers/task_provider.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'core/services/subscription_service.dart';
import 'features/calendar/presentation/widgets/calendar_pane.dart';
import 'features/home/presentation/widgets/home_pane.dart';
import 'features/settings/presentation/widgets/settings_pane.dart';
import 'features/tasks/presentation/widgets/task_editor_pane.dart';
import 'features/tasks/presentation/widgets/task_list_pane.dart';
// Note: Import will be valid after build/generation
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      AppLogger.e('Flutter Error', errorDetails.exception, errorDetails.stack);
    };

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      AppLogger.e('Platform Error', error, stack);
      return true;
    };

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );

    AppLogger.i('Application successfully initialized');
    
    runApp(
      const rp.ProviderScope(
        child: DeXDoApp(),
      ),
    );
  } catch (e, stack) {
    AppLogger.e('Initialization failed', e, stack);
    // In a real app, you might show a minimal error UI here
  }
}

class DeXDoApp extends rp.ConsumerWidget {
  const DeXDoApp({super.key});

  @override
  Widget build(BuildContext context, rp.WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp(
      onGenerateTitle: (context) => 'DeXDo', // Use localization when generated
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      localizationsDelegates: const [
        // AppLocalizations.delegate, // Uncomment when generated
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
      ],
      home: const HomeScreen(),
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
            child: _buildMainContent(isLargeScreen, taskState, notifier),
          ),
        ],
      );
    }

    return _buildMainContent(isLargeScreen, taskState, notifier);
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
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings_rounded),
          label: Text('Settings'),
        ),
      ],
    );
  }

  Widget _buildMainContent(bool isLargeScreen, TaskState taskState, TaskNotifier taskNotifier) {
    if (_selectedIndex != 2) {
      Widget content;
      switch (_selectedIndex) {
        case 0:
          content = HomePane(
            onTaskTap: (task) => setState(() => _selectedIndex = 2),
          );
          break;
        case 1:
          content = CalendarPane(
            onTaskTap: (task) => setState(() => _selectedIndex = 2),
          );
          break;
        case 3:
          content = const SettingsPane();
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
              child: PageTransitionSwitcher(
                transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                  return SharedAxisTransition(
                    animation: primaryAnimation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.horizontal,
                    child: child,
                  );
                },
                child: taskState.selectedTask != null
                    ? TaskEditorPane(
                        key: ValueKey(taskState.selectedTask!.id),
                        task: taskState.selectedTask!,
                      )
                    : Center(
                        key: const ValueKey('empty_editor'),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_note_rounded, size: 64, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)),
                            const SizedBox(height: 16),
                            Text(
                              'Select a task to view details',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 16),
                            ),
                          ],
                        ),
                      ),
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
    final taskState = ref.watch(taskProvider);
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
              taskNotifier.addTask();
              if (_selectedIndex != 2) {
                setState(() => _selectedIndex = 2);
              }
              return null;
            },
          ),
          DeleteSelectedIntent: CallbackAction<DeleteSelectedIntent>(
            onInvoke: (DeleteSelectedIntent intent) {
              FocusScope.of(context).unfocus();
              if (taskState.isSelectionMode) {
                taskNotifier.deleteSelectedTasks();
              } else if (taskState.selectedTask != null) {
                taskNotifier.deleteTask(taskState.selectedTask!);
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
            appBar: AppBar(
              leading: taskState.isSelectionMode
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        taskNotifier.clearSelection();
                      },
                    )
                  : null,
              title: taskState.isSelectionMode
                  ? Text('${taskState.selectedTaskIds.length} Selected')
                  : null,
              actions: [
                if (taskState.isSelectionMode) ...[
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
                    itemBuilder: (context) => taskState.categories
                        .where((c) => c != 'All')
                        .map((c) => PopupMenuItem(value: c, child: Text(c)))
                        .toList(),
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
                        borderRadius: BorderRadius.circular(16),
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
                  if (taskState.hasCompleted && _selectedIndex == 2)
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
                          error: (_, __) => const CircleAvatar(radius: 18, child: Icon(Icons.error)),
                        );
                      }
                    ),
                ],
                const SizedBox(width: 16),
              ],
            ),
            body: _buildBody(isLargeScreen, taskState, taskNotifier)
                .animate()
                .fadeIn(duration: 400.ms, curve: Curves.easeOut),
            bottomNavigationBar: !isLargeScreen ? _buildBottomNav() : null,
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                HapticFeedback.mediumImpact();
                taskNotifier.addTask();
                if (_selectedIndex != 2) {
                  setState(() => _selectedIndex = 2);
                }
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  _buildNavItem(Icons.tune_outlined, Icons.tune_rounded, 3, 'Settings'),
                ],
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
