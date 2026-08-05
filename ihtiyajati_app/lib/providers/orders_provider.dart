// ============================================================================
// مزود الطلبات - Orders Provider
// ============================================================================

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/mock_data.dart';

class OrdersProvider extends ChangeNotifier {
  final List<OrderModel> _orders = MockData.storeOrders;

  List<OrderModel> get orders => _orders;

  List<OrderModel> get newOrders =>
      _orders.where((o) => o.status == 'new').toList();
  List<OrderModel> get processingOrders =>
      _orders.where((o) => o.status == 'processing').toList();
  List<OrderModel> get readyOrders =>
      _orders.where((o) => o.status == 'ready').toList();
  List<OrderModel> get deliveredOrders =>
      _orders.where((o) => o.status == 'delivered').toList();

  void updateOrderStatus(String orderId, String newStatus) {
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
        deliveredAt:
            newStatus == 'delivered' ? DateTime.now() : old.deliveredAt,
        isHeavyDelivery: old.isHeavyDelivery,
      );
      notifyListeners();
    }
  }

  void addOrder(OrderModel order) {
    _orders.insert(0, order);
    notifyListeners();
  }
}
