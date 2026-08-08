import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ──────────────── Stores ────────────────
  Future<List<StoreModel>> fetchStores() async {
    try {
      final querySnapshot = await _firestore
          .collection('stores')
          .get()
          .timeout(const Duration(seconds: 3));
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return StoreModel(
          id: doc.id,
          name: data['name']?.toString() ?? '',
          ownerId: data['owner_id']?.toString() ?? '',
          categoryId: data['category']?.toString() ?? 'grocery',
          address: data['address']?.toString() ?? '',
          phone: data['phone']?.toString() ?? '',
          isOpen: data['is_open'] as bool? ?? true,
          rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // ──────────────── Products ────────────────
  Future<List<ProductModel>> fetchProducts(String storeId) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('store_id', isEqualTo: storeId)
          .get()
          .timeout(const Duration(seconds: 3));
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ProductModel(
          id: doc.id,
          name: data['name']?.toString() ?? '',
          description: data['description']?.toString() ?? '',
          price: (data['price'] as num? ?? 0).toDouble(),
          unit: data['unit']?.toString() ?? 'عدد',
          categoryId: data['category']?.toString() ?? '',
          storeId: storeId,
          imageUrl: data['image_url']?.toString(),
          isAvailable: data['is_available'] as bool? ?? true,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Fetch all products in a specific category (useful for directory catalog)
  Future<List<ProductModel>> fetchProductsByCategory(String categoryId) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: categoryId)
          .get()
          .timeout(const Duration(seconds: 4));
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ProductModel(
          id: doc.id,
          name: data['name']?.toString() ?? '',
          description: data['description']?.toString() ?? '',
          price: (data['price'] as num? ?? 0).toDouble(),
          unit: data['unit']?.toString() ?? 'عدد',
          categoryId: categoryId,
          storeId: data['store_id']?.toString() ?? '',
          imageUrl: data['image_url']?.toString(),
          isAvailable: data['is_available'] as bool? ?? true,
          isHeavy: data['is_heavy'] as bool? ?? false,
          badge: data['badge']?.toString(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // ──────────────── Orders ────────────────
  Future<void> createOrder(OrderModel order) async {
    try {
      final orderRef = _firestore.collection('orders').doc(order.id);

      final itemsJson = order.items.map((item) {
        return {
          'product_name': item.productName,
          'quantity': item.quantity,
          'unit': item.unit,
          'price': item.price,
        };
      }).toList();

      // Write order header along with items array inside it (efficient NoSQL structure)
      await orderRef.set({
        'id': order.id,
        'order_number': DateTime.now().millisecondsSinceEpoch % 100000,
        'customer_id': order.customerId,
        'customer_name': order.customerName,
        'store_id': order.storeId,
        'store_name': order.storeName,
        'driver_id': order.driverId,
        'subtotal': order.subtotal,
        'delivery_fee': order.deliveryFee,
        'total': order.total,
        'status': order.status,
        'delivery_address': order.deliveryAddress,
        'delivery_lat': order.deliveryLat,
        'delivery_lng': order.deliveryLng,
        'created_at': FieldValue.serverTimestamp(),
        'items': itemsJson,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Stream active orders for realtime notifications and list updates
  Stream<List<Map<String, dynamic>>> streamOrders() {
    return _firestore
        .collection('orders')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Convert Timestamp to ISO String so the frontend doesn't crash on type mismatches
        if (data['created_at'] != null && data['created_at'] is Timestamp) {
          data['created_at'] = (data['created_at'] as Timestamp).toDate().toIso8601String();
        }
        return data;
      }).toList();
    });
  }

  // Update order status (realtime change)
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Assign driver to order
  Future<void> assignDriverToOrder(String orderId, String driverId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'driver_id': driverId,
        'status': 'processing',
      });
    } catch (e) {
      rethrow;
    }
  }
}
