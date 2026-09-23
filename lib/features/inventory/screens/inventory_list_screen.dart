import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../data/dummy_data/dummy_inventory.dart';
import '../widgets/inventory_card.dart';

/// Full product-level inventory list — one row per product, aggregated
/// across all branches. Tap through to see per-branch batch detail.
class InventoryListScreen extends StatelessWidget {
  const InventoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = inventoryItemsByProduct;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const MelaiAppBar(title: 'Inventory List', showBack: true),
      body: SafeArea(
        child: items.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text('No inventory yet.', style: AppTextStyles.headlineSm.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 8),
                    Text('Add products to track their inventory.', style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final item = items[i];
                  return InventoryCard.item(
                    item: item,
                    onTap: () => Navigator.of(context)
                        .pushNamed(AppRoutes.inventoryProductDetails, arguments: item.productId),
                  );
                },
              ),
      ),
    );
  }
}
