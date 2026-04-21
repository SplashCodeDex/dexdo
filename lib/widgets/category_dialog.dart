import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class CategoryDialog extends StatefulWidget {
  final String? initialName;
  final IconData? initialIcon;
  final Color? initialColor;

  const CategoryDialog({
    super.key,
    this.initialName,
    this.initialIcon,
    this.initialColor,
  });

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  late TextEditingController _nameController;
  late IconData _selectedIcon;
  late Color _selectedColor;

  final List<IconData> _availableIcons = [
    Icons.work_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.fitness_center_rounded,
    Icons.home_rounded,
    Icons.person_rounded,
    Icons.shopping_cart_rounded,
    Icons.book_rounded,
    Icons.movie_rounded,
    Icons.restaurant_rounded,
    Icons.flight_rounded,
    Icons.code_rounded,
    Icons.brush_rounded,
  ];

  final List<Color> _availableColors = [
    const Color(0xFFF44336), // Red
    const Color(0xFF4CAF50), // Green
    const Color(0xFF2196F3), // Blue
    const Color(0xFF9C27B0), // Purple
    const Color(0xFFFF9800), // Orange
    const Color(0xFFFFC107), // Amber
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFFE91E63), // Pink
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _selectedIcon = widget.initialIcon ?? Icons.category_rounded;
    _selectedColor = widget.initialColor ?? Colors.blue;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final isEditing = widget.initialName != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Category' : 'New Category'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 24),
            const Text('Select Icon', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableIcons.map((icon) {
                final isSelected = _selectedIcon == icon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? _selectedColor.withValues(alpha: 0.1) : Colors.transparent,
                      border: Border.all(color: isSelected ? _selectedColor : Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: isSelected ? _selectedColor : Colors.grey[600]),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('Select Color', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableColors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
                    ),
                    child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        if (isEditing && widget.initialName != 'All' && widget.initialName != 'Personal')
          TextButton(
            onPressed: () {
              provider.deleteCategory(widget.initialName!);
              Navigator.pop(context);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isNotEmpty) {
              if (isEditing) {
                provider.editCategory(widget.initialName!, name, _selectedIcon, _selectedColor);
              } else {
                provider.addCategory(name, _selectedIcon, _selectedColor);
              }
              Navigator.pop(context);
            }
          },
          child: Text(isEditing ? 'SAVE' : 'ADD'),
        ),
      ],
    );
  }
}
