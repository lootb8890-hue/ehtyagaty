// ============================================================================
// مزود سلة المشتريات - Cart Provider
// ============================================================================

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../config/app_constants.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
  int get itemCount => _items.length;
  bool get isEmpty => _items.isEmpty;

  double get subtotal => _items.fold(0, (sum, item) => sum + item.total);

  bool get hasHeavyItems => _items.any((item) => item.product.isHeavy);

  double get deliveryFee =>
      hasHeavyItems ? AppConstants.heavyDeliveryFee.toDouble() : AppConstants.deliveryFee.toDouble();

  double get grandTotal => subtotal + deliveryFee;

  void addItem(ProductModel product) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
