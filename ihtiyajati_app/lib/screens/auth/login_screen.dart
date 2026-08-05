// ============================================================================
// شاشة تسجيل الدخول
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  final String accountType;
  const LoginScreen({super.key, required this.accountType});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  String get _accountTitle {
    switch (widget.accountType) {
      case 'driver':
        return 'حساب السائق';
      case 'store':
        return 'حساب المتجر';
      default:
        return 'حساب الزبون';
    }
  }

  IconData get _accountIcon {
    switch (widget.accountType) {
      case 'driver':
        return Icons.delivery_dining;
      case 'store':
        return Icons.store;
      default:
        return Icons.person;
    }
  }

  Color get _accentColor {
    switch (widget.accountType) {
      case 'driver':
        return AppTheme.primaryBlue;
      case 'store':
        return AppTheme.primaryGold;
      default:
        return AppTheme.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back button
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => context.go('/account-type'),
                    icon: const Icon(Icons.arrow_forward_ios,
                        color: AppTheme.textSecondary),
                  ),
                ),

                const SizedBox(height: 20),

                // Header
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: _accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _accentColor.withValues(alpha: 0.3)),
                    ),
                    child: Icon(_accountIcon, size: 36, color: _accentColor),
                  ),
                ).animate().fadeIn().scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                    ),

                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'تسجيل الدخول',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ).animate().fadeIn(delay: 200.ms),

                Center(
                  child: Text(
                    _accountTitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: _accentColor),
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 40),

                // Phone field
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    hintText: 'رقم الهاتف (07XX...)',
                    prefixIcon:
                        Icon(Icons.phone_android, color: _accentColor),
                    prefixText: '+964 ',
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 16),

                // Password field
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'كلمة المرور',
                    prefixIcon: Icon(Icons.lock_outline, color: _accentColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppTheme.textMuted,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 12),

                // Forgot password
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'نسيت كلمة المرور؟',
                      style: TextStyle(color: _accentColor),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Login button
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('تسجيل الدخول',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                  ),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 24),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('ليس لديك حساب؟',
                        style: TextStyle(color: AppTheme.textMuted)),
                    TextButton(
                      onPressed: () =>
                          context.go('/register?type=${widget.accountType}'),
                      child: Text('سجل الآن',
                          style: TextStyle(
                              color: _accentColor,
                              fontWeight: FontWeight.w800)),
                    ),
                  ],
                ).animate().fadeIn(delay: 700.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_phoneController.text.isEmpty) return;
    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    auth.setAccountType(widget.accountType);
    await auth.login(_phoneController.text, _passwordController.text);

    if (mounted) {
      setState(() => _isLoading = false);
      switch (widget.accountType) {
        case 'driver':
          context.go('/driver');
          break;
        case 'store':
          context.go('/store');
          break;
        default:
          context.go('/customer');
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
