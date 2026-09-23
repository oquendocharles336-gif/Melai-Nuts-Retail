import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../data/dummy_data/dummy_products.dart';
import '../../../data/dummy_data/dummy_inventory.dart';
import '../../../data/models/product.dart';

/// "Edit Product" — same section layout as [AddProductScreen], pre-filled
/// with the selected product's current data. Frontend-only: "Save Changes"
/// just confirms and pops back.
class EditProductScreen extends StatefulWidget {
  final String productId;

  const EditProductScreen({super.key, required this.productId});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Product _product = findProductById(widget.productId);
  late final _nameController = TextEditingController(text: _product.name);
  late final _descriptionController = TextEditingController(text: _product.description);
  late final _cogsController = TextEditingController(text: _product.costPrice.toStringAsFixed(2));
  late final _srpController = TextEditingController(text: _product.price.toStringAsFixed(2));
  late String _category = _product.categoryId;
  late bool _isActive = _product.isActive;
  late final Set<String> _selectedBranches = {..._product.branchAvailability};
  bool _saving = false;

  double get _cogs => double.tryParse(_cogsController.text) ?? 0;
  double get _srp => double.tryParse(_srpController.text) ?? 0;
  double get _margin => _srp == 0 ? 0 : ((_srp - _cogs) / _srp) * 100;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _cogsController.dispose();
    _srpController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBranches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one branch.')),
      );
      return;
    }

    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Simulated: "${_nameController.text}" changes saved.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete this product?'),
                content: Text('${_product.name} will be removed from the catalog. This is a frontend-only simulation.'),
                actions: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Simulated: ${_product.name} deleted.')),
                      );
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _SectionCard(
                title: 'Product Media & Images',
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(color: _product.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                      child: Icon(_product.icon, color: _product.color, size: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Simulated: photo picker opened (no backend/storage).')),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Change Photo'),
                      ),
                    ),
                  ],
                ),
              ),
              _SectionCard(
                title: 'Basic Information',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: 'Product Name *',
                      controller: _nameController,
                      validator: (v) => ValidationUtils.validateRequired(v, 'Product Name'),
                    ),
                    const SizedBox(height: 14),
                    Text('Category *', style: AppTextStyles.labelLg),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      items: [for (final c in kProductCategories) DropdownMenuItem(value: c.id, child: Text(c.name))],
                      onChanged: (v) => setState(() => _category = v ?? _category),
                      validator: (v) => ValidationUtils.validateRequired(v, 'Category'),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(label: 'Product Description', controller: _descriptionController),
                    const SizedBox(height: 4),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _isActive,
                      activeThumbColor: AppColors.primary,
                      title: Text('Active in catalog & POS', style: AppTextStyles.labelLg),
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                  ],
                ),
              ),
              _SectionCard(
                title: 'Pricing & Cost',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Cost of Goods (COGS)',
                            controller: _cogsController,
                            prefixIcon: Icons.receipt_long_outlined,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'Base Retail Price (SRP) *',
                            controller: _srpController,
                            prefixIcon: Icons.sell_outlined,
                            keyboardType: TextInputType.number,
                            validator: (v) => ValidationUtils.validateRequired(v, 'Retail Price'),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _margin >= 50 ? AppColors.successBg : AppColors.warningBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(_margin >= 50 ? Icons.check_circle : Icons.info_outline_rounded,
                              size: 18, color: _margin >= 50 ? AppColors.success : AppColors.warning),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Margin: ${_margin.toStringAsFixed(1)}% (₱${(_srp - _cogs).toStringAsFixed(2)} profit/unit)',
                              style: AppTextStyles.labelMd.copyWith(color: _margin >= 50 ? AppColors.success : AppColors.warning),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.productVariants, arguments: _product.id),
                      icon: const Icon(Icons.tune_rounded, size: 16),
                      label: const Text('Manage Variants & Per-Variant Pricing'),
                    ),
                  ],
                ),
              ),
              _SectionCard(
                title: 'Branch Availability',
                child: Column(
                  children: [
                    for (final branch in kInventoryBranches)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _selectedBranches.contains(branch),
                        activeColor: AppColors.primary,
                        title: Text(branch, style: AppTextStyles.bodyMd),
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            _selectedBranches.add(branch);
                          } else {
                            _selectedBranches.remove(branch);
                          }
                        }),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: SecondaryButton(label: 'Cancel', onPressed: () => Navigator.of(context).pop())),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(label: 'Save Changes', loading: _saving, onPressed: _save),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleMd),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
