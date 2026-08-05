// ============================================================================
// تطبيق احتياجاتي - نظام التنقل (Routes)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth/account_type_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/customer/customer_home_screen.dart';
import '../screens/customer/category_products_screen.dart';
import '../screens/customer/cart_screen.dart';
import '../screens/customer/order_tracking_screen.dart';
import '../screens/customer/customer_profile_screen.dart';
import '../screens/driver/driver_home_screen.dart';
import '../screens/driver/driver_earnings_screen.dart';
import '../screens/driver/driver_profile_screen.dart';
import '../screens/store/store_dashboard_screen.dart';
import '../screens/store/store_orders_screen.dart';
import '../screens/store/store_products_screen.dart';
import '../screens/store/store_profile_screen.dart';

class AppRoutes {
  // Route Paths
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String accountType = '/account-type';
  static const String login = '/login';
  static const String register = '/register';

  // Customer Routes
  static const String customerHome = '/customer';
  static const String categoryProducts = '/customer/category/:categoryId';
  static const String cart = '/customer/cart';
  static const String orderTracking = '/customer/order-tracking/:orderId';
  static const String customerProfile = '/customer/profile';

  // Driver Routes
  static const String driverHome = '/driver';
  static const String driverEarnings = '/driver/earnings';
  static const String driverProfile = '/driver/profile';

  // Store Routes
  static const String storeDashboard = '/store';
  static const String storeOrders = '/store/orders';
  static const String storeProducts = '/store/products';
  static const String storeProfile = '/store/profile';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        pageBuilder: (context, state) => _buildPage(
          const SplashScreen(),
          state,
        ),
      ),
      GoRoute(
        path: onboarding,
        pageBuilder: (context, state) => _buildPage(
          const OnboardingScreen(),
          state,
        ),
      ),
      GoRoute(
        path: accountType,
        pageBuilder: (context, state) => _buildPage(
          const AccountTypeScreen(),
          state,
        ),
      ),
      GoRoute(
        path: login,
        pageBuilder: (context, state) => _buildPage(
          LoginScreen(
            accountType: state.uri.queryParameters['type'] ?? 'customer',
          ),
          state,
        ),
      ),
      GoRoute(
        path: register,
        pageBuilder: (context, state) => _buildPage(
          RegisterScreen(
            accountType: state.uri.queryParameters['type'] ?? 'customer',
          ),
          state,
        ),
      ),

      // ──── Customer Routes ────
      GoRoute(
        path: customerHome,
        pageBuilder: (context, state) => _buildPage(
          const CustomerHomeScreen(),
          state,
        ),
      ),
      GoRoute(
        path: '/customer/category/:categoryId',
        pageBuilder: (context, state) => _buildPage(
          CategoryProductsScreen(
            categoryId: state.pathParameters['categoryId']!,
          ),
          state,
        ),
      ),
      GoRoute(
        path: cart,
        pageBuilder: (context, state) => _buildPage(
          const CartScreen(),
          state,
        ),
      ),
      GoRoute(
        path: '/customer/order-tracking/:orderId',
        pageBuilder: (context, state) => _buildPage(
          OrderTrackingScreen(
            orderId: state.pathParameters['orderId']!,
          ),
          state,
        ),
      ),
      GoRoute(
        path: customerProfile,
        pageBuilder: (context, state) => _buildPage(
          const CustomerProfileScreen(),
          state,
        ),
      ),

      // ──── Driver Routes ────
      GoRoute(
        path: driverHome,
        pageBuilder: (context, state) => _buildPage(
          const DriverHomeScreen(),
          state,
        ),
      ),
      GoRoute(
        path: driverEarnings,
        pageBuilder: (context, state) => _buildPage(
          const DriverEarningsScreen(),
          state,
        ),
      ),
      GoRoute(
        path: driverProfile,
        pageBuilder: (context, state) => _buildPage(
          const DriverProfileScreen(),
          state,
        ),
      ),

      // ──── Store Routes ────
      GoRoute(
        path: storeDashboard,
        pageBuilder: (context, state) => _buildPage(
          const StoreDashboardScreen(),
          state,
        ),
      ),
      GoRoute(
        path: storeOrders,
        pageBuilder: (context, state) => _buildPage(
          const StoreOrdersScreen(),
          state,
        ),
      ),
      GoRoute(
        path: storeProducts,
        pageBuilder: (context, state) => _buildPage(
          const StoreProductsScreen(),
          state,
        ),
      ),
      GoRoute(
        path: storeProfile,
        pageBuilder: (context, state) => _buildPage(
          const StoreProfileScreen(),
          state,
        ),
      ),
    ],
  );

  static Page<dynamic> _buildPage(Widget child, GoRouterState state) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        );
      },
    );
  }
}
