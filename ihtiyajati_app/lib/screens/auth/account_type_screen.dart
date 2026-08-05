// ============================================================================
// شاشة اختيار نوع الحساب
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';
import '../../providers/auth_provider.dart';

class AccountTypeScreen extends StatelessWidget {
  const AccountTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 30),

                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: AppTheme.goldShadow,
                  ),
                  child: const Icon(Icons.local_shipping_rounded,
                      size: 40, color: Colors.white),
                ).animate().fadeIn(duration: 500.ms).scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                    ),

                const SizedBox(height: 16),
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppTheme.primaryGold,
                        fontWeight: FontWeight.w900,
                      ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 8),
                Text(
                  'اختر نوع حسابك للمتابعة',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 50),

                // Account Type Cards
                _AccountTypeCard(
                  title: 'حساب الزبون',
                  subtitle: 'تسوّق واطلب أي شيء يوصلك لباب بيتك',
                  icon: Icons.person,
                  gradient: AppTheme.greenGradient,
                  shadowColor: AppTheme.primaryGreen,
                  accountType: 'customer',
                  delay: 400,
                ),

                const SizedBox(height: 16),

                _AccountTypeCard(
                  title: 'حساب المتجر',
                  subtitle: 'سجل متجرك وابدأ ببيع منتجاتك',
                  icon: Icons.store,
                  gradient: AppTheme.goldGradient,
                  shadowColor: AppTheme.primaryGold,
                  accountType: 'store',
                  delay: 550,
                ),

                const SizedBox(height: 16),

                _AccountTypeCard(
                  title: 'حساب السائق',
                  subtitle: 'انضم كسائق واربح من توصيل الطلبات',
                  icon: Icons.delivery_dining,
                  gradient: AppTheme.blueGradient,
                  shadowColor: AppTheme.primaryBlue,
                  accountType: 'driver',
                  delay: 700,
                ),

                const Spacer(),

                // Bottom text
                Text(
                  '${AppConstants.appCity} 🇮🇶',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppTheme.textMuted),
                ).animate().fadeIn(delay: 900.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final Color shadowColor;
  final String accountType;
  final int delay;

  const _AccountTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.shadowColor,
    required this.accountType,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<AuthProvider>().setAccountType(accountType);
        context.go('/login?type=$accountType');
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: AppTheme.borderDark),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: shadowColor,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 500.ms)
        .slideX(begin: 0.15, end: 0, delay: Duration(milliseconds: delay));
  }
}
