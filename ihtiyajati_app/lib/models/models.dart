// ============================================================================
// نماذج البيانات - المستخدم / المنتج / الطلب / المتجر / الفئة / السائق
// ============================================================================

// ──────────────── User Model ────────────────
class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String accountType; // customer, driver, store
  final String? avatarUrl;
  final String? address;
  final double? lat;
  final double? lng;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.accountType,
    this.avatarUrl,
    this.address,
    this.lat,
    this.lng,
  });
}

// ──────────────── Category Model ────────────────
class CategoryModel {
  final String id;
  final String name;
  final String nameEn;
  final String icon; // Icon name or asset path
  final int colorValue;
  final String? description;

  CategoryModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.icon,
    required this.colorValue,
    this.description,
  });
}

// ──────────────── Product Model ────────────────
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String unit; // كيس، طن، حبة، etc.
  final String categoryId;
  final String storeId;
  final String? imageUrl;
  final bool isAvailable;
  final bool isHeavy; // for construction materials / heavy delivery
  final String? badge; // "توصيل سريع", "خصم", etc.

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.categoryId,
    required this.storeId,
    this.imageUrl,
    this.isAvailable = true,
    this.isHeavy = false,
    this.badge,
  });
}

// ──────────────── Cart Item ────────────────
class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}

// ──────────────── Order Model ────────────────
class OrderModel {
  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String storeId;
  final String storeName;
  final String? driverId;
  final String? driverName;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String status; // new, processing, ready, in_transit, delivered, cancelled
  final String deliveryAddress;
  final double? deliveryLat;
  final double? deliveryLng;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final bool isHeavyDelivery;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.storeId,
    required this.storeName,
    this.driverId,
    this.driverName,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.deliveryAddress,
    this.deliveryLat,
    this.deliveryLng,
    required this.createdAt,
    this.deliveredAt,
    this.isHeavyDelivery = false,
  });
}

class OrderItem {
  final String productName;
  final int quantity;
  final double price;
  final String unit;

  OrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
    required this.unit,
  });

  double get total => price * quantity;
}

// ──────────────── Store Model ────────────────
class StoreModel {
  final String id;
  final String name;
  final String ownerId;
  final String categoryId;
  final String address;
  final String phone;
  final double? lat;
  final double? lng;
  final String? imageUrl;
  final double rating;
  final bool isOpen;

  StoreModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.categoryId,
    required this.address,
    required this.phone,
    this.lat,
    this.lng,
    this.imageUrl,
    this.rating = 5.0,
    this.isOpen = true,
  });
}

// ──────────────── Driver Model ────────────────
class DriverModel {
  final String id;
  final String name;
  final String phone;
  final String vehicleType; // motorcycle, car, truck, crane
  final String vehicleName;
  final double rating;
  final bool isOnline;
  final double todayEarnings;
  final int completedOrders;
  final double? lat;
  final double? lng;

  DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicleType,
    required this.vehicleName,
    this.rating = 5.0,
    this.isOnline = true,
    this.todayEarnings = 0,
    this.completedOrders = 0,
    this.lat,
    this.lng,
  });
}
