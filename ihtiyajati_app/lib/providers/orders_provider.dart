// ============================================================================
// مزود الطلبات - Orders Provider متصل بـ Supabase
// ============================================================================

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/mock_data.dart';
import '../services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final List<OrderModel> _orders = List.from(MockData.storeOrders);

  List<OrderModel> get orders => _orders;

  List<OrderModel> get newOrders =>
      _orders.where((o) => o.status == 'new' || o.status == 'الطلبات الجديدة').toList();
  List<OrderModel> get processingOrders =>
      _orders.where((o) => o.status == 'processing' || o.status == 'قيد التجهيز').toList();
  List<OrderModel> get readyOrders =>
      _orders.where((o) => o.status == 'ready' || o.status == 'جاهزة للاستلام').toList();
  List<OrderModel> get deliveredOrders =>
      _orders.where((o) => o.status == 'delivered' || o.status == 'تم التوصيل').toList();

  bool get _isFirebaseInitialized {
    try {
      FirebaseFirestore.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  // Update order status on local cache and sync to Firestore
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      final old = _orders[index];
      _orders[index] = OrderModel(
        id: old.id,
        orderNumber: old.orderNumber,
        customerId: old.customerId,
        customerName: old.customerName,
        storeId: old.storeId,
        storeName: old.storeName,
        driverId: old.driverId,
        driverName: old.driverName,
        items: old.items,
        subtotal: old.subtotal,
        deliveryFee: old.deliveryFee,
        total: old.total,
        status: newStatus,
        deliveryAddress: old.deliveryAddress,
        deliveryLat: old.deliveryLat,
        deliveryLng: old.deliveryLng,
        createdAt: old.createdAt,
        deliveredAt: newStatus == 'delivered' ? DateTime.now() : old.deliveredAt,
        isHeavyDelivery: old.isHeavyDelivery,
      );
      notifyListeners();
    }

    if (_isFirebaseInitialized) {
      try {
        await _dbService.updateOrderStatus(orderId, newStatus);
      } catch (e) {
        debugPrint('Failed to sync order status update to Firebase: $e');
      }
    }
  }

  // Add a new order and write to Firestore
  Future<void> addOrder(OrderModel order) async {
    _orders.insert(0, order);
    notifyListeners();

    if (_isFirebaseInitialized) {
      try {
        await _dbService.createOrder(order);
      } catch (e) {
        debugPrint('Failed to save order to Firebase: $e');
      }
    }
  }
}
