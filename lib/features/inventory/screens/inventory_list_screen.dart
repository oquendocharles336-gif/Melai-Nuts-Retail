import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
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
        child: ListView.separated(
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
