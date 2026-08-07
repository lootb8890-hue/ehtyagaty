// ============================================================================
// تطبيق احتياجاتي - نقطة الدخول الرئيسية (main.dart)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/app_theme.dart';
import 'config/app_routes.dart';
import 'config/firebase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/orders_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Async non-blocking Firebase initialization
  Firebase.initializeApp(
    options: FirebaseConfig.currentPlatform,
  ).catchError((e) {
    debugPrint('Firebase initialization failed: $e');
    return Firebase.app();
  });

  try {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.surfaceDarker,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (_) {}

  runApp(const IhtiyajatiApp());
}

class IhtiyajatiApp extends StatelessWidget {
  const IhtiyajatiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
      ],
      child: MaterialApp.router(
        title: 'احتياجاتي',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRoutes.router,
        locale: const Locale('ar', 'IQ'),
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
      ),
    );
  }
}
