import 'dart:io';

import 'package:dexdo/core/theme/theme_provider.dart';
import 'package:dexdo/features/auth/presentation/providers/auth_provider.dart';
import 'package:dexdo/features/auth/data/verified_email_service.dart';
import 'package:dexdo/features/settings/presentation/widgets/subscription_pane.dart';
import 'package:dexdo/features/settings/presentation/widgets/user_profile_header.dart';
import 'package:dexdo/features/tasks/presentation/providers/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SettingsPane extends ConsumerWidget {
  const SettingsPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    final taskNotifier = ref.read(taskProvider.notifier);
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.value;
    final isAnonymous = user?.isAnonymous ?? true;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 32),
        const UserProfileHeader(),
        const SizedBox(height: 32),
        _buildSectionHeader(context, 'Premium'),
        _buildSettingTile(
          context,
          title: 'DeXDo Plus',
          subtitle: 'Manage your subscription and billing',
          trailing: const Icon(Icons.chevron_right_rounded),
          icon: Icons.workspace_premium_rounded,
          iconColor: Colors.orange,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SubscriptionPane()),
            );
          },
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(context, 'Appearance'),
        _buildSettingTile(
          context,
          title: 'Dark Mode',
          subtitle: 'Toggle dark and light themes',
          trailing: Switch(
            value: themeMode == ThemeMode.dark,
            onChanged: (value) => themeNotifier.setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
          ),
          icon: Icons.dark_mode_rounded,
          iconColor: Colors.deepPurple,
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(context, 'Account'),
        if (isAnonymous)
          _buildSettingTile(
            context,
            title: 'Link Google Account',
            subtitle: 'Backup and sync your data across devices',
            trailing: const Icon(Icons.link_rounded),
            icon: Icons.account_circle_rounded,
            iconColor: Colors.blue,
            onTap: () async {
              final authController = ref.read(authControllerProvider.notifier);
              final credential = await authController.linkWithGoogle();
              if (context.mounted) {
                if (credential != null) {
                  await taskNotifier.reloadFromStorage();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Succesfully linked to ${credential.user?.email}')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sign-in cancelled or failed.')),
                  );
                }
              }
            },
          )
        else
          _buildSettingTile(
            context,
            title: 'Sign Out',
            subtitle: 'Switch to a local-only guest account',
            icon: Icons.logout_rounded,
            iconColor: Colors.red,
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () async {
              final authController = ref.read(authControllerProvider.notifier);
              await authController.signOut();
              if (context.mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Successfully signed out. Returning to anonymous.')),
                );
                // Rerun the anon init
                await authController.signInAnonymously();
                await taskNotifier.reloadFromStorage();
              }
            },
          ),
        _buildSettingTile(
          context,
          title: 'Verify Email (OTP-less)',
          subtitle: 'Securely verify identity using Credential Manager',
          trailing: const Icon(Icons.verified_user_rounded),
          icon: Icons.mark_email_read_rounded,
          iconColor: Colors.green,
          onTap: () async {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Requesting verifiable credential...')),
            );
            final service = VerifiedEmailService();
            final userInfo = await service.getVerifiedEmail();
            if (context.mounted) {
              if (userInfo != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Successfully logged in as ${userInfo.email}')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to get credential or cancelled.')),
                );
              }
            }
          },
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(context, 'Data Management'),
        _buildSettingTile(
          context,
          title: 'Clear All Tasks',
          subtitle: 'Delete all tasks permanently',
          trailing: const Icon(Icons.chevron_right_rounded),
          icon: Icons.delete_forever_rounded,
          iconColor: Colors.red,
          onTap: () => _showDeleteConfirmation(context, taskNotifier),
        ),
        _buildSettingTile(
          context,
          title: 'Export Data',
          subtitle: 'Backup your tasks to a file',
          trailing: const Icon(Icons.chevron_right_rounded),
          icon: Icons.download_rounded,
          iconColor: Colors.blue,
          onTap: () => _exportData(context, taskNotifier),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(context, 'About'),
        _buildSettingTile(
          context,
          title: 'DeXDo Version',
          subtitle: '1.0.0 (Stable)',
          trailing: const Text('Check for updates', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          icon: Icons.info_outline_rounded,
          iconColor: Colors.grey,
        ),
        const SizedBox(height: 48),
        Center(
          child: Column(
            children: [
              Text(
                'Made with ❤️ by CodeDeX',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '© 2024 DeXDo Inc.',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget trailing,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: trailing,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, TaskNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Clear All Tasks?'),
        content: const Text('This action cannot be undone. All your tasks will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              notifier.clearAllTasks();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All tasks cleared')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, TaskNotifier notifier) async {
    try {
      final jsonString = notifier.exportTasksToJson();
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/dexdo_tasks_export.json');
      await file.writeAsString(jsonString);

      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(file.path)], text: 'My DeXDo Tasks Export');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }
}
