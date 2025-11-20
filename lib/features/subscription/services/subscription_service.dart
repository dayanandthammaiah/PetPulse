import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io';

class SubscriptionService {
  static const String _apiKeyAndroid = String.fromEnvironment('RC_ANDROID_KEY', defaultValue: 'goog_YOUR_ANDROID_API_KEY');
  static const String _apiKeyIOS = String.fromEnvironment('RC_IOS_KEY', defaultValue: 'appl_YOUR_IOS_API_KEY');

  static const String entitlementId = 'pro_access';

  Future<void> init() async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration? configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_apiKeyAndroid);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(_apiKeyIOS);
    }

    if (configuration != null) {
      await Purchases.configure(configuration);
    }
  }

  Future<List<Package>> getOfferings() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        return offerings.current!.availablePackages;
      }
    } catch (e) {
      // Handle error
    }
    return [];
  }

  Future<bool> purchasePackage(Package package) async {
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkSubscriptionStatus() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } catch (e) {
      return false;
    }
  }
}
