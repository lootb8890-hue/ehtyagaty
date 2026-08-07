// ============================================================================
// مزود المصادقة - Auth Provider المتكامل مع Supabase
// ============================================================================

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../config/firebase_config.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  String _selectedAccountType = 'customer';
  bool _isLoggedIn = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  String get selectedAccountType => _selectedAccountType;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;

  void setAccountType(String type) {
    _selectedAccountType = type;
    notifyListeners();
  }

  // Clear any existing error messages
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  bool _isConfigPlaceholder() {
    return FirebaseConfig.apiKey.contains('YOUR_API_KEY') ||
        FirebaseConfig.appId.contains('YOUR_APP_ID');
  }

  // Attempt login using Firebase
  Future<bool> login(String phone, String password) async {
    _errorMessage = null;
    notifyListeners();

    if (_isConfigPlaceholder()) {
      _errorMessage = '⚠️ يرجى إعداد مفاتيح الاتصال بـ Firebase أولاً في ملف `firebase_config.dart`.';
      notifyListeners();
      return false;
    }

    try {
      final user = await _authService.signInWithPhone(
        phone: phone,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        _isLoggedIn = true;
        _selectedAccountType = user.accountType;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'فشل تسجيل الدخول: يرجى التحقق من رقم الهاتف أو كلمة المرور أو اتصال الشبكة.\nتفاصيل: ${e.toString().split('\n').first}';
      notifyListeners();
    }
    return false;
  }

  // Generate and send custom OTP via WhatsApp/Telegram
  Future<void> sendSMSOTP({
    required String phone,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onFailed,
  }) async {
    _errorMessage = null;
    notifyListeners();

    if (_isConfigPlaceholder()) {
      onFailed('⚠️ يرجى إعداد مفاتيح الاتصال بـ Firebase أولاً في ملف `firebase_config.dart`.');
      return;
    }

    try {
      final code = await _authService.sendCustomOTP(phone: phone);
      // Pass the generated code as the verification ID to check locally
      onCodeSent(code);
    } catch (e) {
      onFailed('فشل إرسال الرمز: ${e.toString()}');
    }
  }

  // Complete registration after verifying custom OTP code locally
  Future<bool> verifyOTPAndSignUp({
    required String verificationId,
    required String smsCode,
    required String name,
    required String phone,
    required String password,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if entered code matches the generated OTP code
      if (smsCode.trim() != verificationId.trim()) {
        _errorMessage = 'رمز التحقق غير صحيح، يرجى إدخال الرمز الصحيح المستلم.';
        notifyListeners();
        return false;
      }

      // Create the account using email registration
      final user = await _authService.signUpWithPhone(
        phone: phone,
        password: password,
        name: name,
        accountType: _selectedAccountType,
      );

      if (user != null) {
        _currentUser = user;
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'فشل تسجيل الحساب: ${e.toString().split('\n').first}';
      notifyListeners();
    }
    return false;
  }

  // Sign out and clear local state
  Future<void> logout() async {
    try {
      await _authService.signOut();
    } catch (_) {}
    _currentUser = null;
    _isLoggedIn = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Auto login check if session is already active
  Future<void> checkCurrentUser() async {
    final user = await _authService.getCurrentProfile();
    if (user != null) {
      _currentUser = user;
      _isLoggedIn = true;
      _selectedAccountType = user.accountType;
      notifyListeners();
    }
  }
}
