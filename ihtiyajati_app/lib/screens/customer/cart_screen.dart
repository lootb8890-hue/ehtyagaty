// ============================================================================
// شاشة سلة المشتريات
// ============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../config/app_constants.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###', 'ar');

    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة المشتريات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () => context.go('/customer'),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80, color: AppTheme.textMuted.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('السلة فارغة حالياً',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: AppTheme.textMuted)),
                  const SizedBox(height: 8),
                  Text('قم بإضافة منتجات من الأقسام المتوفرة',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/customer'),
                    child: const Text('تصفح الأقسام'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(color: AppTheme.borderDark),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.inventory_2,
                                color: AppTheme.primaryGold),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.product.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13)),
                                Text(
                                  '${numberFormat.format(item.product.price)} ${AppConstants.currency} / ${item.product.unit}',
                                  style: const TextStyle(
                                      color: AppTheme.primaryGreen,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          // Quantity controls
                          Row(
                            children: [
                              _qtyBtn(Icons.remove, () {
                                cart.updateQuantity(
                                    item.product.id, item.quantity - 1);
                              }),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text('${item.quantity}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16)),
                              ),
                              _qtyBtn(Icons.add, () {
                                cart.updateQuantity(
                                    item.product.id, item.quantity + 1);
                              }),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDarker,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border(top: BorderSide(color: AppTheme.borderDark)),
                ),
                child: Column(
                  children: [
                    _summaryRow('مجموع المنتجات:',
                        '${numberFormat.format(cart.subtotal)} ${AppConstants.currency}'),
                    const SizedBox(height: 6),
                    _summaryRow(
                      'أجرة التوصيل ${cart.hasHeavyItems ? "(ثقيل)" : ""}:',
                      '${numberFormat.format(cart.deliveryFee)} ${AppConstants.currency}',
                    ),
                    const Divider(color: AppTheme.borderDark, height: 20),
                    _summaryRow(
                      'المبلغ الإجمالي:',
                      '${numberFormat.format(cart.grandTotal)} ${AppConstants.currency}',
                      isTotal: true,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('✅ تم إرسال الطلب بنجاح للمتجر!'),
                              backgroundColor: AppTheme.primaryGreen,
                            ),
                          );
                          cart.clear();
                          context.go('/customer');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                        ),
                        child: const Text(
                          'تأكيد الطلب وإرسال للمتجر',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppTheme.glassWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: Icon(icon, size: 16, color: AppTheme.textPrimary),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                color: isTotal ? AppTheme.textPrimary : AppTheme.textSecondary)),
        Text(value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
              color: isTotal ? AppTheme.primaryGreen : AppTheme.textPrimary,
            )),
      ],
    );
  }
}
