// Placeholder screen for order tracking
import 'package:flutter/material.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تتبع الطلب #$orderId')),
      body: const Center(child: Text('شاشة تتبع الطلب - الخريطة ستضاف لاحقاً')),
    );
  }
}
