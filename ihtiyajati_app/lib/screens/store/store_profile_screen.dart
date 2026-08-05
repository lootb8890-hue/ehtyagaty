import 'package:flutter/material.dart';

class StoreProfileScreen extends StatelessWidget {
  const StoreProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('حساب المتجر')),
    body: const Center(child: Text('الحساب الشخصي لصاحب المتجر')),
  );
}
