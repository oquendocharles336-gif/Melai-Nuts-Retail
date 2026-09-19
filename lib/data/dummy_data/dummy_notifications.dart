import '../models/notification_item.dart';

final List<NotificationItem> kNotifications = [
  NotificationItem(
    id: 'NTF-001',
    category: NotificationCategory.delivery,
    title: 'Rider is on the way',
    body: 'Rider Kuya Mark is 15–20 minutes away with order #MLN-ORD-9284.',
    time: DateTime.now().subtract(const Duration(minutes: 20)),
  ),
  NotificationItem(
    id: 'NTF-002',
    category: NotificationCategory.payment,
    title: 'Payment received',
    body: 'Your GCash payment of ₱410 for order #MLN-ORD-9284 was confirmed.',
    time: DateTime.now().subtract(const Duration(hours: 1)),
    read: true,
  ),
  NotificationItem(
    id: 'NTF-003',
    category: NotificationCategory.loyalty,
    title: '+54 Golden Kernel Points earned',
    body: 'Thanks for your order! Points have been added to your loyalty balance.',
    time: DateTime.now().subtract(const Duration(hours: 2)),
    read: true,
  ),
  NotificationItem(
    id: 'NTF-004',
    category: NotificationCategory.promo,
    title: 'Weekend Pasalubong Sale',
    body: 'Get 10% off Family Pasalubong Boxes this weekend at all branches.',
    time: DateTime.now().subtract(const Duration(hours: 6)),
  ),
  NotificationItem(
    id: 'NTF-005',
    category: NotificationCategory.refund,
    title: 'Refund request approved',
    body: 'Your refund request RFD-6104 has been approved and is now processing.',
    time: DateTime.now().subtract(const Duration(days: 1)),
    read: true,
  ),
  NotificationItem(
    id: 'NTF-006',
    category: NotificationCategory.order,
    title: 'Order ready for pickup',
    body: 'Order #MLN-ORD-8841 is packed and ready at Calamba Highway Branch.',
    time: DateTime.now().subtract(const Duration(days: 2)),
    read: true,
  ),
  NotificationItem(
    id: 'NTF-007',
    category: NotificationCategory.system,
    title: 'Scheduled maintenance tonight',
    body: 'The app may be briefly unavailable between 12:00 AM and 1:00 AM.',
    time: DateTime.now().subtract(const Duration(days: 3)),
    read: true,
  ),
];
