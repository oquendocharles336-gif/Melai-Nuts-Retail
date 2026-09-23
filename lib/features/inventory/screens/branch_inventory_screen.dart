import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../data/dummy_data/dummy_inventory.dart';
import '../widgets/inventory_card.dart';

/// Inventory for a single branch (e.g. "Calamba Highway Branch") — every
/// product stocked there, aggregated from its batches at that branch.
class BranchInventoryScreen extends StatelessWidget {
  final String branch;

  const BranchInventoryScreen({super.key, required this.branch});

  @override
  Widget build(BuildContext context) {
    final items = inventoryItemsForBranch(branch);
    final batches = batchesForBranch(branch);
    final totalUnits = batches.fold<int>(0, (sum, b) => sum + b.quantity);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: MelaiAppBar(title: branch, showBack: true),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PRODUCTS', style: AppTextStyles.labelSm),
                      Text('${items.length}', style: AppTextStyles.headlineSm),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOTAL UNITS', style: AppTextStyles.labelSm),
                      Text('$totalUnits', style: AppTextStyles.headlineSm),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LOW STOCK', style: AppTextStyles.labelSm),
                      Text(
                        '${batches.where((b) => b.isLowStock).length}',
                        style: AppTextStyles.headlineSm.copyWith(color: AppColors.error),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Products at this branch', style: AppTextStyles.headlineSm),
            const SizedBox(height: AppSpacing.sm),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InventoryCard.item(
                  item: item,
                  onTap: () => Navigator.of(context)
                      .pushNamed(AppRoutes.inventoryProductDetails, arguments: item.productId),
                ),
              ),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No inventory recorded for this branch.', style: AppTextStyles.bodyMd)),
              ),
          ],
        ),
      ),
    );
  }
}
