// ============================================================================
// شاشة التسجيل الجديد
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  final String accountType;
  const RegisterScreen({super.key, required this.accountType});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.accountType == 'driver'
        ? AppTheme.primaryBlue
        : widget.accountType == 'store'
            ? AppTheme.primaryGold
            : AppTheme.primaryGreen;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => context.go('/login?type=${widget.accountType}'),
                    icon: const Icon(Icons.arrow_forward_ios,
                        color: AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(height: 20),

                Center(
                  child: Text(
                    'إنشاء حساب جديد',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ).animate().fadeIn(),

                const SizedBox(height: 40),

                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'الاسم الكامل',
                    prefixIcon: Icon(Icons.person_outline, color: accentColor),
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 16),

                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    hintText: 'رقم الهاتف',
                    prefixIcon: Icon(Icons.phone_android, color: accentColor),
                    prefixText: '+964 ',
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 16),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'كلمة المرور',
                    prefixIcon: Icon(Icons.lock_outline, color: accentColor),
                  ),
                ).animate().fadeIn(delay: 400.ms),

                if (widget.accountType == 'store') ...[
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'اسم المتجر',
                      prefixIcon: Icon(Icons.store, color: accentColor),
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'عنوان المتجر',
                      prefixIcon:
                          Icon(Icons.location_on_outlined, color: accentColor),
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                ],

                if (widget.accountType == 'driver') ...[
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'نوع المركبة (سيارة، دراجة، شاحنة)',
                      prefixIcon:
                          Icon(Icons.directions_car, color: accentColor),
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                ],

                const SizedBox(height: 32),

                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('إنشاء الحساب',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                  ),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('لديك حساب بالفعل؟',
                        style: TextStyle(color: AppTheme.textMuted)),
                    TextButton(
                      onPressed: () =>
                          context.go('/login?type=${widget.accountType}'),
                      child: Text('سجل الدخول',
                          style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) return;
    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    auth.setAccountType(widget.accountType);
    await auth.register(
      name: _nameController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
    );

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
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
