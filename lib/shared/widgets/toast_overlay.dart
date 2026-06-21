import 'dart:ui';
import 'package:dexdo/core/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppToastOverlay extends ConsumerWidget {
  const AppToastOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toasts = ref.watch(toastProvider);
    if (toasts.isEmpty) return const SizedBox.shrink();

    final int count = toasts.length;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: List.generate(count, (index) {
                final toast = toasts[index];
                final int indexFromEnd = count - 1 - index;

                // Only render the top 3 items in the stack to maintain high rendering performance
                if (indexFromEnd >= 3) {
                  return const SizedBox.shrink();
                }

                return _ToastCard(
                  key: ValueKey(toast.id),
                  toast: toast,
                  indexFromEnd: indexFromEnd,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastCard extends ConsumerWidget {
  const _ToastCard({
    super.key,
    required this.toast,
    required this.indexFromEnd,
  });

  final AppToast toast;
  final int indexFromEnd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine colors and icons based on type
    final Color typeColor;
    final IconData typeIcon;
    switch (toast.type) {
      case ToastType.success:
        typeColor = Colors.green;
        typeIcon = Icons.check_circle_rounded;
        break;
      case ToastType.error:
        typeColor = Colors.red;
        typeIcon = Icons.error_outline_rounded;
        break;
      case ToastType.warning:
        typeColor = Colors.amber;
        typeIcon = Icons.warning_amber_rounded;
        break;
      case ToastType.info:
        typeColor = Colors.blue;
        typeIcon = Icons.info_outline_rounded;
        break;
    }

    // Dynamic calculations for stack depth styling and positioning
    final double scale = indexFromEnd == 0 ? 1.0 : (indexFromEnd == 1 ? 0.94 : 0.88);
    final double yOffset = indexFromEnd == 0 ? 0.0 : (indexFromEnd == 1 ? -10.0 : -20.0);
    final double opacity = indexFromEnd == 0 ? 1.0 : (indexFromEnd == 1 ? 0.80 : 0.50);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      transform: Matrix4.identity()
        ..translateByDouble(0.0, yOffset, 0.0, 1.0)
        ..scaleByDouble(scale, scale, scale, 1.0),
      transformAlignment: Alignment.topCenter,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: opacity,
        child: Dismissible(
          key: ValueKey(toast.id),
          direction: indexFromEnd == 0 ? DismissDirection.horizontal : DismissDirection.none,
          onDismissed: (_) {
            ref.read(toastProvider.notifier).dismiss(toast.id);
          },
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: (isDark ? const Color(0xFF1A1A1A) : Colors.white).withValues(alpha: isDark ? 0.75 : 0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.12),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: indexFromEnd == 0 ? 0.12 : 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Toast Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          typeIcon,
                          color: typeColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Toast Text
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (toast.title != null) ...[
                              Text(
                                toast.title!,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black.withValues(alpha: 0.9),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 1),
                            ],
                            Text(
                              toast.message,
                              style: TextStyle(
                                color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.6),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Primary Action Button (e.g. Undo)
                      if (toast.actionLabel != null && toast.onAction != null) ...[
                        const SizedBox(width: 8),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: typeColor,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            toast.onAction!();
                            ref.read(toastProvider.notifier).dismiss(toast.id);
                          },
                          child: Text(
                            toast.actionLabel!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                      // Secondary Action Button (e.g. Edit)
                      if (toast.secondaryActionLabel != null && toast.onSecondaryAction != null) ...[
                        const SizedBox(width: 6),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: typeColor,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            toast.onSecondaryAction!();
                            ref.read(toastProvider.notifier).dismiss(toast.id);
                          },
                          child: Text(
                            toast.secondaryActionLabel!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 12),
                      // Dismiss button
                      GestureDetector(
                        onTap: () {
                          ref.read(toastProvider.notifier).dismiss(toast.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.4),
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate()
     .fadeIn(duration: 300.ms, curve: Curves.easeOut)
     .slideY(begin: -0.3, end: 0, duration: 500.ms, curve: Curves.easeOutBack);
  }
}
