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

class CategoryProductsScreen extends StatefulWidget {
  final String categoryId;
  const CategoryProductsScreen({super.key, required this.categoryId});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final _numberFormat = NumberFormat('#,###', 'ar');
  int _selectedFilter = 0;

  List<ProductModel> get _products {
    switch (widget.categoryId) {
      case 'construction':
        return MockData.constructionProducts;
      case 'grocery':
        return MockData.groceryProducts;
      default:
        return MockData.constructionProducts; // fallback
    }
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

  Widget _buildProductsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: AppTheme.borderDark),
          ),
          child: Row(
            children: [
              // Product icon/image placeholder
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: _getProductColor(index),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getProductIcon(index),
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_numberFormat.format(product.price)} ${AppConstants.currency}',
                          style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<CartProvider>().addItem(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'تمت إضافة "${product.name}" للسلة'),
                                  backgroundColor: AppTheme.primaryGreen,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('طلب الآن',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: Duration(milliseconds: 250 + (index * 100)))
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
