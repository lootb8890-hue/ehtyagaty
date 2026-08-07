import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current auth user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Helper to fetch dynamic notification configs managed from the Admin Panel Settings
  Future<Map<String, dynamic>> _getNotificationConfig() async {
    try {
      final doc = await _firestore.collection('settings').doc('notification_config').get();
      if (doc.exists) {
        return doc.data() ?? {};
      } else {
        // Initialize default configuration document if missing
        final defaultConfig = {
          'whatsapp_api_url': 'https://ihtiyajati-whatsapp.onrender.com/send-otp',
          'whatsapp_token': 'local_gateway',
          'telegram_bot_token': 'YOUR_TELEGRAM_BOT_TOKEN',
          'telegram_chat_id': 'YOUR_TELEGRAM_CHAT_ID',
          'provider': 'both', // 'whatsapp', 'telegram', 'both', 'none'
        };
        await _firestore.collection('settings').doc('notification_config').set(defaultConfig);
        return defaultConfig;
      }
    } catch (_) {}
    return {
      'whatsapp_api_url': 'https://ihtiyajati-whatsapp.onrender.com/send-otp',
      'whatsapp_token': 'local_gateway',
      'provider': 'both',
    };
  }

  // 1. Generate and send custom OTP via WhatsApp and Telegram using settings from Firestore
  Future<String> sendCustomOTP({
    required String phone,
  }) async {
    try {
      final cleanPhone = phone.trim().replaceAll(' ', '');
      final formattedPhone = cleanPhone;
      final otpCode = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
      final messageText = 'رمز التحقق الخاص بك لتطبيق احتياجاتي هو: $otpCode';
      
      // Fetch dynamic API credentials
      final config = await _getNotificationConfig();
      final provider = config['provider'] ?? 'both';
      String whatsappUrl = (config['whatsapp_api_url'] != null && config['whatsapp_api_url'].toString().isNotEmpty)
          ? config['whatsapp_api_url'].toString()
          : 'https://ihtiyajati-whatsapp.onrender.com/send-otp';
      final whatsappToken = (config['whatsapp_token'] != null && config['whatsapp_token'].toString().isNotEmpty)
          ? config['whatsapp_token'].toString()
          : 'local_gateway';
      final telegramBotToken = config['telegram_bot_token'] ?? '';
      final telegramChatId = config['telegram_chat_id'] ?? '';

      // Build list of target Gateway URLs (adapts for Emulator 10.0.2.2, Physical Phone 192.168.0.109, and Localhost)
      final Set<String> targetUrls = {};
      if (whatsappUrl.isNotEmpty) targetUrls.add(whatsappUrl);

      if (whatsappUrl.contains('localhost')) {
        if (!kIsWeb && Platform.isAndroid) {
          targetUrls.add(whatsappUrl.replaceAll('localhost', '10.0.2.2'));
        }
        targetUrls.add(whatsappUrl.replaceAll('localhost', '192.168.0.109'));
      } else if (whatsappUrl.contains('10.0.2.2')) {
        targetUrls.add(whatsappUrl.replaceAll('10.0.2.2', '192.168.0.109'));
        targetUrls.add(whatsappUrl.replaceAll('10.0.2.2', 'localhost'));
      }

      // Add standard local fallbacks
      if (!kIsWeb && Platform.isAndroid) {
        targetUrls.add('http://10.0.2.2:3000/send-otp');
      }
      targetUrls.add('http://localhost:3000/send-otp');
      targetUrls.add('http://10.178.131.117:3000/send-otp');
      targetUrls.add('http://192.168.0.109:3000/send-otp');

      // Send via WhatsApp (Local Gateway API)
      if (provider == 'whatsapp' || provider == 'both' || provider.isEmpty) {
        bool sentSuccessfully = false;
        for (final targetUrl in targetUrls) {
          try {
            final url = Uri.parse(targetUrl);
            print('📱 Sending WhatsApp OTP to $formattedPhone via $url...');
            final res = await http.post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'token': whatsappToken,
                'to': formattedPhone,
                'body': messageText,
              }),
            ).timeout(const Duration(seconds: 4));
            print('✅ WhatsApp OTP Send Result [${res.statusCode}]: ${res.body}');
            if (res.statusCode == 200) {
              sentSuccessfully = true;
              break;
            }
          } catch (e) {
            print('❌ WhatsApp OTP Send Error ($targetUrl): $e');
          }
        }
      }

      // Send via Telegram Bot API (logs OTP to admin channel/chat)
      if ((provider == 'telegram' || provider == 'both') && 
          telegramBotToken.isNotEmpty && 
          telegramChatId.isNotEmpty && 
          !telegramBotToken.contains('YOUR_')) {
        try {
          final url = Uri.parse('https://api.telegram.org/bot$telegramBotToken/sendMessage');
          await http.post(url, body: {
            'chat_id': telegramChatId,
            'text': '🔔 [إشعار تفعيل احتياجاتي]\nرقم الهاتف: +$formattedPhone\nرمز التحقق الجديد: $otpCode',
          });
        } catch (e) {
          print('Telegram OTP Send Error: $e');
        }
      }

      // Fallback: Always print to console/debug so developer can test without config
      print('\n====================================');
      print('🔑 OTP FOR +$formattedPhone: $otpCode');
      print('====================================\n');

      return otpCode;
    } catch (e) {
      rethrow;
    }
  }

  // 2. Complete sign up by creating email credentials internally
  Future<UserModel?> signUpWithPhone({
    required String phone,
    required String password,
    required String name,
    required String accountType, // 'customer', 'driver', 'store'
  }) async {
    try {
      final cleanPhone = phone.trim().replaceAll(' ', '');
      final mockEmail = '$cleanPhone@ihtiyajati.com';

      // Create email/password user in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: mockEmail,
        password: password,
      );

      final user = credential.user;
      if (user == null) return null;

      // Save user profile in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'phone': cleanPhone,
        'full_name': name,
        'role': accountType,
        'created_at': FieldValue.serverTimestamp(),
      });

      return UserModel(
        id: user.uid,
        name: name,
        phone: cleanPhone,
        accountType: accountType,
      );
    } catch (e) {
      rethrow;
    }
  }

  // 3. Sign in using translated mock email to allow password logins
  Future<UserModel?> signInWithPhone({
    required String phone,
    required String password,
  }) async {
    try {
      final cleanPhone = phone.trim().replaceAll(' ', '');
      final mockEmail = '$cleanPhone@ihtiyajati.com';

      final credential = await _auth.signInWithEmailAndPassword(
        email: mockEmail,
        password: password,
      );

      final user = credential.user;
      if (user == null) return null;

      // Fetch user profile from Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        return UserModel(
          id: user.uid,
          name: 'مستخدم جديد',
          phone: cleanPhone,
          accountType: 'customer',
        );
      }

      final data = doc.data()!;
      return UserModel(
        id: user.uid,
        name: data['full_name'] ?? 'مستخدم احتياجاتي',
        phone: data['phone'] ?? cleanPhone,
        accountType: data['role'] ?? 'customer',
      );
    } catch (e) {
      rethrow;
    }
  }

  // Fetch current user details
  Future<UserModel?> getCurrentProfile() async {
    final uid = currentUserId;
    if (uid == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return UserModel(
        id: uid,
        name: data['full_name'] ?? '',
        phone: data['phone'] ?? '',
        accountType: data['role'] ?? 'customer',
      );
    } catch (e) {
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
