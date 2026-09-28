import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/customer_data_store.dart';
import '../../../core/utils/app_error.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../data/dummy_data/dummy_notifications.dart';
import '../../../data/models/notification_item.dart';
import '../../../data/repositories/notifications_repository.dart';
import 'notification_detail_screen.dart';
import 'notification_settings_screen.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  @override
  void initState() {
    super.initState();
    // Normally loaded at sign-in; (re)try here if that hasn't succeeded yet.
    final uid = AuthService.instance.currentFirebaseUser?.uid;
    final store = CustomerDataStore.instance;
    if (uid != null && !store.hasLoaded && !store.isLoading) {
      store.loadForCustomer(uid);
    }
  }

  Future<void> _markAllRead() async {
    final uid = AuthService.instance.currentFirebaseUser?.uid;
    if (uid == null) return;
    final previouslyUnread = kNotifications.where((n) => !n.read).toList();
    setState(() {
      for (final n in kNotifications) {
        n.read = true;
      }
    });
    try {
      await NotificationsRepository.instance.markAllRead(uid);
    } catch (e) {
      // Not saved: put the unread state back and tell the customer.
      if (!mounted) return;
      setState(() {
        for (final n in previouslyUnread) {
          n.read = false;
        }
      });
      AppErrors.showSnack(context, e);
    }
  }

  Future<void> _open(NotificationItem item) async {
    setState(() => item.read = true);
    NotificationsRepository.instance.markRead(item.id).catchError((_) {});
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NotificationDetailScreen(item: item)),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CustomerDataStore.instance,
      builder: (context, _) => _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final store = CustomerDataStore.instance;
    final unreadCount = kNotifications.where((n) => !n.read).length;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: MelaiAppBar(
        title: 'Notifications',
        showBack: true,
        actions: [
          IconButton(
            tooltip: 'Notification Settings',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
            ),
          ),
          if (unreadCount > 0)
            IconButton(
              tooltip: 'Mark all as read',
              icon: const Icon(Icons.done_all_rounded),
              onPressed: _markAllRead,
            ),
        ],
      ),
      body: SafeArea(
        child: DataStateView(
          isLoading: store.isLoading,
          error: store.error,
          isEmpty: kNotifications.isEmpty,
          onRetry: () => store.retry(),
          emptyIcon: Icons.notifications_none_rounded,
          emptyTitle: 'No notifications yet.',
          emptyMessage: 'Updates about your orders, rewards and offers will appear here.',
          loadingMessage: 'Loading notifications...',
          builder: (context) => RefreshIndicator(
            onRefresh: () => store.refresh(),
            child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: kNotifications.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final n = kNotifications[i];
            return InkWell(
              onTap: () => _open(n),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: n.read ? Colors.white : AppColors.primaryContainer.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.sm,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: n.category.color.withValues(alpha: 0.12), shape: BoxShape.circle),
                      child: Icon(n.category.icon, color: n.category.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.title, style: AppTextStyles.labelLg),
                          const SizedBox(height: 2),
                          Text(n.body, style: AppTextStyles.bodySm, maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(_relativeTime(n.time), style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    if (!n.read)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
          ),
        ),
      ),
    );
  }

  String _relativeTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}