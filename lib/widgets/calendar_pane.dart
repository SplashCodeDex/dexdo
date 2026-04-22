import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:animations/animations.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'package:intl/intl.dart';

class CalendarPane extends StatefulWidget {
  final Function(Task)? onTaskTap;
  const CalendarPane({super.key, this.onTaskTap});

  @override
  State<CalendarPane> createState() => _CalendarPaneState();
}

class _CalendarPaneState extends State<CalendarPane> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  late PageController _pageController;
  final int _initialPage = 1200; // Large center point for infinite scroll

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasksWithDates = taskProvider.allTasks.where((t) => t.dueDate != null).toList();

    // PERFORMANCE OPTIMIZATION: 
    // Group tasks into an O(1) lookup map to prevent O(N * 42) iterations 
    // per month when rendering the swiping PagerView grid.
    final Map<DateTime, List<Task>> tasksByDate = {};
    for (var task in tasksWithDates) {
      final date = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      if (!tasksByDate.containsKey(date)) tasksByDate[date] = [];
      tasksByDate[date]!.add(task);
    }

    return Column(
      children: [
        _buildCalendarHeader(),
        _buildCalendarPageView(tasksByDate),
        const SizedBox(height: 16),
        const Divider(height: 1),
        Expanded(
          child: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation, secondaryAnimation) {
              return SharedAxisTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.vertical,
                fillColor: Colors.transparent,
                child: child,
              );
            },
            child: _buildTasksForSelectedDay(tasksByDate, _selectedDay),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('yyyy').format(_focusedDay),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Text(
                  DateFormat('MMMM').format(_focusedDay),
                  key: ValueKey<String>(DateFormat('MMMM').format(_focusedDay)),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildHeaderButton(
                icon: Icons.today_rounded,
                onPressed: () {
                  final now = DateTime.now();
                  setState(() {
                    _focusedDay = now;
                    _selectedDay = now;
                  });
                  _pageController.animateToPage(_initialPage, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                },
                tooltip: 'Today',
              ),
              const SizedBox(width: 8),
              _buildHeaderButton(
                icon: Icons.chevron_left_rounded,
                onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
              ),
              const SizedBox(width: 8),
              _buildHeaderButton(
                icon: Icons.chevron_right_rounded,
                onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({required IconData icon, required VoidCallback onPressed, String? tooltip}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        tooltip: tooltip,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildCalendarPageView(Map<DateTime, List<Task>> tasksByDate) {
    return SizedBox(
      height: 380, // Fixed height for 6 rows + headers
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          final monthOffset = index - _initialPage;
          final now = DateTime.now();
          setState(() {
            _focusedDay = DateTime(now.year, now.month + monthOffset, 1);
          });
        },
        itemBuilder: (context, index) {
          final monthOffset = index - _initialPage;
          final now = DateTime.now();
          final monthDate = DateTime(now.year, now.month + monthOffset, 1);
          return _buildCalendarMonthGrid(monthDate, tasksByDate);
        },
      ),
    );
  }

  Widget _buildCalendarMonthGrid(DateTime monthDate, Map<DateTime, List<Task>> tasksByDate) {
    final firstDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(monthDate.year, monthDate.month);
    final firstDayOffset = firstDayOfMonth.weekday % 7; // Sunday = 0
    final daysInPrevMonth = DateUtils.getDaysInMonth(monthDate.year, monthDate.month - 1);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: 7 + 42, // 7 days of week + 6 rows of 7
        itemBuilder: (context, index) {
          if (index < 7) {
            return Center(
              child: Text(
                ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'][index],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            );
          }

          final dayIndex = index - 7;
          DateTime cellDate;
          bool isCurrentMonth = true;

          if (dayIndex < firstDayOffset) {
            final dayNum = daysInPrevMonth - firstDayOffset + dayIndex + 1;
            cellDate = DateTime(monthDate.year, monthDate.month - 1, dayNum);
            isCurrentMonth = false;
          } else if (dayIndex < firstDayOffset + daysInMonth) {
            final dayNum = dayIndex - firstDayOffset + 1;
            cellDate = DateTime(monthDate.year, monthDate.month, dayNum);
          } else {
            final dayNum = dayIndex - firstDayOffset - daysInMonth + 1;
            cellDate = DateTime(monthDate.year, monthDate.month + 1, dayNum);
            isCurrentMonth = false;
          }

          final isSelected = _selectedDay != null && DateUtils.isSameDay(_selectedDay, cellDate);
          final isToday = DateUtils.isSameDay(cellDate, DateTime.now());
          
          final normalizedCellDate = DateTime(cellDate.year, cellDate.month, cellDate.day);
          final dayTasks = tasksByDate[normalizedCellDate] ?? const [];
          final hasTasks = dayTasks.isNotEmpty;
          final completedTasks = dayTasks.where((t) => t.isCompleted).length;

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedDay = cellDate);
              
              // If tapping a day in prev/next month, auto-swipe to that month
              if (!isCurrentMonth) {
                if (dayIndex < firstDayOffset) {
                  _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                } else {
                  _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                }
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary 
                    : isToday ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isToday && !isSelected 
                    ? Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5), width: 1.5) 
                    : Border.all(color: Colors.transparent),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    cellDate.day.toString(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.onPrimary 
                          : isCurrentMonth
                              ? (isToday ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface)
                              : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  if (hasTasks)
                    Positioned(
                      bottom: 8,
                      left: 12,
                      right: 12,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: completedTasks / dayTasks.length,
                          minHeight: 4,
                          backgroundColor: isSelected 
                            ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.3) 
                            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isSelected 
                              ? Theme.of(context).colorScheme.onPrimary 
                              : (completedTasks == dayTasks.length ? Colors.green : Theme.of(context).colorScheme.primary)
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks scheduled',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enjoy your free time or add a new task!',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksForSelectedDay(Map<DateTime, List<Task>> tasksByDate, DateTime? selectedDay) {
    if (selectedDay == null) return const SizedBox.shrink();

    final normalizedSelected = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    final dayTasks = List<Task>.from(tasksByDate[normalizedSelected] ?? [])
      ..sort((a, b) => (a.dueDate ?? DateTime.now()).compareTo(b.dueDate ?? DateTime.now()));

    return Column(
      key: ValueKey<String>(selectedDay.toIso8601String()),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Row(
            children: [
              Text(
                DateFormat('EEEE, MMM d').format(selectedDay),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              if (dayTasks.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${dayTasks.where((t) => t.isCompleted).length}/${dayTasks.length} Done',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  final provider = Provider.of<TaskProvider>(context, listen: false);
                  provider.addTask(dueDate: selectedDay);
                  if (widget.onTaskTap != null && provider.selectedTask != null) {
                    widget.onTaskTap!(provider.selectedTask!);
                  }
                },
                icon: const Icon(Icons.add_circle),
                color: Theme.of(context).colorScheme.primary,
                tooltip: 'Add Task for this day',
              ),
            ],
          ),
        ),
        if (dayTasks.isEmpty)
          Expanded(child: _buildEmptyState())
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: dayTasks.length,
              itemBuilder: (context, index) {
                final task = dayTasks[index];
                final isLast = index == dayTasks.length - 1;
                
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Timeline indicator
                    Column(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          margin: const EdgeInsets.only(top: 24),
                          decoration: BoxDecoration(
                            color: task.isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.surface,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (task.isCompleted ? Colors.green : Theme.of(context).colorScheme.primary).withValues(alpha: 0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // Slidable task card
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Slidable(
                          key: ValueKey(task.id),
                          startActionPane: ActionPane(
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                borderRadius: BorderRadius.circular(16),
                                onPressed: (context) {
                                  final provider = Provider.of<TaskProvider>(context, listen: false);
                                  provider.toggleTask(task);
                                },
                                backgroundColor: task.isCompleted ? Colors.orange : Colors.green,
                                foregroundColor: Colors.white,
                                icon: task.isCompleted ? Icons.undo_rounded : Icons.check_circle_rounded,
                                label: task.isCompleted ? 'Undo' : 'Done',
                              ),
                            ],
                          ),
                          endActionPane: ActionPane(
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                borderRadius: BorderRadius.circular(16),
                                onPressed: (context) {
                                  final provider = Provider.of<TaskProvider>(context, listen: false);
                                  provider.deleteTask(task);
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete_rounded,
                                label: 'Delete',
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () {
                              final provider = Provider.of<TaskProvider>(context, listen: false);
                              provider.setSelectedTask(task);
                              if (widget.onTaskTap != null) widget.onTaskTap!(task);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardTheme.color,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: task.isCompleted 
                                      ? Colors.green.withValues(alpha: 0.3) 
                                      : Theme.of(context).dividerColor
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02), 
                                    blurRadius: 8, 
                                    offset: const Offset(0, 2)
                                  ),
                                ]
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: task.isCompleted ? Colors.green.withValues(alpha: 0.1) : task.color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      task.isCompleted ? Icons.check_circle_rounded : task.icon, 
                                      color: task.isCompleted ? Colors.green : task.color, 
                                      size: 20
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.dueDate != null ? DateFormat('h:mm a').format(task.dueDate!) : 'Anytime',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: task.isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          task.title.isEmpty ? 'Untitled Task' : task.title,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                            color: task.isCompleted ? Theme.of(context).colorScheme.onSurfaceVariant : Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                        if (task.description.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            task.description,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ]
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}
