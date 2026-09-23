import '../models/notification_item.dart';

/// TEMPORARY PLACEHOLDER DATA — see dummy_products.dart for context.
/// Replace with real notification data from a backend before shipping.
///
/// Deliberately `final` (not `const`) since [notification_detail_screen]
/// mutates this list directly via `removeWhere`.
final DateTime _now = DateTime.now();

final List<NotificationItem> kNotifications = [
  NotificationItem(
    id: 'n-1',
    category: NotificationCategory.delivery,
    title: 'Your order is out for delivery',
    body: 'Juan is on the way with your order ORD-1005. ETA 15-20 min.',
    time: _now.subtract(const Duration(minutes: 10)),
  ),
  NotificationItem(
    id: 'n-2',
    category: NotificationCategory.order,
    title: 'Order confirmed',
    body: 'Your order ORD-1005 has been confirmed by Santa Cruz Main.',
    time: _now.subtract(const Duration(minutes: 45)),
    read: true,
  ),
  NotificationItem(
    id: 'n-3',
    category: NotificationCategory.loyalty,
    title: 'You earned 33 points!',
    body: 'Thanks for your recent order — points have been added to your account.',
    time: _now.subtract(const Duration(hours: 2)),
    read: true,
  ),
  NotificationItem(
    id: 'n-4',
    category: NotificationCategory.promo,
    title: 'Weekend promo: 10% off Garlic Peanuts',
    body: 'This weekend only at all Laguna branches.',
    time: _now.subtract(const Duration(days: 1)),
    read: true,
  ),
  NotificationItem(
    id: 'n-5',
    category: NotificationCategory.system,
    title: 'Welcome to Melai Nuts Retailing',
    body: 'Explore our full catalog and start earning loyalty points today.',
    time: _now.subtract(const Duration(days: 4)),
    read: true,
  ),
];
