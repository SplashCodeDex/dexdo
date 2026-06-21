import 'dart:ui';
import 'package:dexdo/core/theme/theme_provider.dart';
import 'package:dexdo/features/auth/presentation/providers/auth_provider.dart';
import 'package:dexdo/features/tasks/presentation/providers/task_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showAvatarDropdown(BuildContext context, WidgetRef ref, {required Function(int) onMenuSelected}) async {
  await HapticFeedback.lightImpact();
  if (!context.mounted) return;
  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.2),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return SafeArea(
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 56, right: 16),
            child: Material(
              color: Colors.transparent,
              child: _AvatarDropdownContent(
                onMenuSelected: (index) {
                  Navigator.of(context).pop();
                  if (index != -1) {
                    onMenuSelected(index);
                  }
                },
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          alignment: Alignment.topRight,
          child: child,
        ),
      );
    },
  );
}

class _AvatarDropdownContent extends ConsumerWidget {
  const _AvatarDropdownContent({required this.onMenuSelected});
  final Function(int) onMenuSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.value;
    final completedCount = ref.watch(taskProvider.select((s) => s.completedTasks.length));
    final level = (completedCount ~/ 10) + 1;
    final xpProgress = (completedCount % 10) / 10.0;

    return Container(
      width: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: isDark ? 0.75 : 0.85),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildNestedCard(
                  context,
                  children: [
                    _buildProfileHeader(context, user, level, xpProgress, () {
                      HapticFeedback.mediumImpact();
                      onMenuSelected(0);
                    }),
                  ],
                ),
                const SizedBox(height: 8),
                _buildNestedCard(
                  context,
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.insights_rounded,
                      title: 'Productivity Stats',
                      subtitle: 'View your weekly progress',
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        onMenuSelected(1);
                      },
                    ),
                    _buildDivider(context),
                    _buildMenuItem(
                      context,
                      icon: Icons.tune_rounded,
                      title: 'Settings',
                      subtitle: 'Preferences & integrations',
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        onMenuSelected(2);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildNestedCard(
                  context,
                  children: [
                    _buildMenuItem(
                      context,
                      icon: isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                      title: isDark ? 'Light Mode' : 'Dark Mode',
                      subtitle: 'Change app appearance',
                      iconColor: isDark ? Colors.amber[400] : null,
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        ref.read(themeNotifierProvider.notifier).setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
                        onMenuSelected(-1);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildNestedCard(
                  context,
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.logout_rounded,
                      title: 'Log Out',
                      subtitle: 'Disconnect your session',
                      iconColor: Theme.of(context).colorScheme.error,
                      textColor: Theme.of(context).colorScheme.error,
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        ref.read(authControllerProvider.notifier).signOut();
                        onMenuSelected(-1);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNestedCard(BuildContext context, {required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User? user, int level, double xpProgress, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(
                user?.photoURL ?? 'https://api.dicebear.com/7.x/avataaars/png?seed=${user?.uid ?? "Felix"}',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.displayName ?? 'Guest User',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.email ?? 'Guest Account',
                    style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: xpProgress,
                            minHeight: 6,
                            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Lvl $level',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 24, color: iconColor ?? Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: textColor ?? Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
