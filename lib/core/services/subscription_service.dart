import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionState {
  final bool isPremium;
  final Offerings? offerings;

  SubscriptionState({
    this.isPremium = false,
    this.offerings,
  });

  SubscriptionState copyWith({
    bool? isPremium,
    Offerings? offerings,
  }) {
    return SubscriptionState(
      isPremium: isPremium ?? this.isPremium,
      offerings: offerings ?? this.offerings,
    );
  }
}

class SubscriptionNotifier extends Notifier<SubscriptionState> {
  static const String _publicSdkKeyAndroid = 'goog_placeholder_key'; // Users should replace with real RC key
  static const String _publicSdkKeyIos = 'appl_placeholder_key';

  @override
  SubscriptionState build() {
    _init();
    return SubscriptionState();
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
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    _updateEntitlementStatus(customerInfo);

    // Listen for customer info updates
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      _updateEntitlementStatus(customerInfo);
    });

    await fetchOfferings();
  }

  void _updateEntitlementStatus(CustomerInfo customerInfo) {
    // Replace 'premium' with your entitlement ID from RevenueCat dashboard
    final isPremium = customerInfo.entitlements.active.containsKey('premium');
    state = state.copyWith(isPremium: isPremium);
  }

  Future<void> fetchOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      state = state.copyWith(offerings: offerings);
    } catch (e) {
      debugPrint('Error fetching offerings: $e');
    }
  }

  Future<bool> purchasePackage(Package package) async {
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      _updateEntitlementStatus(customerInfo);
      return state.isPremium;
    } catch (e) {
      debugPrint('Purchase error: $e');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      _updateEntitlementStatus(customerInfo);
    } catch (e) {
      debugPrint('Restore error: $e');
    }
  }
}

final subscriptionProvider = NotifierProvider<SubscriptionNotifier, SubscriptionState>(() {
  return SubscriptionNotifier();
});
