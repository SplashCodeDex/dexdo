import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';

class CategoryDialog extends ConsumerStatefulWidget {
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
  ConsumerState<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends ConsumerState<CategoryDialog> {
  late TextEditingController _nameController;
  late IconData _selectedIcon;
  late Color _selectedColor;

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
    final notifier = ref.read(taskProvider.notifier);
    final isEditing = widget.initialName != null;

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

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  isEditing ? 'Edit Category' : 'New Category',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const Spacer(),
                if (isEditing && widget.initialName != 'All' && widget.initialName != 'Personal')
                  IconButton(
                    onPressed: () {
                      notifier.deleteCategory(widget.initialName!);
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g. Work, Study, Health',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 24),
            Text(
              'Select Icon',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _availableIcons.length,
                itemBuilder: (context, index) {
                  final icon = _availableIcons[index];
                  final isSelected = _selectedIcon == icon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? _selectedColor.withValues(alpha: 0.1) : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                        border: Border.all(
                          color: isSelected ? _selectedColor : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? _selectedColor : Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select Color',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _availableColors.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final color = _availableColors[index];
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3) : null,
                      ),
                      child: isSelected ? const Icon(Icons.check, size: 20, color: Colors.white) : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final name = _nameController.text.trim();
                  if (name.isNotEmpty) {
                    if (isEditing) {
                      notifier.editCategory(widget.initialName!, name, _selectedIcon, _selectedColor);
                    } else {
                      notifier.addCategory(name, _selectedIcon, _selectedColor);
                    }
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  isEditing ? 'Save Changes' : 'Create Category',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
}
