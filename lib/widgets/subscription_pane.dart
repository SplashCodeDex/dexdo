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
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              _buildPlanOption(
                id: 'weekly',
                title: 'Weekly Plan',
                priceLabel: _getPriceFor(_kWeeklySubscriptionId, 'GH₵10.00 per week'),
              ),
              const SizedBox(height: 12),
              
              _buildPlanOption(
                id: 'monthly',
                title: 'Monthly Plan',
                badgeText: 'Save 54%',
                originalPrice: '₵43.30',
                priceLabel: _getPriceFor(_kMonthlySubscriptionId, 'GH₵20.00 per month'),
              ),
              const SizedBox(height: 12),
              
              _buildPlanOption(
                id: 'yearly',
                title: 'Yearly Plan',
                badgeText: 'Save 50%',
                originalPrice: '₵240.00',
                priceLabel: _getPriceFor(_kYearlySubscriptionId, 'GH₵120.00 per year'),
              ),
              const SizedBox(height: 12),
              
              _buildPlanOption(
                id: 'lifetime',
                title: 'Lifetime - One-time payment',
                priceLabel: _getPriceFor(_kLifetimeProductId, 'GH₵360.00'),
              ),
              
              const Spacer(),
              ElevatedButton(
                onPressed: _buySelectedPlan,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
      return p.price; // This will return things like "$1.99" localized!
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
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.05) : Colors.transparent,
        ),
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
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red[500],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (originalPrice != null) ...[
                        Text(
                          originalPrice,
                          style: TextStyle(
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        priceLabel,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
