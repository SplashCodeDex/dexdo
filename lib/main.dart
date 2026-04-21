import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'widgets/task_list_pane.dart';
import 'widgets/task_editor_pane.dart';
import 'package:animations/animations.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: const DeXDoApp(),
    ),
  );
}

class DeXDoApp extends StatelessWidget {
  const DeXDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeXDo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          surface: Colors.grey[50]!,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[50],
          surfaceTintColor: Colors.transparent,
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
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

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2; // Default to 'Tasks' icon

  Widget _buildBody(bool isLargeScreen, TaskProvider taskProvider) {
    if (isLargeScreen) {
      return Row(
        children: [
          // Sidebar Navigation for Desktop
          _buildDesktopNavigationRail(),
          const VerticalDivider(width: 1, color: Colors.black12),
          
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
      backgroundColor: Colors.white.withValues(alpha: 0.5),
      indicatorColor: Colors.blue.withValues(alpha: 0.1),
      selectedIconTheme: const IconThemeData(color: Colors.blue),
      unselectedIconTheme: const IconThemeData(color: Colors.grey),
      selectedLabelTextStyle: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      unselectedLabelTextStyle: const TextStyle(color: Colors.grey),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/logo2DexDoNo.svg',
              height: 120,
              colorFilter: ColorFilter.mode(
                Colors.blue.withValues(alpha: 0.15),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${['Home View', 'Calendar View', '', 'Settings'][_selectedIndex < 2 ? _selectedIndex : _selectedIndex - 1]} Coming Soon',
              style: TextStyle(
                color: Colors.blue[900]?.withValues(alpha: 0.4),
                fontSize: 20,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
          ],
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
          const VerticalDivider(width: 1, color: Colors.black12),
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.white.withValues(alpha: 0.3),
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
                            Icon(Icons.edit_note_rounded, size: 64, color: Colors.blue.withValues(alpha: 0.1)),
                            const SizedBox(height: 16),
                            const Text(
                              'Select a task to view details',
                              style: TextStyle(color: Colors.black26, fontSize: 16),
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

    return LayoutBuilder(
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
                  : Image.asset(
                      'assets/images/DexDo.png',
                      height: 40,
                      filterQuality: FilterQuality.high,
                    ),
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
                  if (taskProvider.hasCompleted && _selectedIndex == 2)
                    IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        taskProvider.clearCompleted();
                      },
                      icon: const Icon(Icons.delete_sweep_outlined),
                      tooltip: 'Clear Done',
                    ),
                  const CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=Felix'),
                  ),
                ],
                const SizedBox(width: 16),
              ],
            ),
            body: _buildBody(isLargeScreen, taskProvider),
            bottomNavigationBar: !isLargeScreen ? _buildBottomNav() : null,
            floatingActionButton: _selectedIndex == 2 ? FloatingActionButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                taskProvider.addTask();
              },
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              child: const Icon(Icons.add, size: 32),
            ) : null,
            floatingActionButtonLocation: !isLargeScreen 
                ? FloatingActionButtonLocation.centerDocked 
                : FloatingActionButtonLocation.endFloat,
          ),
        );
      },
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
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(35),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.home_outlined, color: _selectedIndex == 0 ? Colors.blue : Colors.grey),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _selectedIndex = 0);
                    },
                    tooltip: 'Home',
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_month_outlined, color: _selectedIndex == 1 ? Colors.blue : Colors.grey),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _selectedIndex = 1);
                    },
                    tooltip: 'Calendar',
                  ),
                  const SizedBox(width: 48), // Space for FAB
                  IconButton(
                    icon: Icon(Icons.list_alt_rounded, color: _selectedIndex == 2 ? Colors.blue : Colors.grey),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _selectedIndex = 2);
                    },
                    tooltip: 'Tasks',
                  ),
                  IconButton(
                    icon: Icon(Icons.person_outline, color: _selectedIndex == 3 ? Colors.blue : Colors.grey),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _selectedIndex = 3);
                    },
                    tooltip: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
