import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../app/routes.dart';

/// Staff "Notifications" screen — rounded, bordered cards with soft
/// shadows, matching the rest of the app's design system rather than bare
/// ListTiles.
class StaffNotificationsScreen extends StatelessWidget {
  const StaffNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      (
        title: 'Low Stock Alert: Garlic Peanuts',
        time: '2 hours ago • Calamba Branch',
        icon: Icons.warning_rounded,
        isAlert: true,
      ),
      (
        title: 'New Order Received #ORD-4421',
        time: '3 hours ago • Calamba Branch',
        icon: Icons.receipt_long_rounded,
        isAlert: false,
      ),
      (
        title: 'System Maintenance Tonight',
        time: '5 hours ago • All Branches',
        icon: Icons.build_circle_outlined,
        isAlert: false,
      ),
      (
        title: 'Shift Handover Reminder',
        time: 'Yesterday • Calamba Branch',
        icon: Icons.swap_horiz_rounded,
        isAlert: false,
      ),
      (
        title: 'Performance Bonus Applied',
        time: '2 days ago • HQ Payroll',
        icon: Icons.stars_rounded,
        isAlert: false,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const MelaiAppBar(title: 'Notifications', showBack: true),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: notifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final n = notifications[i];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.sm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: n.isAlert ? AppColors.errorBg : AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      n.icon,
                      color: n.isAlert ? AppColors.error : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(n.title, style: AppTextStyles.labelLg),
                        const SizedBox(height: 2),
                        Text(n.time, style: AppTextStyles.bodySm),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondary),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Staff profile screen — matches the prototype's Account & Settings card
/// pattern (avatar header, info card, settings list).
class StaffProfileScreen extends StatelessWidget {
  const StaffProfileScreen({super.key});

  void _logout(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const MelaiAppBar(title: 'Staff Profile', showBack: true),
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
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.roleStaff,
                    child: Text(
                      'JS',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Juan Staff', style: AppTextStyles.headlineSm),
                  Text('Senior Register • Calamba Branch', style: AppTextStyles.bodyMd),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
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
                  _ProfileItem(icon: Icons.badge_outlined, title: 'Employee ID', value: 'MN-STAFF-2024-042'),
                  const Divider(height: 24),
                  _ProfileItem(icon: Icons.calendar_today_rounded, title: 'Joining Date', value: 'March 15, 2024'),
                  const Divider(height: 24),
                  _ProfileItem(icon: Icons.access_time_rounded, title: 'Current Shift', value: '08:00 AM - 05:00 PM'),
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
                  ListTile(
                    leading: const Icon(Icons.settings_outlined, color: AppColors.darkBrown),
                    title: Text('App Settings', style: AppTextStyles.labelLg),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline_rounded, color: AppColors.darkBrown),
                    title: Text('Help & Support', style: AppTextStyles.labelLg),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SecondaryButton(
              label: 'Log Out',
              icon: Icons.logout_rounded,
              onPressed: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _ProfileItem({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodySm),
              Text(value, style: AppTextStyles.labelLg),
            ],
          ),
        ),
      ],
    );
  }
}
