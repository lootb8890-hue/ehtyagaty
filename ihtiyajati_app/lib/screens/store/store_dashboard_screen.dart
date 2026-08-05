// ============================================================================
// لوحة تحكم المتجر (Store Dashboard Screen)
// مطابقة تماماً للصورة المرجعية
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';
import '../../services/mock_data.dart';
import '../../models/models.dart';

class StoreDashboardScreen extends StatefulWidget {
  const StoreDashboardScreen({super.key});

  @override
  State<StoreDashboardScreen> createState() => _StoreDashboardScreenState();
}

class _StoreDashboardScreenState extends State<StoreDashboardScreen> {
  final _numberFormat = NumberFormat('#,###', 'ar');
  int _selectedTab = 0;
  int _currentNavIndex = 0;
  double _totalSales = 320000;
  bool _showNotifications = false;

  final List<Map<String, String>> _notifications = [
    {
      'title': 'تم قبول الطلب #104',
      'body': 'الكابتن حيدر الكعبي قبل توصيل الشحنة وهو متوجه إليك الآن.',
      'time': 'الآن',
      'icon': '🏍️',
    },
    {
      'title': 'طلب جديد وارد #104',
      'body': 'طلب جديد بقيمة 1,180,000 د.ع بانتظار الموافقة والتجهيز.',
      'time': 'منذ 5 د',
      'icon': '📦',
    },
    {
      'title': 'كابتن يقترب',
      'body': 'الكابتن محمد جاسم على بعد 1.5 كم لاستلام الطلب #103.',
      'time': 'منذ 12 د',
      'icon': '📍',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: IndexedStack(
            index: _currentNavIndex,
            children: [
              _buildDashboardTab(),
              _buildProductsTab(),
              _buildStatsTab(),
              _buildProfileTab(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store header
          _buildStoreHeader(),
          const SizedBox(height: 16),

          // Notifications area (if expanded)
          if (_showNotifications) _buildNotificationsPanel(),
          if (_showNotifications) const SizedBox(height: 16),

          // Stats pills
          _buildStatsPills(),
          const SizedBox(height: 20),

          // Order status tabs
          _buildOrderTabs(),
          const SizedBox(height: 16),

          // Orders list
          _buildOrdersList(),
        ],
      ),
    );
  }

  // ──── Store Header (matching image) ────
  Widget _buildStoreHeader() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.accentAmber.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.store,
              color: AppTheme.accentAmber, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                MockData.currentStore.name,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800, fontSize: 15),
                maxLines: 2,
              ),
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 12, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${MockData.currentStore.address} | معتمد',
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Bell icon
        GestureDetector(
          onTap: () => setState(() => _showNotifications = !_showNotifications),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.glassWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderDark),
                ),
                child: Icon(
                  _showNotifications ? Icons.notifications_active : Icons.notifications_outlined,
                  color: _showNotifications ? AppTheme.accentAmber : AppTheme.textPrimary,
                  size: 22,
                ),
              ),
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppTheme.accentRed,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '3',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildNotificationsPanel() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.accentAmber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.accentAmber.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusMedium)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'إشعارات المتجر الأخيرة 🔔',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.accentAmber),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showNotifications = false),
                  child: const Icon(Icons.close, size: 16, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _notifications.length,
            separatorBuilder: (context, index) => const Divider(color: AppTheme.borderDark, height: 1),
            itemBuilder: (context, index) {
              final n = _notifications[index];
              return ListTile(
                leading: Text(n['icon']!, style: const TextStyle(fontSize: 20)),
                title: Text(n['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                subtitle: Text(n['body']!, style: const TextStyle(fontSize: 11)),
                trailing: Text(n['time']!, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                dense: true,
              );
            },
          ),
        ],
      ),
    ).animate().slideY(begin: -0.1, end: 0, duration: 250.ms).fadeIn();
  }

  // ──── Stats Pills (matching image: daily sales + active orders) ────
  Widget _buildStatsPills() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('إجمالي المبيعات اليوم',
                    style: TextStyle(
                        color: AppTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  '${_numberFormat.format(_totalSales)} IQD',
                  style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderDark),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الطلبات النشطة',
                    style: TextStyle(
                        color: AppTheme.textMuted, fontSize: 12)),
                SizedBox(height: 4),
                Text(
                  '23 طلب',
                  style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  // ──── Order Status Tabs (matching image) ────
  Widget _buildOrderTabs() {
    final tabs = [
      'الطلبات الجديدة (3)',
      'قيد التجهيز (2)',
      'جاهزة للاستلام (4)',
      'تم التوصيل (18)',
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(left: index < tabs.length - 1 ? 8 : 0),
          child: GestureDetector(
            onTap: () => setState(() => _selectedTab = index),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedTab == index
                    ? AppTheme.primaryBlue
                    : AppTheme.glassWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedTab == index
                      ? AppTheme.primaryBlue
                      : AppTheme.borderDark,
                ),
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: _selectedTab == index
                      ? Colors.white
                      : AppTheme.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  // ──── Orders List (matching image cards) ────
  Widget _buildOrdersList() {
    final orders = MockData.storeOrders;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: AppTheme.borderDark),
            // Right border indicator
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'طلب #${order.orderNumber}',
                    style: const TextStyle(
                        color: AppTheme.accentAmber,
                        fontWeight: FontWeight.w800),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        'منذ ${DateTime.now().difference(order.createdAt).inMinutes} دقيقة',
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Customer info
              Text(
                'الزبون: ${order.customerName}',
                style: const TextStyle(fontSize: 13),
              ),
              if (order.deliveryAddress.isNotEmpty)
                Text(
                  order.deliveryAddress,
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 12),
                ),

              const SizedBox(height: 10),

              // Items
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.glassWhite,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: order.items
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '• ${item.quantity} ${item.unit} ${item.productName}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ))
                      .toList(),
                ),
              ),

              const SizedBox(height: 12),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المجموع: ${_numberFormat.format(order.total)} ${AppConstants.currency}',
                    style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w800),
                  ),
                  Row(
                    children: [
                      if (order.status != 'new' && order.status != 'cancelled') ...[
                        TextButton.icon(
                          onPressed: () => _showDriverTrackingDialog(context, order),
                          icon: const Icon(Icons.map_outlined, size: 16, color: AppTheme.primaryBlue),
                          label: const Text('تتبع المندوب', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                      ],
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _totalSales += order.subtotal;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'تم تجهيز الطلب #${order.orderNumber} ✅'),
                                backgroundColor: AppTheme.primaryGreen,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: order.status == 'new'
                                ? AppTheme.primaryBlue
                                : AppTheme.glassWhite,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          child: Text(
                            order.status == 'new'
                                ? 'تجهيز الطلب الآن'
                                : order.status == 'processing'
                                    ? 'في انتظار الكابتن'
                                    : 'تم التسليم ✓',
                            style: TextStyle(
                              color: order.status == 'new'
                                  ? Colors.white
                                  : AppTheme.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 350 + (index * 120)));
      },
    );
  }

  void _showDriverTrackingDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'تتبع المندوب | طلب #${order.orderNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryGold),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.close, color: AppTheme.textSecondary),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          height: 380,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(32.6160, 44.0250),
                    initialZoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                    ),
                    MarkerLayer(
                      markers: [
                        // Store Marker
                        Marker(
                          point: const LatLng(32.6180, 44.0320),
                          width: 80,
                          height: 60,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(color: AppTheme.accentAmber, borderRadius: BorderRadius.circular(4)),
                                child: const Text('متجر الهناء', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                              ),
                              const Icon(Icons.store, color: AppTheme.accentAmber, size: 20),
                            ],
                          ),
                        ),
                        // Driver Marker
                        Marker(
                          point: const LatLng(32.6130, 44.0290),
                          width: 80,
                          height: 60,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(color: AppTheme.primaryGreen, borderRadius: BorderRadius.circular(4)),
                                child: Text(order.driverName ?? 'المندوب', style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                              ),
                              const Icon(Icons.directions_bike, color: AppTheme.primaryGreen, size: 20),
                            ],
                          ),
                        ),
                        // Customer Marker
                        Marker(
                          point: const LatLng(32.6250, 44.0150),
                          width: 80,
                          height: 60,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(color: AppTheme.accentRed, borderRadius: BorderRadius.circular(4)),
                                child: Text(order.customerName, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                              ),
                              const Icon(Icons.location_on, color: AppTheme.accentRed, size: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: const [
                            LatLng(32.6180, 44.0320),
                            LatLng(32.6130, 44.0290),
                            LatLng(32.6250, 44.0150),
                          ],
                          strokeWidth: 3,
                          color: AppTheme.primaryGreen,
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDarker.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderDark),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppTheme.primaryGold, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'المندوب ${order.driverName ?? "حيدر الكعبي"} في طريقه لتوصيل طلبية ${order.customerName}',
                            style: const TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductsTab() {
    return const Center(child: Text('إدارة المنتجات'));
  }

  Widget _buildStatsTab() {
    return const Center(child: Text('الإحصائيات'));
  }

  Widget _buildProfileTab() {
    return const Center(child: Text('حساب المتجر'));
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDarker,
        border: Border(top: BorderSide(color: AppTheme.borderDark)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (i) => setState(() => _currentNavIndex = i),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppTheme.accentAmber,
        unselectedItemColor: AppTheme.textMuted,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'الطلبات'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2), label: 'المنتجات'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'الإحصائيات'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}
