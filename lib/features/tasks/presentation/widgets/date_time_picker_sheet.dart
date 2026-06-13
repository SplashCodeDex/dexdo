import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePickerSheet extends StatefulWidget {
  final DateTime? initialDate;
  final bool includeTime;

  const DateTimePickerSheet({
    super.key,
    this.initialDate,
    this.includeTime = true,
  });

  @override
  State<DateTimePickerSheet> createState() => _DateTimePickerSheetState();
}

class _DateTimePickerSheetState extends State<DateTimePickerSheet> {
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  bool _showTimePicker = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    if (widget.initialDate != null) {
      _selectedTime = TimeOfDay.fromDateTime(widget.initialDate!);
      _showTimePicker = true;
    }
  }

  void _selectQuickDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final nextMonday = today.add(Duration(days: (8 - today.weekday) % 7 == 0 ? 7 : (8 - today.weekday) % 7));

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Select Date',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          
          // Quick Select Options
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickChip('Today', today, Icons.today_rounded),
                const SizedBox(width: 8),
                _buildQuickChip('Tomorrow', tomorrow, Icons.wb_sunny_outlined),
                const SizedBox(width: 8),
                _buildQuickChip('Next Mon', nextMonday, Icons.next_plan_outlined),
                const SizedBox(width: 8),
                _buildQuickChip('Later', today.add(const Duration(days: 7)), Icons.calendar_month_rounded),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Calendar
          Theme(
            data: theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(
                primary: theme.colorScheme.primary,
              ),
            ),
            child: CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              onDateChanged: (date) {
                setState(() => _selectedDate = date);
              },
            ),
          ),
          
          if (widget.includeTime) ...[
            const Divider(),
            ListTile(
              leading: Icon(Icons.access_time_rounded, color: theme.colorScheme.primary),
              title: const Text('Add Time', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: _selectedTime != null 
                ? Text(
                    _selectedTime!.format(context),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                : Icon(Icons.add_circle_outline_rounded, color: theme.colorScheme.primary),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime ?? TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() => _selectedTime = time);
                }
              },
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, null),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    final finalDateTime = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      _selectedTime?.hour ?? 0,
                      _selectedTime?.minute ?? 0,
                    );
                    Navigator.pop(context, finalDateTime);
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Set Date'),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String label, DateTime date, IconData icon) {
    final isSelected = DateUtils.isSameDay(_selectedDate, date);
    final theme = Theme.of(context);
    
    return ActionChip(
      avatar: Icon(
        icon, 
        size: 16, 
        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary
      ),
      label: Text(label),
      onPressed: () => _selectQuickDate(date),
      backgroundColor: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? Colors.transparent : theme.colorScheme.outlineVariant,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
