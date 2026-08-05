// ============================================================================
// لوحة تحكم الإدارة الكاملة لبرنامج احتياجاتي (Admin Dashboard Web App)
// مطابقة تماماً للمواصفات والتصميم في الصورة المرجعية للابتوب
// تشتمل على كافة التبويبات والمشاهد المتكاملة وتصحيح كامل لمشاكل الـ Overflow
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const IhtiyajatiAdminApp());
}

class IhtiyajatiAdminApp extends StatelessWidget {
  const IhtiyajatiAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'لوحة تحكم الإدارة الكاملة | احتياجاتي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4A843), // Gold
          secondary: Color(0xFF10B981), // Green
          surface: Color(0xFF16213E), // Card Dark Blue
        ),
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
      ),
      home: const AdminDashboardScreen(),
    );
  }
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedMenuIndex = 0;

  // Settings mock configuration state
  double _baseDeliveryFee = 5000;
  double _heavyDeliveryFee = 12000;
  double _commissionRate = 10;
  bool _maintenanceMode = false;

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'الرئيسية والمؤشرات', 'icon': Icons.analytics_outlined},
    {'title': 'المستخدمين (1.2M)', 'icon': Icons.people_outline},
    {'title': 'الكباتن والسائقين (15.4K)', 'icon': Icons.motorcycle},
    {'title': 'المتاجر والشركاء (4.8K)', 'icon': Icons.storefront_outlined},
    {'title': 'التتبع المباشر GPS', 'icon': Icons.map_outlined},
    {'title': 'الحسابات والإيرادات', 'icon': Icons.account_balance_wallet_outlined},
    {'title': 'إعدادات المنظومة', 'icon': Icons.settings_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 1. Sidebar Navigation
          _buildSidebar(),

          // 2. Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Header Bar
                _buildHeaderBar(),

                // Dynamic content based on selection
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _buildCurrentTabContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────── Dynamically build Tab Content ────────────────
  Widget _buildCurrentTabContent() {
    switch (_selectedMenuIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return _buildUsersTab();
      case 2:
        return _buildDriversTab();
      case 3:
        return _buildStoresTab();
      case 4:
        return _buildGPSMapTab();
      case 5:
        return _buildRevenueTab();
      case 6:
        return _buildSettingsTab();
      default:
        return _buildDashboardTab();
    }
  }

  // ──────────────── 0. Overview/Dashboard Tab ────────────────
  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      key: const ValueKey('dashboard'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCards(),
          const SizedBox(height: 24),
          _buildAnalyticsRow(),
          const SizedBox(height: 24),
          _buildRecentOrdersSection(),
        ],
      ),
    );
  }

  // ──────────────── 1. Users Tab (المستخدمين) ────────────────
  Widget _buildUsersTab() {
    return SingleChildScrollView(
      key: const ValueKey('users'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('إدارة شؤون المستخدمين (1.2M حساب)', style: GoogleFonts.cairo(fontWeight: FontWeight.w900, fontSize: 20, color: const Color(0xFFD4A843))),
              _buildAddButton('إضافة مستخدم جديد'),
            ],
          ),
          const SizedBox(height: 20),
          _buildTableCard(
            title: 'قائمة الحسابات النشطة مؤخراً',
            table: Table(
              border: TableBorder.symmetric(inside: const BorderSide(color: Color(0x1AFFFFFF))),
              children: [
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF), width: 2))),
                  children: [
                    _th('المعرف'),
                    _th('الاسم الكامل'),
                    _th('رقم الهاتف'),
                    _th('نوع الحساب'),
                    _th('تاريخ التسجيل'),
                    _th('الموقع'),
                    _th('حالة الحساب'),
                  ],
                ),
                _userRow('#u9281', 'أحمد الكربلائي', '07801234567', 'زبون', '2023/10/12', 'كربلاء، شارع السنان', 'نشط', const Color(0xFF10B981)),
                _userRow('#u9282', 'حيدر الكعبي', '07809876543', 'سائق (كابتن)', '2024/01/05', 'كربلاء، حي رمضان', 'نشط', const Color(0xFF10B981)),
                _userRow('#u9283', 'معمل الوفاء للمواد', '07705544332', 'متجر شريك', '2023/05/20', 'كربلاء، حي الأطباء', 'نشط', const Color(0xFF10B981)),
                _userRow('#u9284', 'مصطفى الموسوي', '07823322110', 'زبون', '2025/02/11', 'كربلاء، حي البلدية', 'بانتظار التأكيد', Colors.amber),
                _userRow('#u9285', 'علي الفتلاوي', '07504499882', 'سائق (كابتن)', '2024/09/18', 'كربلاء، حي العباس', 'معطل مؤقتاً', Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────── 2. Drivers Tab (الكباتن والسائقين) ────────────────
  Widget _buildDriversTab() {
    return SingleChildScrollView(
      key: const ValueKey('drivers'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('إدارة الكباتن وأسطول التوصيل (15,400 كابتن)', style: GoogleFonts.cairo(fontWeight: FontWeight.w900, fontSize: 20, color: const Color(0xFFD4A843))),
              _buildAddButton('تسجيل كابتن جديد'),
            ],
          ),
          const SizedBox(height: 20),
          _buildTableCard(
            title: 'قائمة الكباتن وتفاصيل العمل والأرباح',
            table: Table(
              border: TableBorder.symmetric(inside: const BorderSide(color: Color(0x1AFFFFFF))),
              children: [
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF), width: 2))),
                  children: [
                    _th('المعرف'),
                    _th('اسم الكابتن'),
                    _th('نوع المركبة'),
                    _th('تقييم'),
                    _th('طلبيات اليوم'),
                    _th('أرباح اليوم'),
                    _th('حالة الاتصال'),
                  ],
                ),
                _driverRow('#d101', 'حيدر الكعبي', 'شاحنة نقل (كيا)', '4.9 ★', '6 طلبات', '55,000 د.ع', 'متصل - بالخدمة', const Color(0xFF10B981)),
                _driverRow('#d102', 'محمد جاسم', 'دراجة نارية', '4.8 ★', '12 طلب', '48,000 د.ع', 'متصل - بالخدمة', const Color(0xFF10B981)),
                _driverRow('#d103', 'كرار العبودي', 'شاحنة رافعة (كرين)', '4.7 ★', '3 طلبات', '95,000 د.ع', 'مشغول بتوصيل طلبية', Colors.blue),
                _driverRow('#d104', 'مصطفى الساعدي', 'سيارة صالون', '4.9 ★', '0 طلبات', '0 د.ع', 'غير متصل', Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────── 3. Stores Tab (المتاجر والشركاء) ────────────────
  Widget _buildStoresTab() {
    return SingleChildScrollView(
      key: const ValueKey('stores'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('المتاجر ومحلات التجهيز الشريكة (4,890 متجر)', style: GoogleFonts.cairo(fontWeight: FontWeight.w900, fontSize: 20, color: const Color(0xFFD4A843))),
              _buildAddButton('إضافة متجر جديد للمنظومة'),
            ],
          ),
          const SizedBox(height: 20),
          _buildTableCard(
            title: 'قائمة المتاجر والشركاء المسجلين وتصنيفاتهم',
            table: Table(
              border: TableBorder.symmetric(inside: const BorderSide(color: Color(0x1AFFFFFF))),
              children: [
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF), width: 2))),
                  children: [
                    _th('معرف المتجر'),
                    _th('اسم المتجر'),
                    _th('القسم'),
                    _th('اسم المالك'),
                    _th('رقم الهاتف'),
                    _th('المبيعات الشهرية'),
                    _th('حالة المتجر'),
                  ],
                ),
                _storeRow('#s401', 'معمل الوفاء للمواد الإنشائية', 'مواد بناء', 'أبو علي الحسيني', '0780221199', '18.5M د.ع', 'مفتوح', const Color(0xFF10B981)),
                _storeRow('#s402', 'مشويات الكربلائي الكبير', 'مطاعم', 'حسين الغزي', '0770554411', '12.4M د.ع', 'مفتوح', const Color(0xFF10B981)),
                _storeRow('#s403', 'صيدلية الشفاء المركزية', 'صيدليات', 'د. رنا العامري', '0750442299', '4.2M د.ع', 'مغلق مؤقتاً', Colors.amber),
                _storeRow('#s404', 'أسواق الفرات المركزية', 'بقالة', 'أبو جاسم البهادلي', '0781992288', '8.9M د.ع', 'مفتوح', const Color(0xFF10B981)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────── 4. GPS Map Tab (التتبع المباشر) ────────────────
  Widget _buildGPSMapTab() {
    return Container(
      key: const ValueKey('gps_map'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('شاشة التتبع الجغرافي المباشر لأسطول كربلاء', style: GoogleFonts.cairo(fontWeight: FontWeight.w900, fontSize: 20, color: const Color(0xFFD4A843))),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                // Tracking map
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FlutterMap(
                      options: const MapOptions(
                        initialCenter: LatLng(32.6160, 44.0250),
                        initialZoom: 12.5,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                          subdomains: const ['a', 'b', 'c', 'd'],
                        ),
                        MarkerLayer(
                          markers: [
                            _buildAdminMapMarker(const LatLng(32.6160, 44.0250), 'كابتن #101'),
                            _buildAdminMapMarker(const LatLng(32.6210, 44.0310), 'كابتن #102'),
                            _buildAdminMapMarker(const LatLng(32.6100, 44.0190), 'كابتن #103'),
                            _buildAdminMapMarker(const LatLng(32.6280, 44.0400), 'كابتن #104'),
                            _buildAdminMapMarker(const LatLng(32.6050, 44.0330), 'كابتن #105'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Tracking Info Sidebar
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x1AFFFFFF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('حالة أسطول التوصيل النشط', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                        const Divider(color: Color(0x1AFFFFFF), height: 20),
                        _trackingDriverTile('كابتن حيدر الكعبي', 'طلب #104 | مواد بناء', '3.4 كم عن الهدف', const Color(0xFF10B981)),
                        _trackingDriverTile('كابتن محمد جاسم', 'طلب #103 | مطاعم', '1.2 كم عن الهدف', const Color(0xFF10B981)),
                        _trackingDriverTile('كابتن كرار العبودي', 'طلب #102 | صيدليات', '0.5 كم عن الهدف', const Color(0xFF10B981)),
                        _trackingDriverTile('كابتن مصطفى الساعدي', 'بانتظار طلب جديد', 'في الخدمة', Colors.blue),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _trackingDriverTile(String name, String job, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                Text(job, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text(status, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────── 5. Financial/Revenue Tab (الحسابات والإيرادات) ────────────────
  Widget _buildRevenueTab() {
    return SingleChildScrollView(
      key: const ValueKey('revenue'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الإحصائيات المالية والحسابات الإجمالية', style: GoogleFonts.cairo(fontWeight: FontWeight.w900, fontSize: 20, color: const Color(0xFFD4A843))),
          const SizedBox(height: 20),
          _buildTableCard(
            title: 'سجل التحويلات المالية والمعاملات اليومية',
            table: Table(
              border: TableBorder.symmetric(inside: const BorderSide(color: Color(0x1AFFFFFF))),
              children: [
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF), width: 2))),
                  children: [
                    _th('رقم المعاملة'),
                    _th('الجهة'),
                    _th('المبلغ الكلي'),
                    _th('نسبة المنظومة (10%)'),
                    _th('أجرة الكابتن'),
                    _th('صافي المتجر'),
                    _th('الحالة والنوع'),
                  ],
                ),
                _revenueRow('#tr701', 'معمل الوفاء', '1,192,000 د.ع', '118,000 د.ع', '12,000 د.ع', '1,062,000 د.ع', 'مكتمل - دفع إلكتروني', const Color(0xFF10B981)),
                _revenueRow('#tr702', 'مشويات الكربلائي', '45,000 د.ع', '4,500 د.ع', '5,000 د.ع', '35,500 د.ع', 'مكتمل - نقد عند الاستلام', const Color(0xFF10B981)),
                _revenueRow('#tr703', 'صيدلية الشفاء', '35,000 د.ع', '3,000 د.ع', '5,000 د.ع', '27,000 د.ع', 'مكتمل - دفع إلكتروني', const Color(0xFF10B981)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────── 6. Settings Tab (إعدادات المنظومة) ────────────────
  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      key: const ValueKey('settings'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('إعدادات المنظومة العامة والتحكم بالرسوم', style: GoogleFonts.cairo(fontWeight: FontWeight.w900, fontSize: 20, color: const Color(0xFFD4A843))),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x1AFFFFFF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('أجور التوصيل والعمولات'),
                const SizedBox(height: 16),
                _buildNumberSetting('أجرة التوصيل العادية للطلبات (د.ع)', _baseDeliveryFee, (val) => setState(() => _baseDeliveryFee = val)),
                const SizedBox(height: 16),
                _buildNumberSetting('أجرة التوصيل الثقيل ومواد البناء (د.ع)', _heavyDeliveryFee, (val) => setState(() => _heavyDeliveryFee = val)),
                const SizedBox(height: 16),
                _buildNumberSetting('نسبة عمولة التطبيق من المبيعات (%)', _commissionRate, (val) => setState(() => _commissionRate = val)),
                const Divider(color: Color(0x1AFFFFFF), height: 40),
                _buildSectionTitle('وضع الصيانة وإدارة التشغيل'),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text('تفعيل وضع الصيانة المؤقت للنظام', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('يقوم بإغلاق التسجيل وتجهيز الطلبيات للزبائن مؤقتاً لأعمال الصيانة والتحسين.', style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                  value: _maintenanceMode,
                  onChanged: (val) => setState(() => _maintenanceMode = val),
                  activeThumbColor: const Color(0xFFD4A843),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ تم حفظ كافة الإعدادات بنجاح!'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.black),
                    child: Text('حفظ الإعدادات والتحديث', style: GoogleFonts.cairo(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w900, color: const Color(0xFFD4A843)),
    );
  }

  Widget _buildNumberSetting(String label, double value, ValueChanged<double> onChanged) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 40,
            child: TextField(
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: value.toInt().toString()),
              onSubmitted: (val) {
                final d = double.tryParse(val);
                if (d != null) onChanged(d);
              },
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(String text) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.add, size: 18),
      label: Text(text, style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.black,
      ),
    );
  }

  Widget _buildTableCard({required String title, required Widget table}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),
          table,
        ],
      ),
    );
  }

  // ──────────────── Helper Row builders for Tables ────────────────
  TableRow _userRow(String id, String name, String phone, String type, String date, String location, String status, Color color) {
    return TableRow(
      children: [
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(id, style: const TextStyle(fontWeight: FontWeight.w700)))),
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(name))),
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(phone))),
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(type))),
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(date))),
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(location))),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
              child: Text(status, style: GoogleFonts.cairo(color: color, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
          ),
        ),
      ],
    );
  }

  TableRow _driverRow(String id, String name, String vehicle, String rating, String orders, String earnings, String status, Color color) {
    return TableRow(
      children: [
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(id, style: const TextStyle(fontWeight: FontWeight.w700)))),
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(name))),
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(vehicle))),
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(rating, style: const TextStyle(color: Color(0xFFD4A843), fontWeight: FontWeight.bold)))),
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(orders))),
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(earnings, style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)))),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
              child: Text(status, style: GoogleFonts.cairo(color: color, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
          ),
        ),
      ],
    );
  }

  TableRow _storeRow(String id, String name, String category, String owner, String phone, String sales, String status, Color color) {
    return TableRow(
      children: [
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(id, style: const TextStyle(fontWeight: FontWeight.w700)))),
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(name))),
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(category))),
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(owner))),
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(phone))),
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(sales, style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)))),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
              child: Text(status, style: GoogleFonts.cairo(color: color, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
          ),
        ),
      ],
    );
  }

  TableRow _revenueRow(String id, String name, String total, String commission, String delivery, String netStore, String status, Color color) {
    return TableRow(
      children: [
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(id, style: const TextStyle(fontWeight: FontWeight.w700)))),
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(name))),
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(total, style: const TextStyle(fontWeight: FontWeight.bold)))),
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(commission, style: const TextStyle(color: Color(0xFFD4A843), fontWeight: FontWeight.bold)))),
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(delivery))),
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(netStore, style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)))),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
              child: Text(status, style: GoogleFonts.cairo(color: color, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────── Sidebar Navigation ────────────────
  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(left: BorderSide(color: Color(0x1AFFFFFF))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4A843), Color(0xFFB8860B)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_shipping, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'احتياجاتي',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFD4A843),
                    ),
                  ),
                  Text(
                    'لوحة تحكم الإدارة الكاملة',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 40),

          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = _selectedMenuIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    selected: isSelected,
                    selectedTileColor: const Color(0xFF10B981).withValues(alpha: 0.15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: Icon(
                      item['icon'],
                      color: isSelected ? const Color(0xFF10B981) : Colors.grey,
                    ),
                    title: Text(
                      item['title'],
                      style: GoogleFonts.cairo(
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? const Color(0xFF10B981) : Colors.grey[300],
                        fontSize: 13.5,
                      ),
                    ),
                    onTap: () => setState(() => _selectedMenuIndex = index),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x1AFFFFFF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'حالة خوادم النظام',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const LinearProgressIndicator(
                  value: 0.999,
                  backgroundColor: Color(0x1AFFFFFF),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                ),
                const SizedBox(height: 6),
                Text(
                  'كفاءة التشغيل: 99.9%',
                  style: GoogleFonts.cairo(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  // ──────────────── Header Bar ────────────────
  Widget _buildHeaderBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 380,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'بحث في المتاجر، الطلبات، الكباتن، المستخدمين...',
                hintStyle: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_city, color: Color(0xFFF59E0B), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'مركز عمليات كربلاء المقدسة',
                      style: GoogleFonts.cairo(
                        color: const Color(0xFFF59E0B),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFD4A843),
                    child: Icon(Icons.admin_panel_settings, color: Colors.black),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'مدير النظام الشامل',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────── Stats Cards (match laptop display) ────────────────
  Widget _buildStatsCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.8,
      children: [
        _statCard('إجمالي المستخدمين', '1,245,800', '+14.2% هذا الشهر', Icons.people_outline, Colors.blue),
        _statCard('الكباتن والسائقين النشطين', '15,400', '+8.5% متصلين الآن', Icons.motorcycle, const Color(0xFF10B981)),
        _statCard('المتاجر والشركاء', '4,890', '+120 متجر جديد', Icons.storefront_outlined, Colors.amber),
        _statCard('إجمالي حجم الإيرادات', '3.10 مليار د.ع', '+22.4% نمو ربع سنوي', Icons.monetization_on_outlined, const Color(0xFFD4A843), highlight: true),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _statCard(String label, String value, String trend, IconData icon, Color color, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFF059669) : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1AFFFFFF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: highlight ? Colors.white.withValues(alpha: 0.2) : color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: highlight ? Colors.white : color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: highlight ? Colors.white.withValues(alpha: 0.8) : Colors.grey[400],
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  trend,
                  style: GoogleFonts.cairo(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: highlight ? Colors.white : const Color(0xFF6EE7B7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────── Charts & Map ────────────────
  Widget _buildAnalyticsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Line chart
        Expanded(
          flex: 4,
          child: Container(
            height: 380,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x1AFFFFFF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'منحنى نمو الطلبات اليومية والأسبوعية',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    Row(
                      children: [
                        _filterBtn('يومي', true),
                        const SizedBox(width: 6),
                        _filterBtn('أسبوعي', false),
                        const SizedBox(width: 6),
                        _filterBtn('شهري', false),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: const Color(0x0DFFFFFF),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}K',
                              style: GoogleFonts.cairo(fontSize: 10, color: Colors.grey),
                            ),
                            reservedSize: 32,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final days = ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
                              if (value.toInt() >= 0 && value.toInt() < days.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    days[value.toInt()],
                                    style: GoogleFonts.cairo(fontSize: 10, color: Colors.grey),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                            reservedSize: 24,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 12.4),
                            FlSpot(1, 15.2),
                            FlSpot(2, 18.9),
                            FlSpot(3, 21.0),
                            FlSpot(4, 24.5),
                            FlSpot(5, 32.1),
                            FlSpot(6, 38.4),
                          ],
                          isCurved: true,
                          color: const Color(0xFF10B981),
                          barWidth: 4,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
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
        const SizedBox(width: 16),

        // Live map using free OpenStreetMap (CartoDB Dark)
        Expanded(
          flex: 3,
          child: Container(
            height: 380,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x1AFFFFFF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'التتبع الحي للكباتن والأسطول (كربلاء المقدسة)',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FlutterMap(
                      options: const MapOptions(
                        initialCenter: LatLng(32.6160, 44.0250),
                        initialZoom: 12,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                          subdomains: const ['a', 'b', 'c', 'd'],
                        ),
                        MarkerLayer(
                          markers: [
                            _buildAdminMapMarker(const LatLng(32.6160, 44.0250), 'كابتن #101'),
                            _buildAdminMapMarker(const LatLng(32.6210, 44.0310), 'كابتن #102'),
                            _buildAdminMapMarker(const LatLng(32.6100, 44.0190), 'كابتن #103'),
                            _buildAdminMapMarker(const LatLng(32.6280, 44.0400), 'كابتن #104'),
                            _buildAdminMapMarker(const LatLng(32.6050, 44.0330), 'كابتن #105'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Marker _buildAdminMapMarker(LatLng point, String name) {
    return Marker(
      point: point,
      width: 75,
      height: 50,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              name,
              style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w900),
            ),
          ),
          const Icon(Icons.navigation, color: Color(0xFF10B981), size: 16),
        ],
      ),
    );
  }

  Widget _filterBtn(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF10B981) : Colors.transparent,
        border: Border.all(color: active ? const Color(0xFF10B981) : const BorderSide(color: Color(0x1AFFFFFF)).color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          color: active ? Colors.black : Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ──────────────── Recent Orders Table ────────────────
  Widget _buildRecentOrdersSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'أحدث العمليات والطلبات في المنظومة',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.file_download_outlined, size: 18),
                label: const Text('تصدير التقرير'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Table(
            border: TableBorder.symmetric(inside: const BorderSide(color: Color(0x1AFFFFFF))),
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF), width: 2)),
                ),
                children: [
                  _th('رقم الطلب'),
                  _th('الزبون'),
                  _th('القسم / المتجر'),
                  _th('الكابتن'),
                  _th('القيمة'),
                  _th('الموقع'),
                  _th('الحالة'),
                ],
              ),
              _tr('#104', 'أحمد الكربلائي', 'مواد بناء / معمل الوفاء', 'حيدر الكعبي', '1,180,000 د.ع', 'حي الأطباء', 'قيد التجهيز', Colors.amber),
              _tr('#103', 'علي الموسوي', 'مواد بناء / الهناء للمواد', 'محمد جاسم', '180,000 د.ع', 'حي المعلمين', 'جاري التوصيل', Colors.blue),
              _tr('#102', 'د. فاطمة الزهراء', 'صيدليات / صيدلية الشفاء', 'كرار العبودي', '35,000 د.ع', 'شارع السنان', 'تم التسليم', const Color(0xFF10B981)),
              _tr('#101', 'حسين الغزي', 'مطاعم / مشويات الكربلائي', 'مصطفى الساعدي', '42,000 د.ع', 'حي العباس', 'تم التسليم', const Color(0xFF10B981)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  TableCell _th(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          text,
          style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.grey),
        ),
      ),
    );
  }

  TableRow _tr(String id, String cust, String shop, String driver, String val, String loc, String status, Color statusColor) {
    return TableRow(
      children: [
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(id, style: const TextStyle(fontWeight: FontWeight.w700)))),
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(cust))),
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(shop))),
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(driver))),
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(val, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF10B981))))),
        TableCell(child: Padding(padding: const EdgeInsets.all(12), child: Text(loc))),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: GoogleFonts.cairo(color: statusColor, fontSize: 11, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
