import 'package:dexdo/features/auth/presentation/providers/auth_provider.dart';
import 'package:dexdo/features/settings/presentation/widgets/dynamic_avatar.dart';
import 'package:dexdo/features/settings/presentation/widgets/productivity_rings.dart';
import 'package:dexdo/features/tasks/presentation/providers/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfileHeader extends ConsumerWidget {
  const UserProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    final taskState = ref.watch(taskProvider);
    
    final user = authState.value;
    final isAnonymous = user?.isAnonymous ?? true;
    final displayName = user?.displayName ?? (isAnonymous ? 'Guest' : 'User');
    final email = user?.email ?? (isAnonymous ? 'Local-only data' : '');

    // Calculate Completion Ratios
    final totalTasks = taskState.tasks.length;
    final completedTasks = taskState.tasks.where((t) => t.isCompleted).length;
    final mainTaskProgress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    int totalSubtasks = 0;
    int completedSubtasks = 0;
    for (var task in taskState.tasks) {
      totalSubtasks += task.subtasks.length;
      completedSubtasks += task.subtasks.where((s) => s.isCompleted).length;
    }
    final subtaskProgress = totalSubtasks > 0 ? completedSubtasks / totalSubtasks : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Avatar & Identity
          Stack(
            alignment: Alignment.center,
            children: [
              ProductivityRings(
                mainTaskProgress: mainTaskProgress,
                subtaskProgress: subtaskProgress,
                size: 90,
              ),
              DynamicAvatar(
                photoUrl: user?.photoURL,
                displayName: user?.displayName,
                email: user?.email,
                size: 56,
              ),
            ],
          ),
          const SizedBox(width: 20),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isAnonymous) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.verified_rounded, color: Colors.blue, size: 18),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Premium Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'PRO MEMBER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
