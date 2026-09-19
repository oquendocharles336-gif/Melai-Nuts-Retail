import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../core/widgets/secondary_button.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _twoFactorEnabled = false;
  bool _biometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const MelaiAppBar(title: 'Account Security', showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.vpn_key_rounded, color: AppColors.darkBrown),
                      const SizedBox(width: 10),
                      Expanded(child: Text('Password', style: AppTextStyles.titleMd)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Last changed 42 days ago.', style: AppTextStyles.bodyMd),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.resetPassword),
                    child: Row(
                      children: [
                        const Icon(Icons.restart_alt_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Change Password', style: AppTextStyles.labelLg.copyWith(color: AppColors.primary)),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.sm,
              ),
              child: Column(
                children: [
                  _ToggleRow(
                    icon: Icons.smartphone_rounded,
                    title: 'Two-Factor Authentication',
                    subtitle: 'Extra OTP step when signing in on a new device.',
                    value: _twoFactorEnabled,
                    onChanged: (v) => setState(() => _twoFactorEnabled = v),
                  ),
                  const Divider(height: 1),
                  _ToggleRow(
                    icon: Icons.fingerprint_rounded,
                    title: 'Biometric Login',
                    subtitle: 'Use fingerprint or Face ID to sign in faster.',
                    value: _biometricEnabled,
                    onChanged: (v) => setState(() => _biometricEnabled = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Staff and managers can view active POS terminal sessions and supervisor PIN settings in the full security console.',
              style: AppTextStyles.bodySm,
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              label: 'Open Full Security Console',
              icon: Icons.admin_panel_settings_outlined,
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.security),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.darkBrown),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMd),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.bodyMd),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(value: value, activeThumbColor: AppColors.primary, onChanged: onChanged),
        ],
      ),
    );
  }
}
