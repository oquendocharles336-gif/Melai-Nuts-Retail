import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../core/widgets/primary_button.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushEnabled = true;
  bool _orderUpdates = true;
  bool _deliveryUpdates = true;
  bool _loyaltyUpdates = true;
  bool _promos = false;
  bool _systemAnnouncements = true;
  bool _emailNotifications = false;
  bool _smsNotifications = false;

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification preferences saved.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const MelaiAppBar(title: 'Notification Settings', showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _SectionCard(
              children: [
                _ToggleTile(
                  icon: Icons.notifications_active_rounded,
                  title: 'Push Notifications',
                  subtitle: 'Master switch for all app alerts',
                  value: _pushEnabled,
                  onChanged: (v) => setState(() => _pushEnabled = v),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text('NOTIFY ME ABOUT', style: AppTextStyles.labelSm),
            const SizedBox(height: AppSpacing.xs),
            _SectionCard(
              children: [
                _ToggleTile(
                  icon: Icons.receipt_long_rounded,
                  title: 'Order Updates',
                  subtitle: 'Confirmations, packing, and readiness',
                  value: _orderUpdates,
                  onChanged: _pushEnabled ? (v) => setState(() => _orderUpdates = v) : null,
                ),
                const Divider(height: 1),
                _ToggleTile(
                  icon: Icons.local_shipping_rounded,
                  title: 'Delivery Updates',
                  subtitle: 'Rider dispatch and live ETA changes',
                  value: _deliveryUpdates,
                  onChanged: _pushEnabled ? (v) => setState(() => _deliveryUpdates = v) : null,
                ),
                const Divider(height: 1),
                _ToggleTile(
                  icon: Icons.stars_rounded,
                  title: 'Loyalty & Rewards',
                  subtitle: 'Points earned and reward reminders',
                  value: _loyaltyUpdates,
                  onChanged: _pushEnabled ? (v) => setState(() => _loyaltyUpdates = v) : null,
                ),
                const Divider(height: 1),
                _ToggleTile(
                  icon: Icons.local_offer_rounded,
                  title: 'Promos & Offers',
                  subtitle: 'Sales, discounts, and seasonal deals',
                  value: _promos,
                  onChanged: _pushEnabled ? (v) => setState(() => _promos = v) : null,
                ),
                const Divider(height: 1),
                _ToggleTile(
                  icon: Icons.build_circle_outlined,
                  title: 'System Announcements',
                  subtitle: 'Maintenance and app-wide notices',
                  value: _systemAnnouncements,
                  onChanged: _pushEnabled ? (v) => setState(() => _systemAnnouncements = v) : null,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text('DELIVERY CHANNELS', style: AppTextStyles.labelSm),
            const SizedBox(height: AppSpacing.xs),
            _SectionCard(
              children: [
                _ToggleTile(
                  icon: Icons.email_outlined,
                  title: 'Email Notifications',
                  subtitle: 'Receipts and account emails',
                  value: _emailNotifications,
                  onChanged: (v) => setState(() => _emailNotifications = v),
                ),
                const Divider(height: 1),
                _ToggleTile(
                  icon: Icons.sms_outlined,
                  title: 'SMS Notifications',
                  subtitle: 'Text alerts for critical updates',
                  value: _smsNotifications,
                  onChanged: (v) => setState(() => _smsNotifications = v),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: PrimaryButton(label: 'Save Preferences', icon: Icons.check_rounded, onPressed: _save),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.darkBrown),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelLg),
                Text(subtitle, style: AppTextStyles.bodySm),
              ],
            ),
          ),
          Switch(value: value, activeThumbColor: AppColors.primary, onChanged: onChanged),
        ],
      ),
    );
  }
}
