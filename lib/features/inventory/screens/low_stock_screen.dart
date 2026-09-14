import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/dummy_data/dummy_inventory.dart';
import '../../../data/dummy_data/dummy_products.dart';

/// Low-stock batches across every branch, each with a restock
/// recommendation, matching the spec's "Current 25 → +10 → New 35" style
/// analysis (the actual adjustment happens on [InventoryAdjustmentScreen]).
class LowStockScreen extends StatelessWidget {
  const LowStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final batches = lowStockBatches;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const MelaiAppBar(title: 'Low Stock & Restock', showBack: true),
      body: SafeArea(
        child: batches.isEmpty
            ? Center(child: Text('All branches are well stocked. 🎉', style: AppTextStyles.bodyMd))
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: batches.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final batch = batches[i];
                  final product = findProductById(batch.productId);
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                      boxShadow: AppShadows.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(product.icon, color: product.color, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(product.name, style: AppTextStyles.labelLg)),
                            Text(batch.branch, style: AppTextStyles.bodySm),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Current: ${batch.quantity} / Threshold: ${batch.restockThreshold}',
                              style: AppTextStyles.bodySm,
                            ),
                            Text(
                              'Suggested: +${batch.recommendedRestockQty}',
                              style: AppTextStyles.labelLg.copyWith(color: AppColors.success),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            label: 'Restock +${batch.recommendedRestockQty}',
                            icon: Icons.add_circle_outline_rounded,
                            onPressed: () => Navigator.of(context).pushNamed(
                              AppRoutes.inventoryAdjustment,
                              arguments: batch,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
