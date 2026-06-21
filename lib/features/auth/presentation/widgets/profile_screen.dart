import 'package:dexdo/features/auth/presentation/providers/auth_provider.dart';
import 'package:dexdo/features/tasks/presentation/providers/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authStateChangesProvider).value;
      if (user != null && user.displayName != null) {
        _nameController.text = user.displayName!;
      } else {
        _nameController.text = 'Guest User';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    FocusScope.of(context).unfocus();
    await HapticFeedback.mediumImpact();
    
    final newName = _nameController.text.trim();
    await ref.read(authControllerProvider.notifier).updateProfile(displayName: newName);
    
    if (mounted) {
      setState(() => _isEditingName = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final completedCount = ref.watch(taskProvider.select((s) => s.completedTasks.length));
    final activeCount = ref.watch(taskProvider.select((s) => s.activeTasks.length));
    final level = (completedCount ~/ 10) + 1;
    final xpProgress = (completedCount % 10) / 10.0;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: authState.when(
        data: (_) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              // Avatar
              Center(
                child: Hero(
                  tag: 'profile_avatar',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      backgroundImage: NetworkImage(
                        user?.photoURL ?? 'https://api.dicebear.com/7.x/avataaars/png?seed=${user?.uid ?? "Felix"}',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Gamification Card
              _buildGlassCard(
                context,
                isDark,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Current Level',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Lvl $level',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: xpProgress,
                          minHeight: 12,
                          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(completedCount % 10) * 10} XP',
                            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                          Text(
                            '100 XP to Next Level',
                            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(context, 'Completed', completedCount.toString(), Icons.check_circle_rounded),
                          Container(width: 1, height: 40, color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
                          _buildStatItem(context, 'Active', activeCount.toString(), Icons.pending_actions_rounded),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Details Card
              _buildGlassCard(
                context,
                isDark,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Row(
                          children: [
                            Icon(Icons.person_outline_rounded, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _nameController,
                                enabled: _isEditingName,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                                decoration: InputDecoration(
                                  labelText: 'Display Name',
                                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Name cannot be empty';
                                  return null;
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(_isEditingName ? Icons.check_rounded : Icons.edit_rounded),
                              color: _isEditingName ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                              onPressed: () {
                                if (_isEditingName) {
                                  _saveProfile();
                                } else {
                                  setState(() => _isEditingName = true);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: Theme.of(context).dividerColor.withValues(alpha: 0.08)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Row(
                          children: [
                            Icon(Icons.email_outlined, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Email Address',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.email ?? 'Guest Account (Not Linked)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Theme.of(context).colorScheme.onSurface,
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
                ),
              ),
              const SizedBox(height: 16),
              
              // Actions Card
              _buildGlassCard(
                context,
                isDark,
                child: Column(
                  children: [
                    if (user?.isAnonymous ?? true)
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.g_mobiledata_rounded, color: Colors.blue, size: 28),
                        ),
                        title: const Text('Link with Google', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('Sync data across devices'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () async {
                          await HapticFeedback.mediumImpact();
                          await ref.read(authControllerProvider.notifier).linkWithGoogle();
                        },
                      ),
                    if (user?.isAnonymous ?? true)
                      Divider(height: 1, color: Theme.of(context).dividerColor.withValues(alpha: 0.08)),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
                      ),
                      title: Text(
                        'Delete Account',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.error),
                      ),
                      onTap: () async {
                        await HapticFeedback.heavyImpact();
                        // TODO: Implement delete account logic
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48), // Bottom padding
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading profile: $err')),
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, bool isDark, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: isDark ? 0.4 : 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
