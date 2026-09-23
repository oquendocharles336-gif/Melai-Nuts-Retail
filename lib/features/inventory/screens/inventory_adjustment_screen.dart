import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/dummy_data/dummy_products.dart';
import '../../../data/models/inventory_batch.dart';

/// Frontend-only stock adjustment form.
///
/// Example from the spec: Current Stock 25, Adjustment +10 → New Stock 35.
/// Nothing here is persisted — submitting just navigates to the success
/// screen with the computed numbers.
class InventoryAdjustmentScreen extends StatefulWidget {
  final InventoryBatch batch;

  const InventoryAdjustmentScreen({super.key, required this.batch});

  @override
  State<InventoryAdjustmentScreen> createState() => _InventoryAdjustmentScreenState();
}

class _InventoryAdjustmentScreenState extends State<InventoryAdjustmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late int _adjustment = widget.batch.isLowStock ? widget.batch.recommendedRestockQty : 0;
  final _reasonController = TextEditingController();
  String _reasonPreset = 'Restock delivery';

  int get _rawNewStock => widget.batch.quantity + _adjustment;
  int get _newStock => _rawNewStock.clamp(0, 999999);

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_rawNewStock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock cannot go below 0. Reduce the adjustment amount.')),
      );
      return;
    }
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.inventoryAdjustmentSuccess,
      arguments: {
        'productId': widget.batch.productId,
        'batch': widget.batch,
        'adjustment': _adjustment,
        'newStock': _newStock,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = findProductById(widget.batch.productId);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const MelaiAppBar(title: 'Adjust Inventory', showBack: true),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: product.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                      child: Icon(product.icon, color: product.color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name, style: AppTextStyles.labelLg),
                          Text('Batch ${widget.batch.batchCode} • ${widget.batch.branch}', style: AppTextStyles.bodySm),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StockNumber(label: 'Current Stock', value: '${widget.batch.quantity}'),
                        const Icon(Icons.arrow_forward_rounded, color: AppColors.textSecondary),
                        _StockNumber(
                          label: 'Adjustment',
                          value: '${_adjustment >= 0 ? '+' : ''}$_adjustment',
                          valueColor: _adjustment >= 0 ? AppColors.success : AppColors.error,
                        ),
                        const Icon(Icons.arrow_forward_rounded, color: AppColors.textSecondary),
                        _StockNumber(label: 'New Stock', value: '$_newStock', valueColor: AppColors.roleStaff),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filled(
                          onPressed: () => setState(() => _adjustment -= 5),
                          icon: const Icon(Icons.remove_rounded),
                        ),
                        const SizedBox(width: 16),
                        Text('$_adjustment', style: AppTextStyles.headlineLg),
                        const SizedBox(width: 16),
                        IconButton.filled(
                          onPressed: () => setState(() => _adjustment += 5),
                          icon: const Icon(Icons.add_rounded),
                        ),
                      ],
                    ),
                    Text('Tap +/- to adjust by 5 packs', style: AppTextStyles.bodySm),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Reason for Adjustment', style: AppTextStyles.labelLg),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final reason in const ['Restock delivery', 'Damaged goods', 'Stock count correction', 'Branch transfer'])
                    ChoiceChip(
                      label: Text(reason),
                      selected: _reasonPreset == reason,
                      onSelected: (_) => setState(() => _reasonPreset = reason),
                      selectedColor: AppColors.roleStaff.withValues(alpha: 0.15),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(hintText: 'Optional notes...'),
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Submit Adjustment',
                icon: Icons.check_rounded,
                onPressed: _adjustment == 0 || _rawNewStock < 0 ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockNumber extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StockNumber({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.headlineSm.copyWith(color: valueColor)),
        Text(label, style: AppTextStyles.bodySm, textAlign: TextAlign.center),
      ],
    );
  }
}
