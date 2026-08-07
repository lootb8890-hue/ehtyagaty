// ============================================================================
// الشاشة الرئيسية للسائق (Driver Home Screen)
// مطابقة تماماً للصورة المرجعية
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../config/app_theme.dart';
import '../../services/mock_data.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final _numberFormat = NumberFormat('#,###', 'ar');
  bool _isOnline = true;
  double _earnings = 55000;
  int _completedOrders = 6;
  bool _orderAccepted = false;
  bool _orderRejected = false;
  int _currentNavIndex = 0;

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
              _buildEarningsTab(),
              _buildHistoryTab(),
              _buildProfileTab(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Driver header with toggle
          _buildDriverHeader(),

          // Map placeholder
          _buildMapPlaceholder(),

          // Earnings strip
          _buildEarningsStrip(),

          // Active order card
          if (!_orderRejected) _buildActiveOrderCard(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ──── Driver Header ────
  Widget _buildDriverHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppTheme.goldGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<AuthProvider>(
                  builder: (context, auth, _) => Text(
                    auth.currentUser?.name != null
                        ? 'الكابتن ${auth.currentUser!.name}'
                        : 'الكابتن ${MockData.currentDriver.name}',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.local_shipping,
                        size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      MockData.currentDriver.vehicleName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Online toggle
          Column(
            children: [
              Text('الحالة:',
                  style:
                      TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              const SizedBox(height: 2),
              Switch(
                value: _isOnline,
                onChanged: (val) => setState(() => _isOnline = val),
                activeThumbColor: AppTheme.primaryGreen,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  // ──── Map Layer using free OpenStreetMap (CartoDB Dark) ────
  Widget _buildMapPlaceholder() {
    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(32.6160, 44.0250),
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    // Driver Marker
                    Marker(
                      point: LatLng(32.6120, 44.0280),
                      width: 90,
                      height: 70,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('الكابتن حيدر', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                          ),
                          const Icon(Icons.local_shipping, color: AppTheme.primaryGreen, size: 24),
                        ],
                      ),
                    ),
                    // Store Marker
                    Marker(
                      point: LatLng(32.6180, 44.0320),
                      width: 90,
                      height: 70,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentAmber,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('معمل الوفاء', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                          ),
                          const Icon(Icons.store, color: AppTheme.accentAmber, size: 24),
                        ],
                      ),
                    ),
                    // Customer Marker
                    Marker(
                      point: LatLng(32.6250, 44.0150),
                      width: 90,
                      height: 70,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentRed,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('الزبون أحمد', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                          ),
                          const Icon(Icons.location_on, color: AppTheme.accentRed, size: 24),
                        ],
                      ),
                    ),
                  ],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [
                        LatLng(32.6120, 44.0280), // Driver
                        LatLng(32.6180, 44.0320), // Store
                        LatLng(32.6250, 44.0150), // Customer
                      ],
                      strokeWidth: 3,
                      color: AppTheme.primaryGreen,
                    ),
                  ],
                ),
              ],
            ),
            
            // Online status overlay
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isOnline
                      ? AppTheme.primaryGreen.withValues(alpha: 0.9)
                      : AppTheme.accentRed.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, size: 8, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      _isOnline ? 'متصل الآن' : 'غير متصل',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  // ──── Earnings Strip (matching image: 3 boxes) ────
  Widget _buildEarningsStrip() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _earningsBox('أرباح اليوم',
              '${_numberFormat.format(_earnings)} IQD', AppTheme.primaryGreen),
          const SizedBox(width: 8),
          _earningsBox('الطلبات المكتملة', '$_completedOrders طلبات',
              AppTheme.primaryBlue),
          const SizedBox(width: 8),
          _earningsBox(
              'التقييم', '${MockData.currentDriver.rating} ★', AppTheme.accentAmber),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _earningsBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  // ──── Active Order Card #104 (matching image) ────
  Widget _buildActiveOrderCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
            color: _orderAccepted
                ? AppTheme.primaryGreen
                : AppTheme.primaryGreen.withValues(alpha: 0.5),
            width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _orderAccepted
                      ? 'تم قبول الطلب #104 ✅'
                      : 'طلب جديد قيد الانتظار #104',
                  style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w800,
                      fontSize: 13),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 14, color: AppTheme.accentAmber),
                  const SizedBox(width: 4),
                  const Text('0:45',
                      style: TextStyle(
                          color: AppTheme.accentAmber,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Route details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _routePoint(Icons.circle, AppTheme.primaryBlue,
                    'المتجر (المصدر):', 'معمل الوفاء للمواد - كربلاء، حي رمضان'),
                Container(
                  margin: const EdgeInsets.only(right: 7),
                  height: 20,
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: AppTheme.textMuted,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                ),
                _routePoint(Icons.location_on, AppTheme.accentRed,
                    'موقع الزبون (الهدف):', 'مشروع بناء - كربلاء، حي الأطباء (3.4 كم)'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Cargo info
          Row(
            children: [
              const Icon(Icons.inventory,
                  size: 16, color: AppTheme.textMuted),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'الحمولة: 20 كيس سمنت + 2 طن حديد',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                'أجرة: 12,000 د.ع',
                style: const TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w900,
                    fontSize: 14),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action buttons
          if (!_orderAccepted)
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _orderAccepted = true;
                          _earnings += 12000;
                          _completedOrders++;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                '✅ تم قبول الطلب #104! جاري التوجه للمتجر'),
                            backgroundColor: AppTheme.primaryGreen,
                          ),
                        );
                      },
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text('قبول الطلب فوراً',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _orderRejected = true),
                      icon: const Icon(Icons.close, color: AppTheme.accentRed),
                      label: const Text('رفض',
                          style: TextStyle(
                              color: AppTheme.accentRed,
                              fontWeight: FontWeight.w800)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.accentRed),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_shipping, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'جاري التوجه نحو المتجر لاستلام الحمولة...',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13),
                  ),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _routePoint(
      IconData icon, Color color, String label, String detail) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 12)),
              Text(detail,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsTab() {
    return const Center(child: Text('شاشة الأرباح التفصيلية'));
  }

  Widget _buildHistoryTab() {
    return const Center(child: Text('سجل الطلبات'));
  }

  Widget _buildProfileTab() {
    return const Center(child: Text('الحساب الشخصي'));
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
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: AppTheme.textMuted,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'الرئيسية'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: 'الأرباح'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: 'السجل'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}
