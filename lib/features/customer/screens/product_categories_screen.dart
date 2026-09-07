import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../data/dummy_data/dummy_products.dart';
import 'product_list_screen.dart';

/// Dedicated "browse by category" screen — a grid of every product
/// category. Tapping a category opens [ProductListScreen] filtered to it.
class ProductCategoriesScreen extends StatelessWidget {
  const ProductCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const MelaiAppBar(title: 'All Categories', showBack: true),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: kProductCategories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemBuilder: (context, i) {
            final cat = kProductCategories[i];
            final count = productsByCategory(cat.id).length;
            return InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductListScreen(categoryId: cat.id),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: cat.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(cat.icon, color: cat.color),
                    ),
                    const Spacer(),
                    Text(cat.name, style: AppTextStyles.titleMd),
                    Text('$count items', style: AppTextStyles.bodySm),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
