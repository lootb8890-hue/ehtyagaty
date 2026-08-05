import 'package:flutter/material.dart';

class StoreProductsScreen extends StatelessWidget {
  const StoreProductsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('إدارة المنتجات')),
    body: const Center(child: Text('شاشة إدارة منتجات المتجر')),
  );
}
