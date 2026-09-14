import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../data/dummy_data/dummy_products.dart';

/// Management-facing product detail: financial metrics, per-variant
/// pricing matrix, and branch distribution — matches the prototype's
/// owner/staff "Product Details" screen (distinct from the customer-facing
/// storefront details screen in lib/features/customer/).
class ProductDetailsScreen extends StatelessWidget {
  final String productId;

  const ProductDetailsScreen({super.key, this.productId = 'p1'});

  @override
  Widget build(BuildContext context) {
    final product = findProductById(productId);
    final minPrice = product.variants.map((v) => v.price).reduce((a, b) => a < b ? a : b);
    final maxPrice = product.variants.map((v) => v.price).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: MelaiAppBar(
        title: product.name,
        showBack: true,
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.productEdit, arguments: product.id),
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Edit'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: product.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                  child: Icon(product.icon, color: product.color, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        children: [
                          for (final tag in product.tags)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(20)),
                              child: Text(tag, style: AppTextStyles.labelSm),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('SKU: ${product.sku}', style: AppTextStyles.bodySm),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: product.isActive ? AppColors.successBg : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    product.isActive ? 'Active' : 'Inactive',
                    style: AppTextStyles.labelMd.copyWith(color: product.isActive ? AppColors.success : AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Key Financial Metrics', style: AppTextStyles.headlineSm),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSpacing.radiusMd), border: Border.all(color: AppColors.border), boxShadow: AppShadows.sm),
              child: _MetricRow(label: 'Retail Price Range', value: '₱${minPrice.toStringAsFixed(0)} – ₱${maxPrice.toStringAsFixed(0)}', sub: 'Across all ${product.variants.length} packaging tiers'),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSpacing.radiusMd), border: Border.all(color: AppColors.border), boxShadow: AppShadows.sm),
              child: _MetricRow(label: 'Base Unit Cost (COGS)', value: '₱${product.costPrice.toStringAsFixed(2)}', sub: 'Includes raw kernel, garlic & foil'),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSpacing.radiusMd), border: Border.all(color: AppColors.border), boxShadow: AppShadows.sm),
              child: _MetricRow(
                label: 'Average Margin',
                value: '${product.marginPercent.toStringAsFixed(1)}%',
                sub: product.marginPercent >= 55 ? 'Healthy' : 'Below 55% target',
                valueColor: product.marginPercent >= 55 ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSpacing.radiusMd), border: Border.all(color: AppColors.border), boxShadow: AppShadows.sm),
              child: _MetricRow(
                label: '30-Day Sales Volume',
                value: '${product.unitsSoldLast30Days} units',
                sub: '₱${product.monthlyRevenue.toStringAsFixed(0)} gross',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Product Variants & Packaging', style: AppTextStyles.headlineSm),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.productVariants, arguments: product.id),
                  child: const Text('Manage Variants'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSpacing.radiusMd), border: Border.all(color: AppColors.border)),
              child: Column(
                children: [
                  for (int i = 0; i < product.variants.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(child: Text(product.variants[i].label, style: AppTextStyles.bodyMd)),
                          Text('SKU: ${product.variants[i].sku ?? '—'}', style: AppTextStyles.bodySm),
                          const SizedBox(width: 10),
                          Text('₱${product.variants[i].price.toStringAsFixed(0)}', style: AppTextStyles.labelLg),
                        ],
                      ),
                    ),
                    if (i != product.variants.length - 1) const Divider(height: 1),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Branch Distribution & Availability', style: AppTextStyles.headlineSm),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSpacing.radiusMd), border: Border.all(color: AppColors.border)),
              child: Column(
                children: [
                  for (final branch in product.branchAvailability)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.storefront_outlined, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(child: Text(branch, style: AppTextStyles.bodyMd)),
                          Text('Enabled', style: AppTextStyles.bodySm.copyWith(color: AppColors.success)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: product.isActive ? 'Deactivate Product' : 'Activate Product',
                    icon: product.isActive ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Simulated: product ${product.isActive ? 'deactivated' : 'activated'}.')),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PrimaryButton(
                    label: 'Edit Product & Pricing',
                    icon: Icons.edit_outlined,
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.productEdit, arguments: product.id),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color? valueColor;

  const _MetricRow({required this.label, required this.value, required this.sub, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.bodySm),
            Text(sub, style: AppTextStyles.bodySm.copyWith(color: valueColor)),
          ],
        ),
        Text(value, style: AppTextStyles.headlineSm.copyWith(color: valueColor)),
      ],
    );
  }
}
