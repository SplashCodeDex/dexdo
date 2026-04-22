import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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

    return Column(
      children: [
        _buildCalendarHeader(),
        _buildCalendarPageView(tasksWithDates),
        const SizedBox(height: 16),
        const Divider(height: 1),
        Expanded(
          child: _buildTasksForSelectedDay(tasksWithDates),
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

  Widget _buildCalendarPageView(List<Task> allTasks) {
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
          return _buildCalendarMonthGrid(monthDate, allTasks);
        },
      ),
    );
  }

  Widget _buildCalendarMonthGrid(DateTime monthDate, List<Task> allTasks) {
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
          
          final dayTasks = allTasks.where((t) => DateUtils.isSameDay(t.dueDate, cellDate)).toList();
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
                      bottom: 4,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: dayTasks.take(3).map((t) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isSelected 
                                ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8)
                                : t.isCompleted ? Colors.green : t.color,
                              shape: BoxShape.circle,
                            ),
                          );
                        }).toList(),
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

  Widget _buildTasksForSelectedDay(List<Task> allTasks) {
    if (_selectedDay == null) return const SizedBox.shrink();

    final dayTasks = allTasks.where((t) => DateUtils.isSameDay(t.dueDate, _selectedDay)).toList()
      ..sort((a, b) => (a.dueDate ?? DateTime.now()).compareTo(b.dueDate ?? DateTime.now()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('EEEE, MMM d').format(_selectedDay!),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
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
                                  provider.toggleTaskCompletion(task);
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
                                  provider.deleteTask(task.id);
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
