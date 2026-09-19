import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../core/widgets/primary_button.dart';

class BranchSettingsScreen extends StatefulWidget {
  const BranchSettingsScreen({super.key});

  @override
  State<BranchSettingsScreen> createState() => _BranchSettingsScreenState();
}

class _BranchSettingsScreenState extends State<BranchSettingsScreen> {
  late String _selectedBranch = AppConstants.branches.first;

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Preferred branch set to $_selectedBranch.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const MelaiAppBar(title: 'Branch Settings', showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text('Preferred Branch', style: AppTextStyles.titleMd),
            const SizedBox(height: 4),
            Text('Used for default pickup, inventory, and reporting views.', style: AppTextStyles.bodySm),
            const SizedBox(height: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.sm,
              ),
              child: RadioGroup<String>(
                groupValue: _selectedBranch,
                onChanged: (v) => setState(() => _selectedBranch = v ?? _selectedBranch),
                child: Column(
                  children: [
                    for (final branch in AppConstants.branches) ...[
                      RadioListTile<String>(
                        value: branch,
                        activeColor: AppColors.primary,
                        title: Text(branch, style: AppTextStyles.labelLg),
                        secondary: const Icon(Icons.storefront_outlined, color: AppColors.darkBrown),
                      ),
                      if (branch != AppConstants.branches.last) const Divider(height: 1),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: PrimaryButton(label: 'Save Preference', icon: Icons.check_rounded, onPressed: _save),
        ),
      ),
    );
  }
}