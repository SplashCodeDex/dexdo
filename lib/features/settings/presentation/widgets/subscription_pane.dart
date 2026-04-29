import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../../core/services/subscription_service.dart';

class SubscriptionPane extends ConsumerStatefulWidget {
  const SubscriptionPane({super.key});

  @override
  ConsumerState<SubscriptionPane> createState() => _SubscriptionPaneState();
}

class _SubscriptionPaneState extends ConsumerState<SubscriptionPane> {
  String _selectedPackageType = 'monthly'; // 'weekly', 'monthly', 'yearly', 'lifetime'

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionProvider);
    final subscriptionNotifier = ref.read(subscriptionProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final offerings = subscriptionState.offerings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Premium'),
      ),
      body: SafeArea(
        child: offerings == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Choose Your Plan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  if (offerings.current != null) ...[
                    ...offerings.current!.availablePackages.map((package) {
                      String title = package.packageType.toString().split('.').last;
                      // Mapping package types to readable titles
                      if (package.packageType == PackageType.weekly) title = 'Weekly Plan';
                      if (package.packageType == PackageType.monthly) title = 'Monthly Plan';
                      if (package.packageType == PackageType.annual) title = 'Yearly Plan';
                      if (package.packageType == PackageType.lifetime) title = 'Lifetime';

                      return _buildPackageOption(
                        package: package,
                        title: title,
                        isSelected: _selectedPackageType == package.packageType.toString(),
                        onTap: () => setState(() => _selectedPackageType = package.packageType.toString()),
                      );
                    }),
                  ] else 
                    const Center(child: Text('No active offerings found.')),
                  
                  const Spacer(),
                  if (subscriptionState.isPremium)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 12),
                          Text('You have an active Premium subscription!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: () async {
                        final selectedPackage = offerings.current?.availablePackages.firstWhere(
                          (p) => p.packageType.toString() == _selectedPackageType,
                          orElse: () => offerings.current!.availablePackages.first,
                        );
                        if (selectedPackage != null) {
                          final success = await subscriptionNotifier.purchasePackage(selectedPackage);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Welcome to Premium!')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 2,
                      ),
                      child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => subscriptionNotifier.restorePurchases(),
                    child: const Text('Restore Purchases'),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildPackageOption({
    required Package package,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: isSelected ? 2 : 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        color: isSelected ? colorScheme.primary.withValues(alpha: 0.08) : colorScheme.surface,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        package.storeProduct.priceString,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


