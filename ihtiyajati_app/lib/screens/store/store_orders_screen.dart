import 'package:flutter/material.dart';

class StoreOrdersScreen extends StatelessWidget {
  const StoreOrdersScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('إدارة الطلبات')),
    body: const Center(child: Text('شاشة إدارة طلبات المتجر')),
  );
}
