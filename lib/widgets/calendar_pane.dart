import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasksWithDates = taskProvider.allTasks.where((t) => t.dueDate != null).toList();

    return Column(
      children: [
        _buildCalendarHeader(),
        _buildCalendarGrid(tasksWithDates),
        const Divider(height: 1),
        Expanded(
          child: _buildTasksForSelectedDay(tasksWithDates),
        ),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
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
              Text(
                DateFormat('MMMM').format(_focusedDay),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildHeaderButton(
                icon: Icons.today_rounded,
                onPressed: () => setState(() {
                  _focusedDay = DateTime.now();
                  _selectedDay = _focusedDay;
                }),
                tooltip: 'Today',
              ),
              const SizedBox(width: 8),
              _buildHeaderButton(
                icon: Icons.chevron_left_rounded,
                onPressed: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1)),
              ),
              const SizedBox(width: 8),
              _buildHeaderButton(
                icon: Icons.chevron_right_rounded,
                onPressed: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1)),
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
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildCalendarGrid(List<Task> allTasks) {
    final daysInMonth = DateUtils.getDaysInMonth(_focusedDay.year, _focusedDay.month);
    final firstDayOffset = DateTime(_focusedDay.year, _focusedDay.month, 1).weekday % 7;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 1,
        ),
        itemCount: 7 + 35, // 7 days of week + 5-6 rows
        itemBuilder: (context, index) {
          if (index < 7) {
            return Center(
              child: Text(
                ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'][index],
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            );
          }

          final dayNum = index - 7 - firstDayOffset + 1;
          if (dayNum < 1 || dayNum > daysInMonth) return const SizedBox.shrink();

          final date = DateTime(_focusedDay.year, _focusedDay.month, dayNum);
          final isSelected = _selectedDay != null &&
              _selectedDay!.year == date.year &&
              _selectedDay!.month == date.month &&
              _selectedDay!.day == date.day;
          final isToday = DateUtils.isSameDay(date, DateTime.now());
          
          final dayTasks = allTasks.where((t) => DateUtils.isSameDay(t.dueDate, date)).toList();
          final hasTasks = dayTasks.isNotEmpty;

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedDay = date);
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
                    dayNum.toString(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.onPrimary 
                          : isToday 
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (hasTasks)
                    Positioned(
                      bottom: 6,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: dayTasks.take(3).map((t) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : t.color,
                            shape: BoxShape.circle,
                          ),
                        )).toList(),
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

  Widget _buildTasksForSelectedDay(List<Task> allTasks) {
    if (_selectedDay == null) return const SizedBox.shrink();

    final dayTasks = allTasks.where((t) => DateUtils.isSameDay(t.dueDate, _selectedDay)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            DateFormat('EEEE, MMM d').format(_selectedDay!),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        if (dayTasks.isEmpty)
          const Expanded(
            child: Center(
              child: Text('No tasks scheduled for this day'),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: dayTasks.length,
              itemBuilder: (context, index) {
                final task = dayTasks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    onTap: () {
                      final provider = Provider.of<TaskProvider>(context, listen: false);
                      provider.setSelectedTask(task);
                      if (widget.onTaskTap != null) widget.onTaskTap!(task);
                    },
                    leading: Icon(task.icon, color: task.color),
                    title: Text(
                      task.title.isEmpty ? 'Untitled Task' : task.title,
                      style: TextStyle(
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(task.category),
                    trailing: task.isCompleted 
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
