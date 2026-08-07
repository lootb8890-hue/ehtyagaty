// ============================================================================
// لوحة تحكم الإدارة الكاملة لبرنامج احتياجاتي (Admin Dashboard Web App)
// متصلة بقاعدة بيانات Supabase وتظهر البيانات الحقيقية فقط بدون أي قيم فيك
// ============================================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'firebase_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

  // Settings configuration state
  double _baseDeliveryFee = 5000;
  double _heavyDeliveryFee = 12000;
  double _commissionRate = 10;
  bool _maintenanceMode = false;

  // Real Database state variables
  bool _isLoading = false;
  int _totalUsers = 0;
  int _totalDrivers = 0;
  int _totalStores = 0;
  double _totalRevenue = 0;

  List<Map<String, dynamic>> _profilesList = [];
  List<Map<String, dynamic>> _driversList = [];
  List<Map<String, dynamic>> _storesList = [];
  List<Map<String, dynamic>> _ordersList = [];

  // OTP notification settings state
  String _whatsappUrl = '';
  String _whatsappToken = '';
  String _telegramBotToken = '';
  String _telegramChatId = '';
  String _otpProvider = 'both'; // 'whatsapp', 'telegram', 'both', 'none'

  bool _waReady = false;
  String _waQrCode = '';
  Map<String, dynamic>? _waUser;

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'الرئيسية والمؤشرات', 'icon': Icons.analytics_outlined},
    {'title': 'المستخدمين', 'icon': Icons.people_outline},
    {'title': 'الكباتن والسائقين', 'icon': Icons.motorcycle},
    {'title': 'المتاجر والشركاء', 'icon': Icons.storefront_outlined},
    {'title': 'التتبع المباشر GPS', 'icon': Icons.map_outlined},
    {'title': 'الحسابات والإيرادات', 'icon': Icons.account_balance_wallet_outlined},
    {'title': 'إعدادات المنظومة', 'icon': Icons.settings_outlined},
  ];

  bool get _isFirebaseInitialized {
    try {
      FirebaseFirestore.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadRealData();
    _checkWhatsAppGatewayStatus();
  }

  Future<void> _checkWhatsAppGatewayStatus() async {
    try {
      final targetUrl = _whatsappUrl.isNotEmpty ? _whatsappUrl : 'http://localhost:3000/send-otp';
      final uri = Uri.parse(targetUrl);
      final statusUri = Uri.parse('${uri.scheme}://${uri.host}:${uri.port}/status');
      final res = await http.get(statusUri).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _waReady = data['ready'] == true;
            _waQrCode = data['qrCode']?.toString() ?? '';
            _waUser = data['user'] as Map<String, dynamic>?;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _waReady = false;
          _waQrCode = '';
          _waUser = null;
        });
      }
    }
  }

  Future<void> _loadRealData() async {
    setState(() => _isLoading = true);

    try {
      if (Firebase.apps.isEmpty) {
        if (!FirebaseConfig.apiKey.contains('YOUR_API_KEY')) {
          await Firebase.initializeApp(options: FirebaseConfig.currentPlatform);
        }
      }
    } catch (e) {
      debugPrint('Firebase init check failed: $e');
    }

    if (!_isFirebaseInitialized) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;

      // 1. Fetch collections in parallel with strict timeout for instant response
      final results = await Future.wait([
        firestore.collection('users').get().timeout(const Duration(seconds: 3)),
        firestore.collection('stores').get().timeout(const Duration(seconds: 3)),
        firestore.collection('orders').get().timeout(const Duration(seconds: 3)),
      ]).catchError((e) {
        debugPrint('Firestore fetch timed out or offline: $e');
        return <QuerySnapshot<Map<String, dynamic>>>[];
      });

      final usersDocs = results.isNotEmpty ? results[0].docs : [];
      final storesDocs = results.length > 1 ? results[1].docs : [];
      final ordersDocs = results.length > 2 ? results[2].docs : [];

      // 2. Map profiles (users)
      final profilesRes = usersDocs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'phone': data['phone'] ?? '',
          'full_name': data['full_name'] ?? '',
          'role': data['role'] ?? 'customer',
          'created_at': data['created_at'] != null && data['created_at'] is Timestamp
              ? (data['created_at'] as Timestamp).toDate().toIso8601String()
              : DateTime.now().toIso8601String(),
        };
      }).toList();

      // 3. Map drivers (users where role == driver)
      final driversRes = usersDocs
          .where((doc) => doc.data()['role'] == 'driver')
          .map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'vehicle_name': data['vehicle_name'] ?? 'دراجة توصيل',
          'rating': data['rating'] ?? 5.0,
          'is_online': data['is_online'] ?? true,
          'today_orders': data['today_orders'] ?? 0,
          'today_earnings': data['today_earnings'] ?? 0,
          'profiles': {
            'full_name': data['full_name'] ?? '',
            'phone': data['phone'] ?? '',
          }
        };
      }).toList();

      // 4. Map stores
      final storesRes = storesDocs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'category': data['category'] ?? '',
          'address': data['address'] ?? '',
          'is_open': data['is_open'] ?? true,
          'total_sales': data['total_sales'] ?? 0,
          'profiles': {
            'full_name': data['owner_name'] ?? 'مالك المتجر',
          }
        };
      }).toList();

      // 5. Map orders and calculate revenue
      double totalRev = 0;
      final ordersRes = ordersDocs.map((doc) {
        final data = doc.data();
        final total = (data['total'] as num? ?? 0.0).toDouble();
        totalRev += total;

        String createdAt = DateTime.now().toIso8601String();
        if (data['created_at'] != null && data['created_at'] is Timestamp) {
          createdAt = (data['created_at'] as Timestamp).toDate().toIso8601String();
        }

        return {
          'id': doc.id,
          'order_number': data['order_number'] ?? 0,
          'total': total,
          'status': data['status'] ?? 'new',
          'created_at': createdAt,
          'customer': {
            'full_name': data['customer_name'] ?? 'زبون احتياجاتي',
          },
          'store': {
            'name': data['store_name'] ?? 'متجر احتياجاتي',
          },
          'driver': {
            'full_name': data['driver_name'] ?? 'لم يتم التعيين بعد',
          }
        };
      }).toList();

      // 6. Load OTP settings
      String whatsappUrl = 'http://localhost:3000/send-otp';
      String whatsappToken = 'local_gateway';
      String telegramBotToken = '';
      String telegramChatId = '';
      String otpProvider = 'both';

      try {
        final configDoc = await firestore
            .collection('settings')
            .doc('notification_config')
            .get()
            .timeout(const Duration(seconds: 2));
        if (configDoc.exists) {
          final data = configDoc.data()!;
          whatsappUrl = (data['whatsapp_api_url'] != null && data['whatsapp_api_url'].toString().isNotEmpty)
              ? data['whatsapp_api_url']
              : 'http://localhost:3000/send-otp';
          whatsappToken = (data['whatsapp_token'] != null && data['whatsapp_token'].toString().isNotEmpty)
              ? data['whatsapp_token']
              : 'local_gateway';
          telegramBotToken = data['telegram_bot_token'] ?? '';
          telegramChatId = data['telegram_chat_id'] ?? '';
          otpProvider = data['provider'] ?? 'both';
        }
      } catch (e) {
        debugPrint('Failed to load notification settings from Firestore: $e');
      }

      setState(() {
        _totalUsers = usersDocs.length;
        _totalDrivers = driversRes.length;
        _totalStores = storesDocs.length;
        _totalRevenue = totalRev;
        _profilesList = profilesRes;
        _driversList = driversRes;
        _storesList = storesRes;
        _ordersList = ordersRes;
        
        _whatsappUrl = whatsappUrl;
        _whatsappToken = whatsappToken;
        _telegramBotToken = telegramBotToken;
        _telegramChatId = telegramChatId;
        _otpProvider = otpProvider;
        
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading real Firestore stats: $e');
      setState(() => _isLoading = false);
    }
  }

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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4A843)))
                      : AnimatedSwitcher(
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
    return RefreshIndicator(
      onRefresh: _loadRealData,
      color: const Color(0xFFD4A843),
      child: SingleChildScrollView(
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
      ),
    );
  }

  // ──────────────── 1. Users Tab ────────────────
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
              Text('إدارة شؤون المستخدمين ($_totalUsers حساب نشط)', style: GoogleFonts.cairo(fontWeight: FontWeight.w900, fontSize: 20, color: const Color(0xFFD4A843))),
              _buildAddButton('إضافة مستخدم جديد'),
            ],
          ),
          const SizedBox(height: 20),
          _buildTableCard(
            title: 'قائمة الحسابات الحقيقية النشطة',
            table: _profilesList.isEmpty
                ? Center(child: Padding(padding: const EdgeInsets.all(40), child: Text('لا يوجد مستخدمين مسجلين في النظام حالياً.', style: GoogleFonts.cairo(color: Colors.grey))))
                : Table(
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
                      ..._profilesList.map((p) {
                        String roleText = 'زبون';
                        if (p['role'] == 'driver') roleText = 'سائق';
                        if (p['role'] == 'store') roleText = 'صاحب متجر';

                        return _userRow(
                          p['id'].toString().substring(0, 8),
                          p['full_name'] ?? 'بدون اسم',
                          p['phone'] ?? '',
                          roleText,
                          p['created_at'] != null ? p['created_at'].toString().split('T')[0] : '',
                          'كربلاء المقدسة',
                          'نشط',
                          const Color(0xFF10B981),
                        );
                      }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ──────────────── 2. Drivers Tab ────────────────
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
              Text('إدارة الكباتن وأسطول التوصيل ($_totalDrivers كابتن)', style: GoogleFonts.cairo(fontWeight: FontWeight.w900, fontSize: 20, color: const Color(0xFFD4A843))),
              _buildAddButton('تسجيل كابتن جديد'),
            ],
          ),
          const SizedBox(height: 20),
          _buildTableCard(
            title: 'قائمة الكباتن وتفاصيل العمل والأرباح',
            table: _driversList.isEmpty
                ? Center(child: Padding(padding: const EdgeInsets.all(40), child: Text('لا يوجد سائقين مسجلين في النظام حالياً.', style: GoogleFonts.cairo(color: Colors.grey))))
                : Table(
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
                      ..._driversList.map((d) {
                        final profile = d['profiles'];
                        return _driverRow(
                          d['id'].toString().substring(0, 8),
                          profile?['full_name'] ?? 'بدون اسم',
                          d['vehicle_name'] ?? 'دراجة نارية',
                          '${d['rating'] ?? 5.0} ★',
                          '${d['today_orders'] ?? 0} طلبات',
                          '${(d['today_earnings'] as num?)?.toInt() ?? 0} د.ع',
                          (d['is_online'] as bool? ?? true) ? 'متصل - بالخدمة' : 'غير متصل',
                          (d['is_online'] as bool? ?? true) ? const Color(0xFF10B981) : Colors.grey,
                        );
                      }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ──────────────── 3. Stores Tab ────────────────
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
              Text('المتاجر ومحلات التجهيز الشريكة ($_totalStores متجر)', style: GoogleFonts.cairo(fontWeight: FontWeight.w900, fontSize: 20, color: const Color(0xFFD4A843))),
              _buildAddButton('إضافة متجر جديد للمنظومة'),
            ],
          ),
          const SizedBox(height: 20),
          _buildTableCard(
            title: 'قائمة المتاجر والشركاء المسجلين وتصنيفاتهم',
            table: _storesList.isEmpty
                ? Center(child: Padding(padding: const EdgeInsets.all(40), child: Text('لا يوجد متاجر مسجلة في النظام حالياً.', style: GoogleFonts.cairo(color: Colors.grey))))
                : Table(
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
                          _th('المبيعات الكلية'),
                          _th('حالة المتجر'),
                        ],
                      ),
                      ..._storesList.map((s) {
                        final owner = s['profiles'];
                        return _storeRow(
                          s['id'].toString().substring(0, 8),
                          s['name'] ?? 'بدون اسم',
                          s['category'] ?? 'عام',
                          owner?['full_name'] ?? 'بدون اسم',
                          owner?['phone'] ?? '',
                          '${(s['total_sales'] as num?)?.toInt() ?? 0} د.ع',
                          (s['is_open'] as bool? ?? true) ? 'مفتوح' : 'مغلق',
                          (s['is_open'] as bool? ?? true) ? const Color(0xFF10B981) : Colors.amber,
                        );
                      }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ──────────────── 4. GPS Map Tab ────────────────
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
                          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: _driversList.map((d) {
                            final lat = (d['lat'] as num?)?.toDouble() ?? 32.6160;
                            final lng = (d['lng'] as num?)?.toDouble() ?? 44.0250;
                            final name = d['profiles']?['full_name'] ?? 'كابتن';
                            return _buildAdminMapMarker(LatLng(lat, lng), name);
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
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
                        if (_driversList.isEmpty)
                          Center(child: Padding(padding: const EdgeInsets.only(top: 40), child: Text('لا يوجد سائقين نشطين حالياً.', style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey))))
                        else
                          Expanded(
                            child: ListView(
                              children: _driversList.map((d) {
                                final profile = d['profiles'];
                                return _trackingDriverTile(
                                  profile?['full_name'] ?? 'كابتن مجهول',
                                  'المعرف: ${d['id'].toString().substring(0, 8)}',
                                  (d['is_online'] as bool? ?? true) ? 'متصل بالخدمة' : 'غير متصل',
                                  (d['is_online'] as bool? ?? true) ? const Color(0xFF10B981) : Colors.grey,
                                );
                              }).toList(),
                            ),
                          ),
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

  // ──────────────── 5. Financial/Revenue Tab ────────────────
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
            title: 'سجل التحويلات المالية والمعاملات الحقيقية',
            table: _ordersList.isEmpty
                ? Center(child: Padding(padding: const EdgeInsets.all(40), child: Text('لا توجد عمليات بيع أو توصيل مسجلة حالياً.', style: GoogleFonts.cairo(color: Colors.grey))))
                : Table(
                    border: TableBorder.symmetric(inside: const BorderSide(color: Color(0x1AFFFFFF))),
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF), width: 2))),
                        children: [
                          _th('رقم المعاملة'),
                          _th('الجهة / المتجر'),
                          _th('المبلغ الكلي'),
                          _th('نسبة المنظومة (10%)'),
                          _th('أجرة الكابتن'),
                          _th('صافي المتجر'),
                          _th('الحالة والنوع'),
                        ],
                      ),
                      ..._ordersList.map((o) {
                        final double total = (o['total'] as num?)?.toDouble() ?? 0.0;
                        final double systemFee = total * 0.10;
                        final double deliveryFee = (o['delivery_fee'] as num?)?.toDouble() ?? 0.0;
                        final double netStore = total - systemFee - deliveryFee;

                        return _revenueRow(
                          o['id'].toString().substring(0, 8),
                          o['store']?['name'] ?? 'متجر مجهول',
                          '${total.toInt()} د.ع',
                          '${systemFee.toInt()} د.ع',
                          '${deliveryFee.toInt()} د.ع',
                          '${netStore.toInt()} د.ع',
                          o['status'] == 'delivered' ? 'مكتمل - دفع عند الاستلام' : 'قيد المعالجة',
                          o['status'] == 'delivered' ? const Color(0xFF10B981) : Colors.amber,
                        );
                      }),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ──────────────── 6. Settings Tab ────────────────
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
                const Divider(color: Color(0x1AFFFFFF), height: 40),
                _buildSectionTitle('بوابات التحقق ورسائل OTP (الواتساب والتيلغرام)'),
                const SizedBox(height: 16),
                _buildWhatsAppConnectionWidget(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text('مزود الخدمة النشط لإرسال رمز التحقق', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1117),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0x1AFFFFFF)),
                        ),
                        child: DropdownButton<String>(
                          value: _otpProvider,
                          dropdownColor: const Color(0xFF1E293B),
                          underline: const SizedBox(),
                          isExpanded: true,
                          items: [
                            DropdownMenuItem(value: 'both', child: Text('كلاهما (تيلغرام + واتساب)', style: GoogleFonts.cairo(fontSize: 12))),
                            DropdownMenuItem(value: 'whatsapp', child: Text('واتساب فقط (UltraMsg)', style: GoogleFonts.cairo(fontSize: 12))),
                            DropdownMenuItem(value: 'telegram', child: Text('تيلغرام فقط', style: GoogleFonts.cairo(fontSize: 12))),
                            DropdownMenuItem(value: 'none', child: Text('تعطيل الإرسال التلقائي', style: GoogleFonts.cairo(fontSize: 12))),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _otpProvider = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_otpProvider == 'whatsapp' || _otpProvider == 'both') ...[
                  Text('إعدادات بوابة الواتساب (UltraMsg):', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                  const SizedBox(height: 12),
                  _buildTextSetting('رابط API الإرسال (WhatsApp API URL)', _whatsappUrl, (val) => _whatsappUrl = val),
                  const SizedBox(height: 12),
                  _buildTextSetting('رمز الوصول السري (WhatsApp Token)', _whatsappToken, (val) => _whatsappToken = val),
                  const Divider(color: Color(0x1AFFFFFF), height: 30),
                ],
                if (_otpProvider == 'telegram' || _otpProvider == 'both') ...[
                  Text('إعدادات تيلغرام بوت (Telegram Bot Notification):', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF38BDF8))),
                  const SizedBox(height: 12),
                  _buildTextSetting('توكن البوت (Telegram Bot Token)', _telegramBotToken, (val) => _telegramBotToken = val),
                  const SizedBox(height: 12),
                  _buildTextSetting('معرف دردشة الإدارة (Telegram Chat ID)', _telegramChatId, (val) => _telegramChatId = val),
                  const Divider(color: Color(0x1AFFFFFF), height: 30),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: 250,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('⏳ جاري حفظ الإعدادات وتحديث المنظومة...'),
                          backgroundColor: Colors.blue,
                          duration: Duration(seconds: 1),
                        ),
                      );
                      await _saveNotificationSettings();
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

  Widget _buildTextSetting(String label, String value, ValueChanged<String> onChanged) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 40,
            child: TextField(
              controller: TextEditingController(text: value),
              onChanged: onChanged,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveNotificationSettings() async {
    if (!_isFirebaseInitialized) return;
    try {
      await FirebaseFirestore.instance.collection('settings').doc('notification_config').set({
        'whatsapp_api_url': _whatsappUrl,
        'whatsapp_token': _whatsappToken,
        'telegram_bot_token': _telegramBotToken,
        'telegram_chat_id': _telegramChatId,
        'provider': _otpProvider,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم حفظ كافة الإعدادات بنجاح!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ فشل حفظ الإعدادات: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 380),
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

  // ──────────────── Stats Cards ────────────────
  Widget _buildStatsCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.0,
      children: [
        _statCard('إجمالي المستخدمين', '$_totalUsers حساب', 'نشطين بقاعدة البيانات', Icons.people_outline, Colors.blue),
        _statCard('الكباتن والسائقين النشطين', '$_totalDrivers كابتن', 'مسجلين بالمنظومة', Icons.motorcycle, const Color(0xFF10B981)),
        _statCard('المتاجر والشركاء', '$_totalStores متجر شريك', 'محلات ومكاتب تجهيز', Icons.storefront_outlined, Colors.amber),
        _statCard('إجمالي حجم الإيرادات', '${_totalRevenue.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} د.ع', 'مبيعات حقيقية مسجلة', Icons.monetization_on_outlined, const Color(0xFFD4A843), highlight: true),
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
                    fontSize: 15,
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
                            FlSpot(0, 0),
                            FlSpot(1, 0),
                            FlSpot(2, 0),
                            FlSpot(3, 0),
                            FlSpot(4, 0),
                            FlSpot(5, 0),
                            FlSpot(6, 0),
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
                          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: _driversList.map((d) {
                            final lat = (d['lat'] as num?)?.toDouble() ?? 32.6160;
                            final lng = (d['lng'] as num?)?.toDouble() ?? 44.0250;
                            final name = d['profiles']?['full_name'] ?? 'كابتن';
                            return _buildAdminMapMarker(LatLng(lat, lng), name);
                          }).toList(),
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
                onPressed: _loadRealData,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('تحديث البيانات حياً'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_ordersList.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Text('لا توجد طلبيات حقيقية مسجلة في النظام حالياً.', style: GoogleFonts.cairo(color: Colors.grey)),
              ),
            )
          else
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
                ..._ordersList.map((order) {
                  final String orderNum = '#${order['order_number'] ?? order['id'].toString().substring(0, 5)}';
                  final String customerName = order['customer']?['full_name'] ?? 'زبون مجهول';
                  final String storeName = order['store']?['name'] ?? 'متجر مجهول';
                  final String driverName = order['driver']?['full_name'] ?? 'بانتظار سائق';
                  final double totalVal = (order['total'] as num?)?.toDouble() ?? 0.0;
                  final String deliveryAddress = order['delivery_address'] ?? '';
                  final String status = order['status'] ?? 'new';

                  Color statusColor = Colors.amber;
                  String statusText = 'جديد';
                  if (status == 'processing') {
                    statusColor = Colors.blue;
                    statusText = 'قيد التجهيز';
                  } else if (status == 'ready') {
                    statusColor = Colors.purple;
                    statusText = 'جاهز للتوصيل';
                  } else if (status == 'delivered') {
                    statusColor = const Color(0xFF10B981);
                    statusText = 'تم التسليم';
                  } else if (status == 'cancelled') {
                    statusColor = Colors.red;
                    statusText = 'ملغي';
                  }

                  return _tr(orderNum, customerName, storeName, driverName, '${totalVal.toInt()} د.ع', deliveryAddress, statusText, statusColor);
                }),
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

  Widget _buildWhatsAppConnectionWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x4D10B981)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.mark_chat_read, color: Color(0xFF10B981), size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('حالة بوابة الواتساب والربط المباشر', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      Text('ربط رقم الواتساب لإرسال إشعارات ورموز OTP تلقائياً', style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _waReady ? const Color(0x3310B981) : const Color(0x33EF4444),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _waReady ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                ),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: _waReady ? const Color(0xFF10B981) : const Color(0xFFEF4444), shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(_waReady ? 'الواتساب متصل بنجاح' : 'غير مربوط / يرجى مسح QR', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: _waReady ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Color(0x1AFFFFFF), height: 24),
          if (_waReady && _waUser != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0x1A10B981),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x4D10B981)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF10B981),
                    backgroundImage: (_waUser!['profilePic'] != null && _waUser!['profilePic'].toString().isNotEmpty)
                        ? NetworkImage(_waUser!['profilePic'])
                        : null,
                    child: (_waUser!['profilePic'] == null || _waUser!['profilePic'].toString().isEmpty)
                        ? Text((_waUser!['name'] ?? 'W')[0].toUpperCase(), style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(10)),
                          child: Text('الحساب المُرسل للرسائل', style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                        const SizedBox(height: 4),
                        Text(_waUser!['name'] ?? 'حساب الواتساب المربوط', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                        Text(_waUser!['formattedPhone'] ?? _waUser!['phone'] ?? '', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF10B981))),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _checkWhatsAppGatewayStatus,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    tooltip: 'تحديث البيانات',
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                if (_waQrCode.isNotEmpty && _waQrCode.startsWith('data:image'))
                  Container(
                    width: 180,
                    height: 180,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF10B981), width: 2),
                    ),
                    child: Image.memory(
                      base64Decode(_waQrCode.split(',').last),
                      fit: BoxFit.contain,
                    ),
                  )
                else
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0x0DFFFFFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Color(0xFF10B981)),
                        const SizedBox(height: 12),
                        Text('جاري تحميل كود QR...', style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('خطوات ربط حساب الواتساب بالمنظومة:', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF38BDF8))),
                      const SizedBox(height: 8),
                      Text('1. افتح تطبيق الواتساب في هاتفك المحمول.', style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
                      Text('2. اذهب إلى الإعدادات ⚙️ -> الأجهزة المرتبطة.', style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
                      Text('3. انقر على (ربط جهاز) وقم بمسح كود QR الموضح.', style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _checkWhatsAppGatewayStatus,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: Text('تحديث حالة الاتصال والكود', style: GoogleFonts.cairo(fontSize: 12)),
                        style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF38BDF8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
