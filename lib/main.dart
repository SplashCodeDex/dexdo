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

    return MaterialApp(
      title: 'DeXDo',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          },
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.light().textTheme,
        ).copyWith(
          titleLarge: GoogleFonts.plusJakartaSans(
            textStyle: ThemeData.light().textTheme.titleLarge,
            fontWeight: FontWeight.bold,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        dividerColor: const Color(0xFFE2E8F0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8FAFC),
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          centerTitle: false,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          },
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.dark().textTheme,
        ).copyWith(
          titleLarge: GoogleFonts.plusJakartaSans(
            textStyle: ThemeData.dark().textTheme.titleLarge,
            fontWeight: FontWeight.bold,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.dark,
          surface: const Color(0xFF0F172A),
          onSurface: const Color(0xFFF1F5F9),
          primaryContainer: const Color(0xFF1E293B),
          onPrimaryContainer: const Color(0xFF3B82F6),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        dividerColor: const Color(0xFF1E293B),
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
          color: const Color(0xFF1E293B),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF334155), width: 1),
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
  late ScrollController _homeScrollController;
  bool _showHomeHeaderAvatar = false;

  @override
  void initState() {
    super.initState();
    _homeScrollController = ScrollController();
    _homeScrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _homeScrollController.removeListener(_onScroll);
    _homeScrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_selectedIndex == 0 && _homeScrollController.hasClients) {
      final bool shouldShow = _homeScrollController.offset > 80;
      if (shouldShow != _showHomeHeaderAvatar) {
        setState(() {
          _showHomeHeaderAvatar = shouldShow;
        });
      }
    }
  }

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
    // Spacer for the floating header
    final topPadding = MediaQuery.of(context).padding.top + 80;

    if (_selectedIndex != 2) {
      Widget content;
      switch (_selectedIndex) {
        case 0:
          content = HomePane(
            scrollController: _homeScrollController,
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
          child: Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: content,
          ),
        ),
      );
    }

    if (isLargeScreen) {
      return Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Row(
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
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: const TaskListPane(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Calculate daily progress for the header ring
    final now = DateTime.now();
    final completedToday = taskProvider.allTasks.where((t) {
      if (t.isCompleted && t.completionDate != null) {
        return t.completionDate!.year == now.year &&
            t.completionDate!.month == now.month &&
            t.completionDate!.day == now.day;
      }
      return false;
    }).length;
    final activeToday = taskProvider.allTasks.where((t) {
      if (t.isCompleted) return false;
      if (t.dueDate != null) {
        final taskDate = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
        final todayDate = DateTime(now.year, now.month, now.day);
        return taskDate.isBefore(todayDate) || taskDate.isAtSameMomentAs(todayDate);
      }
      return t.isStarred;
    }).length;
    final totalToday = completedToday + activeToday;
    final progressToday = totalToday == 0 ? 0.0 : completedToday / totalToday;

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
            body: Stack(
              children: [
                _buildBody(isLargeScreen, taskProvider),
                // Floating Glassmorphic Header
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            height: 64,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface.withValues(alpha: themeProvider.isDarkMode ? 0.7 : 0.8),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: (themeProvider.isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.08),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 20,
                                  spreadRadius: -5,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                if (taskProvider.isSelectionMode)
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      FocusScope.of(context).unfocus();
                                      taskProvider.clearSelection();
                                    },
                                  )
                                else
                                  // Brand Logo (Bolt icon with optional Progress Ring)
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Progress Ring: Only visible when NOT on the home screen
                                      // It animates in/out as the user navigates
                                      AnimatedScale(
                                        scale: _selectedIndex == 0 ? 0.0 : 1.0,
                                        duration: const Duration(milliseconds: 600),
                                        curve: Curves.elasticOut,
                                        child: AnimatedOpacity(
                                          opacity: _selectedIndex == 0 ? 0.0 : 1.0,
                                          duration: const Duration(milliseconds: 300),
                                          child: SizedBox(
                                            width: 40,
                                            height: 40,
                                            child: CircularProgressIndicator(
                                              value: progressToday,
                                              strokeWidth: 3.5,
                                              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                                              strokeCap: StrokeCap.round,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Brand Bolt Icon: Always visible in the header
                                      // We use a different tag on Home screen to avoid Hero conflict with the banner
                                      Hero(
                                        tag: _selectedIndex == 0 ? 'header_bolt_home' : 'brand_bolt',
                                        child: Icon(
                                          Icons.bolt_rounded,
                                          color: Theme.of(context).colorScheme.primary,
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                Expanded(
                                  child: taskProvider.isSelectionMode
                                      ? Text(
                                          '${taskProvider.selectedTaskIds.length} Selected',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                        )
                                      : RichText(
                                          text: TextSpan(
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -1.2,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'DeX',
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.onSurface,
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'Do',
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
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
                                ] else ...[
                                  // Theme Toggle
                                  IconButton(
                                    onPressed: () => themeProvider.toggleTheme(!themeProvider.isDarkMode),
                                    icon: Icon(
                                      themeProvider.isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                                      size: 20,
                                      color: themeProvider.isDarkMode ? Colors.amber[400] : Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  // Profile Avatar: Only visible when NOT on the home screen or when scrolled down
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 500),
                                    reverseDuration: const Duration(milliseconds: 300),
                                    transitionBuilder: (Widget child, Animation<double> animation) {
                                      return ScaleTransition(
                                        scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                                        child: FadeTransition(opacity: animation, child: child),
                                      );
                                    },
                                    child: (_selectedIndex == 0 && !_showHomeHeaderAvatar)
                                        ? const SizedBox.shrink(key: ValueKey('empty_header_avatar'))
                                        : Builder(
                                            key: const ValueKey('header_avatar'),
                                            builder: (context) {
                                              final authService = Provider.of<AuthService>(context);
                                              final avatar = Padding(
                                                padding: const EdgeInsets.only(left: 8),
                                                child: CircleAvatar(
                                                  radius: 16,
                                                  backgroundImage: NetworkImage(authService.currentUser?.photoURL ?? 'https://api.dicebear.com/7.x/avataaars/png?seed=${authService.currentUser?.uid ?? "Felix"}'),
                                                ),
                                              );
                                              
                                              // Only use Hero tag when NOT on Home screen to avoid duplicate tags
                                              // with the HomePane avatar during scroll. On navigation, 
                                              // the change in _selectedIndex will trigger the Hero flight.
                                              if (_selectedIndex == 0) return avatar;
                                              
                                              return Hero(
                                                tag: 'user_avatar',
                                                child: avatar,
                                              );
                                            }
                                          ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
