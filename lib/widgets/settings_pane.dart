import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/task_provider.dart';
import '../services/auth_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'subscription_pane.dart';

class SettingsPane extends StatelessWidget {
  const SettingsPane({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final authService = Provider.of<AuthService>(context);

    return ListView(
      padding: const EdgeInsets.all(24),
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
        _buildSettingTile(
          context,
          title: 'Upgrade to Premium',
          subtitle: 'Unlock all features and support the developer',
          trailing: const Icon(Icons.star_rounded, color: Colors.orange),
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
            value: themeProvider.isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(value),
          ),
          icon: Icons.dark_mode_rounded,
          iconColor: Colors.deepPurple,
        ),
        const SizedBox(height: 24),
        _buildSectionHeader(context, 'Account'),
        if (authService.isAnonymous)
          _buildSettingTile(
            context,
            title: 'Sign In / Sync Data',
            subtitle: 'Bind to a permanent cloud account',
            trailing: const Icon(Icons.cloud_sync_rounded),
            icon: Icons.account_circle_rounded,
            iconColor: Colors.orange,
            onTap: () async {
              final credential = await authService.linkWithGoogle();
              if (context.mounted) {
                if (credential != null) {
                  await taskProvider.reloadFromStorage();
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
            title: 'Signed in via Google',
            subtitle: authService.currentUser?.email ?? 'Bound Account',
            icon: Icons.verified_user_rounded,
            iconColor: Colors.green,
            trailing: IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () async {
                await authService.signOut();
                if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Successfully signed out. Returning to anonymous.')),
                  );
                  // Rerun the anon init
                  await authService.signInAnonymously();
                  await taskProvider.reloadFromStorage();
                }
              },
            ),
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
          onTap: () => _showDeleteConfirmation(context, taskProvider),
        ),
        _buildSettingTile(
          context,
          title: 'Export Data',
          subtitle: 'Backup your tasks to a file',
          trailing: const Icon(Icons.chevron_right_rounded),
          icon: Icons.download_rounded,
          iconColor: Colors.blue,
          onTap: () => _exportData(context, taskProvider),
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
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
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

  void _showDeleteConfirmation(BuildContext context, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Tasks?'),
        content: const Text('This action cannot be undone. All your tasks will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearAllTasks();
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

  Future<void> _exportData(BuildContext context, TaskProvider provider) async {
    try {
      final jsonString = await provider.exportTasksToJson();
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
