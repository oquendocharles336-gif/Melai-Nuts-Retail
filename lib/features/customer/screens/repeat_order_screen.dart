import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../data/dummy_data/dummy_orders.dart';
import '../../../data/dummy_data/dummy_products.dart';
import '../../../data/models/order.dart';
import '../cart_controller.dart';
import 'cart_screen.dart';

/// Confirmation step for "Repeat Order": review the previous order's items
/// and add them all back to the cart in one tap.
///
/// Matches each item to a current [Product] + [ProductVariant] by name so
/// it can be added through the same [CartController] used everywhere else.
class RepeatOrderScreen extends StatelessWidget {
  final Order order;

  RepeatOrderScreen({super.key, Order? order}) : order = order ?? kOrders.first;

  void _repeat(BuildContext context) {
    int matched = 0;
    for (final item in order.items) {
      for (final product in kProducts) {
        if (product.name.toLowerCase().contains(item.productName.toLowerCase()) ||
            item.productName.toLowerCase().contains(product.name.toLowerCase())) {
          final variant = product.variants.firstWhere(
                (v) => v.label == item.variantLabel,
            orElse: () => product.variants.first,
          );
          CartController.instance.addProduct(product, variant, quantity: item.quantity);
          matched++;
          break;
        }
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added $matched item(s) from ${order.id} to your cart')),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const MelaiAppBar(title: 'Repeat Order', showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Repeat Order adds the exact items from ${order.id} to your active cart for instant checkout.',
                      style: AppTextStyles.bodyMd,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Items from ${order.id}', style: AppTextStyles.titleMd),
            const SizedBox(height: AppSpacing.sm),
            for (final item in order.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.productName, style: AppTextStyles.labelLg),
                            Text(item.variantLabel, style: AppTextStyles.bodySm),
                          ],
                        ),
                      ),
                      Text('${item.quantity}x', style: AppTextStyles.bodyMd),
                      const SizedBox(width: 12),
                      Text(
                        '₱${item.total.toStringAsFixed(0)}',
                        style: AppTextStyles.labelLg.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order Total', style: AppTextStyles.titleMd),
                  Text(
                    '₱${order.total.toStringAsFixed(0)}',
                    style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Add All to Cart',
              icon: Icons.shopping_cart_checkout_rounded,
              onPressed: () => _repeat(context),
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              label: 'Cancel',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
