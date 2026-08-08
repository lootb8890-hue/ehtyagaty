// ============================================================================
// شاشة كتالوج منتجات القسم (Category Products Screen)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';
import '../../models/models.dart';
import '../../services/mock_data.dart';
import '../../providers/cart_provider.dart';
import '../../services/database_service.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryId;
  const CategoryProductsScreen({super.key, required this.categoryId});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final _numberFormat = NumberFormat('#,###', 'ar');
  final DatabaseService _dbService = DatabaseService();
  int _selectedFilter = 0;
  List<ProductModel> _firestoreProducts = [];
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoadingProducts = true);
    try {
      final prods = await _dbService.fetchProductsByCategory(widget.categoryId);
      if (mounted) {
        setState(() {
          _firestoreProducts = prods;
          _isLoadingProducts = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingProducts = false);
      }
    }
  }

  List<ProductModel> get _products {
    final List<ProductModel> combined = [];
    
    // Add Firestore-fetched products first
    combined.addAll(_firestoreProducts);

    // Fallback/Mock products
    final List<ProductModel> mockProds;
    switch (widget.categoryId) {
      case 'construction':
        mockProds = MockData.constructionProducts;
        break;
      case 'grocery':
        mockProds = MockData.groceryProducts;
        break;
      default:
        mockProds = MockData.constructionProducts;
    }

    // Add mock products if not already in list by ID
    for (final mock in mockProds) {
      if (!combined.any((p) => p.id == mock.id)) {
        combined.add(mock);
      }
    }

    return combined;
  }

  String get _categoryName {
    final cat = MockData.categories.firstWhere(
      (c) => c.id == widget.categoryId,
      orElse: () => MockData.categories.first,
    );
    return cat.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sub-category filters
                      _buildSubFilters(),
                      const SizedBox(height: 16),

                      // Calculator (for construction)
                      if (widget.categoryId == 'construction')
                        _buildCalculator(),
                      if (widget.categoryId == 'construction')
                        const SizedBox(height: 20),

                      // Products list
                      _buildProductsList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDarker,
        border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/customer'),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.glassWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: const Icon(Icons.arrow_forward_ios,
                  size: 16, color: AppTheme.textPrimary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'قسم $_categoryName',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Consumer<CartProvider>(
            builder: (context, cart, _) => GestureDetector(
              onTap: () => context.go('/customer/cart'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_cart,
                        size: 16, color: AppTheme.primaryGreen),
                    const SizedBox(width: 4),
                    Text(
                      '${cart.itemCount}',
                      style: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubFilters() {
    final filters = widget.categoryId == 'construction'
        ? ['الكل', 'سمنت وحديد', 'طابوق وبلوك', 'رمل وركام', 'كهربائيات']
        : ['الكل', 'خضار', 'فواكه', 'مواد غذائية', 'مشروبات'];

    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(left: index < filters.length - 1 ? 8 : 0),
          child: GestureDetector(
            onTap: () => setState(() => _selectedFilter = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _selectedFilter == index
                    ? AppTheme.primaryBlue
                    : AppTheme.glassWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _selectedFilter == index
                      ? AppTheme.primaryBlue
                      : AppTheme.borderDark,
                ),
              ),
              child: Text(
                filters[index],
                style: TextStyle(
                  color: _selectedFilter == index
                      ? Colors.white
                      : AppTheme.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildCalculator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate,
                  color: AppTheme.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'حاسبة الكميات والتوصيل الثقيل',
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'أدخل مساحة البناء للحصول على تقدير الكميات المطلوبة',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'المساحة (م²)',
                    isDense: true,
                    contentPadding: const EdgeInsets.all(10),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.2),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue),
                child: const Text('احسب',
                    style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  void _showProductDetailsSheet(ProductModel product) {
    int selectedQty = 1;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.inventory_2, color: AppTheme.primaryGold, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_numberFormat.format(product.price)} ${AppConstants.currency} / ${product.unit}',
                          style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'الوصف والتفاصيل:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 6),
              Text(
                product.description.isNotEmpty ? product.description : 'لا يوجد وصف متوفر لهذا المنتج حالياً.',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'الكمية المطلوبة:',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (selectedQty > 1) {
                            setSheetState(() => selectedQty--);
                          }
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.glassWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.borderDark),
                          ),
                          child: const Icon(Icons.remove, size: 16),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '$selectedQty',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setSheetState(() => selectedQty++),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.glassWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.borderDark),
                          ),
                          child: const Icon(Icons.add, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<CartProvider>().addItems(product, selectedQty);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تمت إضافة $selectedQty من "${product.name}" للسلة'),
                        backgroundColor: AppTheme.primaryGreen,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                  child: const Text(
                    'إضافة إلى سلة التسوق',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    if (_isLoadingProducts && _firestoreProducts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(color: AppTheme.primaryGold),
        ),
      );
    }

    final products = _products;
    if (products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text('لا توجد منتجات متوفرة حالياً في هذا القسم.', style: TextStyle(color: AppTheme.textMuted)),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () => _showProductDetailsSheet(product),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppTheme.borderDark),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Product icon/image placeholder
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getProductColor(index),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getProductIcon(index),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    product.description,
                    style: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.7), fontSize: 10.5, height: 1.3),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_numberFormat.format(product.price)} ${AppConstants.currency}',
                  style: const TextStyle(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () => _showProductDetailsSheet(product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text('طلب الآن', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ).animate()
         .fadeIn(delay: Duration(milliseconds: 150 + (index * 60)))
         .slideY(begin: 0.05, end: 0);
      },
    );
  }

  Color _getProductColor(int index) {
    final colors = [
      const Color(0xFF475569),
      const Color(0xFF1E293B),
      const Color(0xFF9A3412),
      const Color(0xFFB45309),
      const Color(0xFF334155),
      const Color(0xFF374151),
    ];
    return colors[index % colors.length];
  }

  IconData _getProductIcon(int index) {
    final icons = [
      Icons.inventory_2,
      Icons.view_column,
      Icons.grid_view,
      Icons.landscape,
      Icons.view_column_outlined,
      Icons.widgets,
    ];
    return icons[index % icons.length];
  }
}
