// ============================================================================
// مزود المصادقة - Auth Provider
// ============================================================================

import 'package:flutter/material.dart';
import '../models/models.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  String _selectedAccountType = 'customer';
  bool _isLoggedIn = false;

  UserModel? get currentUser => _currentUser;
  String get selectedAccountType => _selectedAccountType;
  bool get isLoggedIn => _isLoggedIn;

  void setAccountType(String type) {
    _selectedAccountType = type;
    notifyListeners();
  }

  Future<bool> login(String phone, String password) async {
    // Simulate login
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = UserModel(
      id: 'u1',
      name: _selectedAccountType == 'customer'
          ? 'أحمد الكربلائي'
          : _selectedAccountType == 'driver'
              ? 'حيدر الكعبي'
              : 'صاحب متجر الهناء',
      phone: phone,
      accountType: _selectedAccountType,
      address: 'كربلاء، شارع السنان، قرب الروضة',
      lat: 32.6160,
      lng: 44.0250,
    );

    _isLoggedIn = true;
    notifyListeners();
    return true;
  }

  Future<bool> register({
    required String name,
    required String phone,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    _currentUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      phone: phone,
      accountType: _selectedAccountType,
    );

    _isLoggedIn = true;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
