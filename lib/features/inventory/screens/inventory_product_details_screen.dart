import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/dummy_data/dummy_inventory.dart';
import '../../../data/dummy_data/dummy_products.dart';
import '../widgets/inventory_card.dart';

/// Full inventory detail for a single product (e.g. "Garlic Peanuts"):
/// total stock across branches, then every active batch in FEFO order.
class InventoryProductDetailsScreen extends StatelessWidget {
  final String productId;

  const InventoryProductDetailsScreen({super.key, this.productId = 'p1'});

  @override
  Widget build(BuildContext context) {
    final product = findProductById(productId);
    final batches = batchesForProduct(productId)
      ..sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
    final totalStock = totalStockFor(productId);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: MelaiAppBar(title: product.name, showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.sm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: product.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(product.icon, color: product.color, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, style: AppTextStyles.titleMd),
                        Text('SKU category: ${product.categoryId}', style: AppTextStyles.bodySm),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$totalStock', style: AppTextStyles.headlineSm.copyWith(color: AppColors.roleStaff)),
                      Text('units in stock', style: AppTextStyles.labelSm),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Active Batches (FEFO order)', style: AppTextStyles.headlineSm),
                Text('${batches.length} batches', style: AppTextStyles.bodySm),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            for (int i = 0; i < batches.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InventoryCard.batch(
                  batch: batches[i],
                  nextToSell: i == 0,
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.inventoryBatchDetails, arguments: batches[i]),
                ),
              ),
            if (batches.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No batches recorded for this product.', style: AppTextStyles.bodyMd)),
              ),
            const SizedBox(height: AppSpacing.md),
            if (batches.isNotEmpty)
              PrimaryButton(
                label: 'Adjust Stock',
                icon: Icons.tune_rounded,
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.inventoryAdjustment, arguments: batches.first),
              ),
          ],
        ),
      ),
    );
  }
}
