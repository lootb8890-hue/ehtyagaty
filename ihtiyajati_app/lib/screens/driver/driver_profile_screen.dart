import 'package:flutter/material.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('حساب السائق')),
    body: const Center(child: Text('الحساب الشخصي للسائق')),
  );
}
