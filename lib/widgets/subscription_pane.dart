import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';

class SubscriptionPane extends StatefulWidget {
  const SubscriptionPane({super.key});

  @override
  State<SubscriptionPane> createState() => _SubscriptionPaneState();
}

class _SubscriptionPaneState extends State<SubscriptionPane> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  String _selectedPlan = 'monthly'; // 'weekly', 'monthly', 'yearly', 'lifetime'

  // Replace these with your actual Play Store product IDs
  static const String _kWeeklySubscriptionId = 'premium_weekly';
  static const String _kMonthlySubscriptionId = 'premium_monthly';
  static const String _kYearlySubscriptionId = 'premium_yearly';
  static const String _kLifetimeProductId = 'premium_lifetime';

  @override
  void initState() {
    super.initState();
    final purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error
    });
    initStoreInfo();
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = [];
      });
      return;
    }

    const Set<String> kIds = <String>{
      _kWeeklySubscriptionId,
      _kMonthlySubscriptionId,
      _kYearlySubscriptionId,
      _kLifetimeProductId,
    };
    final ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(kIds);

    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
    });
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // show pending UI
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // handle error
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          // Grant entitlement
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchase Successful!')),
          );
        }
        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _buySelectedPlan() {
    String productId;
    switch (_selectedPlan) {
      case 'weekly': productId = _kWeeklySubscriptionId; break;
      case 'monthly': productId = _kMonthlySubscriptionId; break;
      case 'yearly': productId = _kYearlySubscriptionId; break;
      case 'lifetime': productId = _kLifetimeProductId; break;
      default: return;
    }

    try {
      final productDetails = _products.firstWhere((p) => p.id == productId);
      final purchaseParam = PurchaseParam(productDetails: productDetails);
      if (_selectedPlan == 'lifetime') {
        _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam); // Subscriptions also use buyNonConsumable logic currently unless handled via specific APIs, RevenueCat highly recommended though.
      }
    } catch (e) {
      // Product not found natively yet, just show generic tap
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload to Play Console first to enable real purchases.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Premium'),
      ),
      body: SafeArea(
        child: Padding(
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
              
              _buildPlanOption(
                id: 'weekly',
                title: 'Weekly Plan',
                priceLabel: _getPriceFor(_kWeeklySubscriptionId, '\$1.99 per week'),
              ),
              const SizedBox(height: 12),
              
              _buildPlanOption(
                id: 'monthly',
                title: 'Monthly Plan',
                badgeText: 'Save 50%',
                originalPrice: '\$9.99',
                priceLabel: _getPriceFor(_kMonthlySubscriptionId, '\$4.99 per month'),
              ),
              const SizedBox(height: 12),
              
              _buildPlanOption(
                id: 'yearly',
                title: 'Yearly Plan',
                badgeText: 'Save 60%',
                originalPrice: '\$119.88',
                priceLabel: _getPriceFor(_kYearlySubscriptionId, '\$49.99 per year'),
              ),
              const SizedBox(height: 12),
              
              _buildPlanOption(
                id: 'lifetime',
                title: 'Lifetime',
                badgeText: 'One-time',
                priceLabel: _getPriceFor(_kLifetimeProductId, '\$149.99'),
              ),
              
              const Spacer(),
              ElevatedButton(
                onPressed: _buySelectedPlan,
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
            ],
          ),
        ),
      ),
    );
  }

  String _getPriceFor(String productId, String fallbackPrice) {
    try {
      final p = _products.firstWhere((element) => element.id == productId);
      return p.price; 
    } catch (_) {
      return fallbackPrice;
    }
  }

  Widget _buildPlanOption({
    required String id,
    required String title,
    required String priceLabel,
    String? badgeText,
    String? originalPrice,
  }) {
    final isSelected = _selectedPlan == id;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
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
        onTap: () {
          setState(() {
            _selectedPlan = id;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (badgeText != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (originalPrice != null) ...[
                          Text(
                            originalPrice,
                            style: TextStyle(
                              fontSize: 14,
                              decoration: TextDecoration.lineThrough,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          priceLabel,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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
    );
  }
}
