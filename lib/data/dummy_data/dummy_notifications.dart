import '../models/notification_item.dart';

/// Real notifications — starts empty until connected to a backend.
/// Deliberately `final` (not `const`) since [notification_detail_screen]
/// mutates this list directly via `removeWhere`.
final List<NotificationItem> kNotifications = <NotificationItem>[];
