// ============================================================================
// تطبيق احتياجاتي - ملف الثوابت والإعدادات العامة
// ============================================================================

class AppConstants {
  // App Info
  static const String appName = 'احتياجاتي';
  static const String appNameEn = 'Ihtiyajati';
  static const String appTagline = 'منظومة التوصيل الشامل';
  static const String appCity = 'كربلاء المقدسة، العراق';
  static const String currency = 'د.ع';
  static const String currencyCode = 'IQD';

  // Karbala Coordinates
  static const double karbalaLat = 32.6160;
  static const double karbalaLng = 44.0250;

  // Account Types
  static const String accountCustomer = 'customer';
  static const String accountDriver = 'driver';
  static const String accountStore = 'store';

  // Order Statuses
  static const String orderNew = 'new';
  static const String orderProcessing = 'processing';
  static const String orderReady = 'ready';
  static const String orderInTransit = 'in_transit';
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';

  // Delivery fee
  static const int deliveryFee = 5000; // 5,000 IQD
  static const int heavyDeliveryFee = 12000; // 12,000 IQD

  // Animations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 400);
  static const Duration animSlow = Duration(milliseconds: 800);
}
