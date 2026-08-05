// ============================================================================
// بيانات وهمية (Mock Data) مطابقة للصورة المرجعية
// ============================================================================

import 'package:flutter/material.dart';
import '../models/models.dart';

class MockData {
  // ──────────────── Categories (مطابقة للصورة) ────────────────
  static final List<CategoryModel> categories = [
    CategoryModel(
      id: 'grocery',
      name: 'بقالة',
      nameEn: 'Grocery',
      icon: 'basket_shopping',
      colorValue: 0xFF10B981,
      description: 'خضار فريش، مواد غذائية',
    ),
    CategoryModel(
      id: 'restaurants',
      name: 'مطاعم',
      nameEn: 'Restaurants',
      icon: 'utensils',
      colorValue: 0xFFD97706,
      description: 'مشويات، كباب، بيتزا',
    ),
    CategoryModel(
      id: 'pharmacy',
      name: 'صيدليات',
      nameEn: 'Pharmacy',
      icon: 'medical',
      colorValue: 0xFFEF4444,
      description: 'أدوية ومستحضرات 24/7',
    ),
    CategoryModel(
      id: 'construction',
      name: 'مواد بناء',
      nameEn: 'Construction',
      icon: 'construction',
      colorValue: 0xFF7C3AED,
      description: 'سمنت، حديد، طابوق، رمل',
    ),
    CategoryModel(
      id: 'events',
      name: 'تأجير مناسبات',
      nameEn: 'Event Rentals',
      icon: 'celebration',
      colorValue: 0xFFD4A843,
      description: 'خيام، كراسي، تجهيزات',
    ),
    CategoryModel(
      id: 'transport',
      name: 'نقل ومعدات',
      nameEn: 'Transport',
      icon: 'truck',
      colorValue: 0xFF3B82F6,
      description: 'شفلات، كرينات، لوريات',
    ),
  ];

  // ──────────────── Category Icons Map ────────────────
  static IconData getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'basket_shopping':
        return Icons.shopping_basket;
      case 'utensils':
        return Icons.restaurant;
      case 'medical':
        return Icons.medical_services;
      case 'construction':
        return Icons.construction;
      case 'celebration':
        return Icons.celebration;
      case 'truck':
        return Icons.local_shipping;
      default:
        return Icons.category;
    }
  }

  // ──────────────── Construction Products (مواد البناء) ────────────────
  static final List<ProductModel> constructionProducts = [
    ProductModel(
      id: 'p1',
      name: 'سمنت بورتلاندي مقاوم',
      description: 'كيس 50 كغم - درجة ممتازة عالية الصلابة',
      price: 10000,
      unit: 'كيس',
      categoryId: 'construction',
      storeId: 's1',
      isHeavy: true,
      badge: 'توصيل سريع',
    ),
    ProductModel(
      id: 'p2',
      name: 'حديد تسليح حلزوني 12ملم',
      description: 'طن كامل مع التوصيل بالكرين لموقع العمل',
      price: 980000,
      unit: 'طن',
      categoryId: 'construction',
      storeId: 's1',
      isHeavy: true,
      badge: 'طلب ضخم',
    ),
    ProductModel(
      id: 'p3',
      name: 'طابوق جمهوري مفحوص',
      description: 'حاملة 1000 طابوقة - تسليم موقع المشروع',
      price: 180000,
      unit: '1000 طابوقة',
      categoryId: 'construction',
      storeId: 's1',
      isHeavy: true,
    ),
    ProductModel(
      id: 'p4',
      name: 'رمل مغسول مقلع',
      description: 'حمل لوري قلاب (15 متر مكعب)',
      price: 120000,
      unit: 'لوري',
      categoryId: 'construction',
      storeId: 's1',
      isHeavy: true,
    ),
    ProductModel(
      id: 'p5',
      name: 'حديد تسليح 16ملم تركيا',
      description: 'حديد حلزوني تركي ممتاز - طن كامل',
      price: 1050000,
      unit: 'طن',
      categoryId: 'construction',
      storeId: 's1',
      isHeavy: true,
    ),
    ProductModel(
      id: 'p6',
      name: 'بلوك خرساني 20سم',
      description: 'بلوك بناء خرساني مصنع - باليت 100 قطعة',
      price: 85000,
      unit: 'باليت',
      categoryId: 'construction',
      storeId: 's1',
      isHeavy: true,
    ),
  ];

  // ──────────────── Grocery Products (بقالة) ────────────────
  static final List<ProductModel> groceryProducts = [
    ProductModel(
      id: 'g1',
      name: 'طماطة فريش',
      description: 'طماطة عراقية طازجة - كيلوغرام',
      price: 2000,
      unit: 'كيلو',
      categoryId: 'grocery',
      storeId: 's2',
      badge: 'طازج اليوم',
    ),
    ProductModel(
      id: 'g2',
      name: 'رز عنبر بسمتي',
      description: 'رز بسمتي عنبر هندي فاخر 5 كيلو',
      price: 18000,
      unit: '5 كيلو',
      categoryId: 'grocery',
      storeId: 's2',
    ),
    ProductModel(
      id: 'g3',
      name: 'زيت عباد الشمس',
      description: 'زيت طعام مكرر عالي الجودة 5 لتر',
      price: 12000,
      unit: '5 لتر',
      categoryId: 'grocery',
      storeId: 's2',
    ),
    ProductModel(
      id: 'g4',
      name: 'سكر أبيض ناعم',
      description: 'سكر ناعم ابيض 10 كيلوغرام',
      price: 8000,
      unit: '10 كيلو',
      categoryId: 'grocery',
      storeId: 's2',
    ),
  ];

  // ──────────────── Store Orders (مطابقة الصورة) ────────────────
  static final List<OrderModel> storeOrders = [
    OrderModel(
      id: 'o104',
      orderNumber: '104',
      customerId: 'c1',
      customerName: 'مهندس علي الحسيني',
      storeId: 's1',
      storeName: 'معمل الوفاء للمواد',
      driverId: 'd1',
      driverName: 'حيدر الكعبي',
      items: [
        OrderItem(
          productName: 'سمنت لافارج مقاوم',
          quantity: 20,
          price: 10000,
          unit: 'كيس',
        ),
        OrderItem(
          productName: 'حديد تسليح 12ملم',
          quantity: 1,
          price: 980000,
          unit: 'طن',
        ),
      ],
      subtotal: 1180000,
      deliveryFee: 12000,
      total: 1192000,
      status: 'new',
      deliveryAddress: 'كربلاء، حي الأطباء',
      deliveryLat: 32.6250,
      deliveryLng: 44.0150,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      isHeavyDelivery: true,
    ),
    OrderModel(
      id: 'o103',
      orderNumber: '103',
      customerId: 'c2',
      customerName: 'مقاولات كربلاء الكبرى',
      storeId: 's1',
      storeName: 'متجر الهناء للمواد',
      driverId: 'd2',
      driverName: 'محمد جاسم',
      items: [
        OrderItem(
          productName: 'طابوق جمهوري ممتاز',
          quantity: 1000,
          price: 180,
          unit: 'طابوقة',
        ),
      ],
      subtotal: 180000,
      deliveryFee: 12000,
      total: 192000,
      status: 'processing',
      deliveryAddress: 'كربلاء، حي المعلمين',
      createdAt: DateTime.now().subtract(const Duration(minutes: 18)),
      isHeavyDelivery: true,
    ),
    OrderModel(
      id: 'o102',
      orderNumber: '102',
      customerId: 'c3',
      customerName: 'د. فاطمة الزهراء',
      storeId: 's3',
      storeName: 'صيدلية الشفاء',
      driverId: 'd3',
      driverName: 'كرار العبودي',
      items: [
        OrderItem(
          productName: 'أدوية ضغط',
          quantity: 2,
          price: 15000,
          unit: 'علبة',
        ),
      ],
      subtotal: 30000,
      deliveryFee: 5000,
      total: 35000,
      status: 'delivered',
      deliveryAddress: 'كربلاء، شارع السنان',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      deliveredAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  // ──────────────── Driver Data (مطابقة الصورة) ────────────────
  static final DriverModel currentDriver = DriverModel(
    id: 'd1',
    name: 'حيدر الكعبي',
    phone: '07801234567',
    vehicleType: 'truck',
    vehicleName: 'شاحنة نقل متوسطة (كيا)',
    rating: 4.9,
    isOnline: true,
    todayEarnings: 55000,
    completedOrders: 6,
    lat: 32.6120,
    lng: 44.0280,
  );

  // ──────────────── Store Data (مطابقة الصورة) ────────────────
  static final StoreModel currentStore = StoreModel(
    id: 's1',
    name: 'متجر الهناء لمواد البناء والتجهيزات العامة',
    ownerId: 'u1',
    categoryId: 'construction',
    address: 'كربلاء المقدسة - المنطقة الصناعية',
    phone: '07809876543',
    lat: 32.6180,
    lng: 44.0320,
    rating: 4.8,
    isOpen: true,
  );
}
