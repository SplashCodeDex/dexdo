import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService extends ChangeNotifier {
  static const String _publicSdkKeyAndroid = 'goog_placeholder_key'; // Users should replace with real RC key
  static const String _publicSdkKeyIos = 'appl_placeholder_key';

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  Offerings? _offerings;
  Offerings? get offerings => _offerings;

  SubscriptionService() {
    _init();
  }

  Future<void> _init() async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration? configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_publicSdkKeyAndroid);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(_publicSdkKeyIos);
    }

    if (configuration != null) {
      await Purchases.configure(configuration);
    }

    // Check current entitlement status
    final CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    _updateEntitlementStatus(customerInfo);

    // Listen for customer info updates
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      _updateEntitlementStatus(customerInfo);
    });

    await fetchOfferings();
  }

  void _updateEntitlementStatus(CustomerInfo customerInfo) {
    // Replace 'premium' with your entitlement ID from RevenueCat dashboard
    _isPremium = customerInfo.entitlements.active.containsKey('premium');
    notifyListeners();
  }

  Future<void> fetchOfferings() async {
    try {
      _offerings = await Purchases.getOfferings();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching offerings: $e');
    }
  }

  Future<bool> purchasePackage(Package package) async {
    try {
      final PurchaseResult result = await Purchases.purchase(
        PurchaseParams.package(package),
      );
      _updateEntitlementStatus(result.customerInfo);
      return _isPremium;
    } catch (e) {
      debugPrint('Purchase error: $e');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      final CustomerInfo customerInfo = await Purchases.restorePurchases();
      _updateEntitlementStatus(customerInfo);
    } catch (e) {
      debugPrint('Restore error: $e');
    }
  }
}
