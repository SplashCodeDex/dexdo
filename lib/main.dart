import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'services/auth_service.dart';
import 'widgets/task_list_pane.dart';
import 'widgets/task_editor_pane.dart';
import 'widgets/home_pane.dart';
import 'widgets/calendar_pane.dart';
import 'widgets/settings_pane.dart';
import 'package:animations/animations.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TaskProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthService()),
      ],
      child: const DeXDoApp(),
    ),
  );
}

class DeXDoApp extends StatelessWidget {
  const DeXDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(Theme.of(context).textTheme);

    return MaterialApp(
      title: 'DeXDo',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: textTheme.copyWith(
          titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          bodyLarge: textTheme.bodyLarge?.copyWith(letterSpacing: -0.2),
          bodyMedium: textTheme.bodyMedium?.copyWith(letterSpacing: -0.2),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB), // A more vibrant "DeX Blue"
          brightness: Brightness.light,
          surface: const Color(0xFFF8FAFC), // Slate 50
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        dividerColor: const Color(0xFFE2E8F0), // Slate 200
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8FAFC),
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          centerTitle: false,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF1E293B), // Slate 800
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData(brightness: Brightness.dark).textTheme).copyWith(
          titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          bodyLarge: textTheme.bodyLarge?.copyWith(letterSpacing: -0.2),
          bodyMedium: textTheme.bodyMedium?.copyWith(letterSpacing: -0.2),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.dark,
          surface: const Color(0xFF0F172A), // Slate 900 (Deep Navy)
          onSurface: const Color(0xFFF1F5F9),
          primaryContainer: const Color(0xFF1E293B),
          onPrimaryContainer: const Color(0xFF3B82F6),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        dividerColor: const Color(0xFF1E293B), // Slate 800
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          centerTitle: false,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFFF1F5F9),
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E293B), // Slate 800
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF334155), width: 1), // Slate 700
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class NewTaskIntent extends Intent {
  const NewTaskIntent();
}

class DeleteSelectedIntent extends Intent {
  const DeleteSelectedIntent();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2; // Default to 'Tasks' icon

  Widget _buildBody(bool isLargeScreen, TaskProvider taskProvider) {
    if (isLargeScreen) {
      return Row(
        children: [
          // Sidebar Navigation for Desktop
          _buildDesktopNavigationRail(),
          VerticalDivider(width: 1, color: Theme.of(context).dividerColor),
          
          // Content Area
          Expanded(
            child: _buildMainContent(isLargeScreen, taskProvider),
          ),
        ],
      );
    }

    return _buildMainContent(isLargeScreen, taskProvider);
  }

  Widget _buildDesktopNavigationRail() {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        FocusScope.of(context).unfocus();
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

  Widget _buildMainContent(bool isLargeScreen, TaskProvider taskProvider) {
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
                child: taskProvider.selectedTask != null
                    ? TaskEditorPane(
                        key: ValueKey(taskProvider.selectedTask!.id),
                        task: taskProvider.selectedTask!,
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
    final taskProvider = Provider.of<TaskProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN): const NewTaskIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyN): const NewTaskIntent(),
        LogicalKeySet(LogicalKeyboardKey.delete): const DeleteSelectedIntent(),
        LogicalKeySet(LogicalKeyboardKey.backspace): const DeleteSelectedIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          NewTaskIntent: CallbackAction<NewTaskIntent>(
            onInvoke: (NewTaskIntent intent) {
              FocusScope.of(context).unfocus();
              taskProvider.addTask();
              if (_selectedIndex != 2) {
                setState(() => _selectedIndex = 2);
              }
              return null;
            },
          ),
          DeleteSelectedIntent: CallbackAction<DeleteSelectedIntent>(
            onInvoke: (DeleteSelectedIntent intent) {
              FocusScope.of(context).unfocus();
              if (taskProvider.isSelectionMode) {
                taskProvider.deleteSelectedTasks();
              } else if (taskProvider.selectedTask != null) {
                taskProvider.deleteTask(taskProvider.selectedTask!);
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
              leading: taskProvider.isSelectionMode
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        taskProvider.clearSelection();
                      },
                    )
                  : null,
              title: taskProvider.isSelectionMode
                  ? Text('${taskProvider.selectedTaskIds.length} Selected')
                  : null,
              actions: [
                if (taskProvider.isSelectionMode) ...[
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      taskProvider.deleteSelectedTasks();
                    },
                    tooltip: 'Delete Selected',
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      taskProvider.markSelectedAsCompleted(true);
                    },
                    tooltip: 'Mark Completed',
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.move_to_inbox_outlined),
                    tooltip: 'Move to Category',
                    onSelected: (category) {
                      FocusScope.of(context).unfocus();
                      taskProvider.moveSelectedToCategory(category);
                    },
                    itemBuilder: (context) => taskProvider.categories
                        .where((c) => c != 'All')
                        .map((c) => PopupMenuItem(value: c, child: Text(c)))
                        .toList(),
                  ),
                ] else ...[
                  // Premium Theme Toggle
                  GestureDetector(
                    onTap: () => themeProvider.toggleTheme(!themeProvider.isDarkMode),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode 
                            ? Colors.amber.withValues(alpha: 0.1) 
                            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
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
                          themeProvider.isDarkMode 
                              ? Icons.wb_sunny_rounded 
                              : Icons.nightlight_round,
                          key: ValueKey(themeProvider.isDarkMode),
                          size: 20,
                          color: themeProvider.isDarkMode 
                              ? Colors.amber[400] 
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (taskProvider.hasCompleted && _selectedIndex == 2)
                    IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        taskProvider.clearCompleted();
                      },
                      icon: const Icon(Icons.delete_sweep_outlined),
                      tooltip: 'Clear Done',
                    ),
                  if (_selectedIndex != 0)
                    Builder(
                      builder: (context) {
                        final authService = Provider.of<AuthService>(context);
                        return CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(authService.currentUser?.photoURL ?? 'https://api.dicebear.com/7.x/avataaars/png?seed=${authService.currentUser?.uid ?? "Felix"}'),
                        );
                      }
                    ),
                ],
                const SizedBox(width: 16),
              ],
            ),
            body: _buildBody(isLargeScreen, taskProvider),
            bottomNavigationBar: !isLargeScreen ? _buildBottomNav() : null,
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                taskProvider.addTask();
                if (_selectedIndex != 2) {
                  setState(() => _selectedIndex = 2);
                }
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              child: const Icon(Icons.add, size: 32),
            ),
            floatingActionButtonLocation: !isLargeScreen 
                ? FloatingActionButtonLocation.centerDocked 
                : FloatingActionButtonLocation.endFloat,
          ),
        );
      },
    ),
  ),
);
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                    Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(35),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2), // Inner light shine
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home_outlined, Icons.home_rounded, 0, 'Home'),
                  _buildNavItem(Icons.calendar_month_outlined, Icons.calendar_month_rounded, 1, 'Calendar'),
                  const SizedBox(width: 56), // Space for FAB
                  _buildNavItem(Icons.list_alt_rounded, Icons.list_alt_rounded, 2, 'Tasks'),
                  _buildNavItem(Icons.settings_outlined, Icons.settings_rounded, 3, 'Settings'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData unselectedIcon, IconData selectedIcon, int index, String tooltip) {
    final isSelected = _selectedIndex == index;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() => _selectedIndex = index);
          HapticFeedback.lightImpact();
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCirc,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: Icon(
              isSelected ? selectedIcon : unselectedIcon,
              key: ValueKey(isSelected),
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary 
                  : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              size: isSelected ? 26 : 24,
            ),
          ),
        ),
      ),
    );
  }
}
