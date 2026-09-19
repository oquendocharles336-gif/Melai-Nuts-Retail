import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../data/dummy_data/dummy_notifications.dart';
import '../../../data/models/notification_item.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotificationItem item;

  const NotificationDetailScreen({super.key, required this.item});

  void _delete(BuildContext context) {
    kNotifications.removeWhere((n) => n.id == item.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const MelaiAppBar(title: 'Notification', showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
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
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(color: item.category.color.withValues(alpha: 0.12), shape: BoxShape.circle),
                        child: Icon(item.category.icon, color: item.category.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.category.label, style: AppTextStyles.labelSm.copyWith(color: item.category.color)),
                            Text(item.title, style: AppTextStyles.headlineSm),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  Text(item.body, style: AppTextStyles.bodyMd),
                  const SizedBox(height: 14),
                  Text(_formatDate(item.time), style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SecondaryButton(
              label: 'Delete Notification',
              icon: Icons.delete_outline_rounded,
              onPressed: () => _delete(context),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    final minute = d.minute.toString().padLeft(2, '0');
    return '${months[d.month - 1]} ${d.day}, ${d.year} at $hour:$minute $ampm';
  }
}
