import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../data/models/inventory_batch.dart';
import '../../../data/dummy_data/dummy_inventory.dart';
/// Options for adding new inventory. Frontend-only: each option either
/// opens the shared adjustment form (pre-filled with a sample batch) or
/// shows a simulated confirmation.
class AddInventoryScreen extends StatelessWidget {
  const AddInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const MelaiAppBar(title: 'Add Inventory', showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(
              'Choose how you want to add stock. This is a frontend-only demo — no data is sent to a backend.',
              style: AppTextStyles.bodyMd,
            ),
            const SizedBox(height: AppSpacing.lg),
            _OptionCard(
              icon: Icons.document_scanner_outlined,
              title: 'Scan Batch Tag / Invoice (OCR)',
              subtitle: 'Point the camera at a supplier slip or batch tag to auto-fill intake details.',
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.ocrCapture),
            ),
            const SizedBox(height: 12),
            _OptionCard(
              icon: Icons.add_box_outlined,
              title: 'New Batch Entry',
              subtitle: 'Log a freshly roasted batch with its own expiry date.',
              onTap: () {
                final batch = kInventoryBatches.isNotEmpty 
                    ? kInventoryBatches.first 
                    : InventoryBatch(
                        id: 'new',
                        productId: 'p1',
                        batchCode: 'NEW-001',
                        branch: 'Santa Cruz Flagship',
                        receivedDate: DateTime.now(),
                        expirationDate: DateTime.now().add(const Duration(days: 90)),
                        quantity: 0,
                      );
                Navigator.of(context).pushNamed(
                  AppRoutes.inventoryAdjustment,
                  arguments: batch,
                );
              },
            ),
            const SizedBox(height: 12),
            _OptionCard(
              icon: Icons.sync_alt_rounded,
              title: 'Transfer from Branch',
              subtitle: 'Move existing stock in from another Laguna branch.',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Simulated: branch transfer request started.')),
              ),
            ),
            const SizedBox(height: 12),
            _OptionCard(
              icon: Icons.local_shipping_outlined,
              title: 'Restock Order from Supplier',
              subtitle: 'Place a raw-material or packaging restock order.',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Simulated: supplier restock order placed.')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.surfaceContainerLow, shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.roleStaff),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.labelLg),
                  Text(subtitle, style: AppTextStyles.bodySm),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
