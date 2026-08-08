// ============================================================================
// الشاشة الرئيسية للزبون (Customer Home Screen)
// مطابقة تماماً للصورة المرجعية
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';
import '../../services/mock_data.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentNavIndex = 0;
  final _searchController = TextEditingController();
  final _numberFormat = NumberFormat('#,###', 'ar');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: IndexedStack(
            index: _currentNavIndex,
            children: [
              _buildHomeTab(),
              _buildOrdersTab(),
              _buildWalletTab(),
              _buildProfileTab(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ──────────────── Home Tab ────────────────
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar: avatar + greeting + cart
          _buildTopBar(),
          const SizedBox(height: 16),

          // Location banner
          _buildLocationBanner(),
          const SizedBox(height: 16),

          // Search bar
          _buildSearchBar(),
          const SizedBox(height: 24),

          // Categories section title
          Row(
            children: [
              Text(
                'الأقسام الرئيسية',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(width: 6),
              const Text('📦', style: TextStyle(fontSize: 18)),
            ],
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 12),

          // Categories Grid (matching image layout)
          _buildCategoriesGrid(),
          const SizedBox(height: 28),

          // Promo banner
          _buildPromoBanner(),
          const SizedBox(height: 28),

          // Popular products
          Row(
            children: [
              Text(
                'العروض الأكثر طلباً',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(width: 6),
              const Text('🔥', style: TextStyle(fontSize: 18)),
            ],
          ).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 12),

          _buildPopularProducts(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ──── Top Bar ────
  Widget _buildTopBar() {
    return Row(
      children: [
        // Avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryGold, width: 2),
            gradient: AppTheme.goldGradient,
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحباً بك 👋',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.textSecondary),
              ),
              Consumer<AuthProvider>(
                builder: (context, auth, _) => Text(
                  auth.currentUser?.name ?? 'أحمد الكربلائي',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),

        // Cart button with badge
        Consumer<CartProvider>(
          builder: (context, cart, _) => Stack(
            clipBehavior: Clip.none,
            children: [
              _iconButton(Icons.shopping_cart, () => context.go('/customer/cart')),
              if (cart.itemCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppTheme.accentRed,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _iconButton(Icons.notifications_outlined, () {}),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppTheme.glassWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: Icon(icon, color: AppTheme.textPrimary, size: 20),
      ),
    );
  }

  // ──── Location Banner ────
  Widget _buildLocationBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: AppTheme.primaryGreen, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'موقع التوصيل الحالي:',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  'كربلاء، شارع السنان، قرب الروضة',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppTheme.primaryGreen),
                ),
              ],
            ),
          ),
          const Icon(Icons.expand_more, color: AppTheme.textMuted),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05, end: 0);
  }

  // ──── Search Bar ────
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.glassWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'ابحث عن طعام، مواد بناء، صيدلية، تأجير...',
          prefixIcon: Icon(Icons.search, color: AppTheme.textMuted),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  // ──── Categories Grid (matching image exactly: 2 columns) ────
  Widget _buildCategoriesGrid() {
    final categories = MockData.categories;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.55,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final color = Color(cat.colorValue);
        final isConstruction = cat.id == 'construction';

        return GestureDetector(
          onTap: () => context.go('/customer/category/${cat.id}'),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(
                color: isConstruction
                    ? AppTheme.accentAmber.withValues(alpha: 0.5)
                    : AppTheme.borderDark,
                width: isConstruction ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Stack(
              children: [
                if (isConstruction)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accentAmber,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'مميز',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        MockData.getCategoryIcon(cat.icon),
                        color: color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    if (cat.description != null)
                      Text(
                        cat.description!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(
                delay: Duration(milliseconds: 350 + (index * 80)),
                duration: 400.ms)
            .slideY(
                begin: 0.08,
                end: 0,
                delay: Duration(milliseconds: 350 + (index * 80)));
      },
    );
  }

  // ──── Promo Banner ────
  Widget _buildPromoBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.blueGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'خصم 20% على طلبات السمنت والحديد',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'اطلب مواد البناء الآن واحصل على توصيل مجاني للطلبات الكبيرة',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.construction, color: Colors.white, size: 28),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.05, end: 0);
  }

  // ──── Popular Products ────
  Widget _buildPopularProducts() {
    final products = MockData.constructionProducts.take(4).toList();
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Container(
            width: 160,
            margin: EdgeInsets.only(left: index < products.length - 1 ? 12 : 0),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppTheme.borderDark),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (product.badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.badge!,
                      style: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                const SizedBox(height: 8),
                Icon(
                  product.id == 'p1'
                      ? Icons.inventory_2
                      : product.id == 'p2'
                          ? Icons.view_column
                          : product.id == 'p3'
                              ? Icons.grid_view
                              : Icons.landscape,
                  size: 36,
                  color: AppTheme.accentAmber,
                ),
                const SizedBox(height: 8),
                Text(
                  product.name,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Text(
                  '${_numberFormat.format(product.price)} ${AppConstants.currency}',
                  style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<CartProvider>().addItem(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تمت إضافة "${product.name}" للسلة'),
                          backgroundColor: AppTheme.primaryGreen,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text('إضافة',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 550 + (index * 100)))
              .slideX(begin: 0.1, end: 0);
        },
      ),
    );
  }

  // ──── Orders Tab ────
  Widget _buildOrdersTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'قائمة الطلبيات',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        Expanded(
          child: Consumer<OrdersProvider>(
            builder: (context, ordersProv, _) {
              final customerOrders = ordersProv.orders;
              if (customerOrders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.textMuted.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      const Text('لا توجد طلبيات حالياً', style: TextStyle(color: AppTheme.textMuted)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: customerOrders.length,
                itemBuilder: (context, index) {
                  final order = customerOrders[index];
                  final statusText = order.status == 'new' || order.status == 'الطلبات الجديدة'
                      ? 'قيد التجهيز'
                      : order.status == 'delivered' || order.status == 'تم التوصيل'
                          ? 'تم التوصيل'
                          : 'جاري التوصيل';
                  final statusColor = order.status == 'delivered' || order.status == 'تم التوصيل'
                      ? AppTheme.primaryGreen
                      : AppTheme.accentAmber;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(color: AppTheme.borderDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'طلب رقم #${order.orderNumber}',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: AppTheme.borderDark, height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.storeName,
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                            ),
                            Text(
                              '${_numberFormat.format(order.total)} ${AppConstants.currency}',
                              style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'التاريخ: ${order.createdAt != null ? DateFormat('yyyy/MM/dd').format(order.createdAt!) : 'اليوم'}',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                            ),
                            if (order.driverName != null)
                              Text(
                                'السائق: ${order.driverName}',
                                style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ──── Wallet Tab ────
  Widget _buildWalletTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المحفظة الرقمية',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          // Wallet Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: AppTheme.goldGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGold.withValues(alpha: 0.35),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الرصيد المتاح حالياً', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 14)),
                    Icon(Icons.account_balance_wallet, color: Colors.black87),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  '75,000 د.ع',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 32),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('المحفظة نشطة', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Quick actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => alert('تم تفعيل خدمة شحن الرصيد'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('شحن رصيد'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => alert('تم تفعيل خدمة تحويل الرصيد'),
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('تحويل رصيد'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textPrimary,
                    side: const BorderSide(color: AppTheme.borderDark),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Recent transactions
          const Text('العمليات الأخيرة', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 12),
          _transactionItem('شحن رصيد محفظة (زين كاش)', '+25,000 د.ع', 'أمس، 08:30 م', true),
          _transactionItem('دفع قيمة طلب رقم #104', '-38,000 د.ع', '07/08/2026', false),
          _transactionItem('شحن رصيد محفظة (تعبئة كود)', '+50,000 د.ع', '05/08/2026', true),
        ],
      ),
    );
  }

  void alert(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.primaryGreen),
    );
  }

  Widget _transactionItem(String title, String amount, String date, bool isAdd) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
              const SizedBox(height: 4),
              Text(date, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            ],
          ),
          Text(
            amount,
            style: TextStyle(
              color: isAdd ? AppTheme.primaryGreen : AppTheme.accentRed,
              fontWeight: FontWeight.w900,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    );
  }

  // ──── Profile Tab ────
  Widget _buildProfileTab() {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final roleName = user?.accountType == 'driver'
        ? 'سائق توصيل'
        : user?.accountType == 'store'
            ? 'صاحب متجر'
            : 'زبون احتياجاتي';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          // User Avatar Big
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryGold, width: 3),
              gradient: AppTheme.goldGradient,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 14),
          Text(
            user?.name ?? 'بدون اسم',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            roleName,
            style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 24),
          // Details Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppTheme.borderDark),
            ),
            child: Column(
              children: [
                _profileDetailRow('رقم الهاتف:', user?.phone ?? 'لا يوجد'),
                const Divider(color: AppTheme.borderDark, height: 24),
                _profileDetailRow('نوع الحساب:', roleName),
                const Divider(color: AppTheme.borderDark, height: 24),
                _profileDetailRow('المدينة:', 'كربلاء المقدسة'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () async {
                await auth.logout();
                if (mounted) {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('تسجيل الخروج من الحساب', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileDetailRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  // ──── Bottom Navigation ────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDarker,
        border: Border(top: BorderSide(color: AppTheme.borderDark)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppTheme.primaryGold,
        unselectedItemColor: AppTheme.textMuted,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'الرئيسية'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'الطلبات'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: 'المحفظة'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}
