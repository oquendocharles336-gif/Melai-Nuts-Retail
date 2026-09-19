import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../data/dummy_data/dummy_notifications.dart';
import '../../notifications/screens/notification_center_screen.dart';
import '../../settings/screens/logout_confirmation_screen.dart';
import 'edit_profile_screen.dart';

/// "Account" tab — profile header, loyalty summary, contact info, and
/// settings list (matches the prototype's Account & Settings screen,
/// adapted for the customer role).
class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final unreadCount = kNotifications.where((n) => !n.read).length;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Account & Settings'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Notifications',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationCenterScreen()),
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
        ],
      ),
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
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'ED',
                        style: AppTextStyles.headlineSm.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Elena Dimaculangan', style: AppTextStyles.titleMd),
                        Text('Golden Kernel Member', style: AppTextStyles.bodySm),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.warningBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Silver Tier', style: AppTextStyles.labelMd.copyWith(color: AppColors.warning)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                boxShadow: AppShadows.sm,
              ),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium_rounded, color: AppColors.primaryDark),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Golden Kernel Rewards', style: AppTextStyles.titleMd),
                        Text('250 pts • Earn 1 pt per ₱10 spent', style: AppTextStyles.bodySm),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/customer/loyalty'),
                    child: const Text('Redeem'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Personal & Contact Info', style: AppTextStyles.titleMd),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('Verified', style: AppTextStyles.labelSm.copyWith(color: AppColors.success)),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  const _FieldRow(label: 'FULL NAME', value: 'Elena Dimaculangan'),
                  const _FieldRow(label: 'EMAIL', value: 'elena.dimaculangan@gmail.com'),
                  const _FieldRow(label: 'MOBILE NUMBER', value: '+63 917 536 1288'),
                  const _FieldRow(
                    label: 'DELIVERY ADDRESS',
                    value: 'Unit 4B, Lakeside Residences, Calamba, Laguna',
                  ),
                  const SizedBox(height: 10),
                  SecondaryButton(
                    label: 'Edit Profile Information',
                    icon: Icons.edit_outlined,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('SETTINGS', style: AppTextStyles.labelSm),
            const SizedBox(height: AppSpacing.xs),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.sm,
              ),
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.settings_outlined,
                    title: 'App Settings',
                    subtitle: 'Preferences, branch, and more',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.appSettings),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.shield_outlined,
                    title: 'Login & Security',
                    subtitle: 'Password, 2FA & active sessions',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.accountSecurity),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notification Preferences',
                    subtitle: 'Order updates & promos',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.notificationSettings),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.location_on_outlined,
                    title: 'Saved Addresses',
                    subtitle: '1 address saved',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Saved addresses coming soon')),
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.assignment_return_outlined,
                    title: 'Refund History',
                    subtitle: 'Track your refund requests',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.customerRefundHistory),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SecondaryButton(
              label: 'Log Out of Session',
              icon: Icons.logout_rounded,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LogoutConfirmationScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final String value;

  const _FieldRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelSm),
          Text(value, style: AppTextStyles.bodyLg),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.darkBrown),
      title: Text(title, style: AppTextStyles.labelLg),
      subtitle: Text(subtitle, style: AppTextStyles.bodySm),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
