import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Lifecycle status of a customer order.
enum OrderStatus { pending, confirmed, preparing, outForDelivery, completed, cancelled }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isActive =>
      this != OrderStatus.completed && this != OrderStatus.cancelled;

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.primary;
      case OrderStatus.preparing:
        return AppColors.primary;
      case OrderStatus.outForDelivery:
        return AppColors.success;
      case OrderStatus.completed:
        return AppColors.textSecondary;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }
}

/// One line item within an [Order].
class OrderItem {
  final String productName;
  final String variantLabel;
  final int quantity;
  final double unitPrice;

  const OrderItem({
    required this.productName,
    required this.variantLabel,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => unitPrice * quantity;
}

/// A single step in an order's tracking timeline.
class OrderTimelineStep {
  final String label;
  final String description;
  final String time;
  final bool done;
  final bool current;

  const OrderTimelineStep({
    required this.label,
    required this.description,
    required this.time,
    this.done = false,
    this.current = false,
  });
}

/// A dummy/static customer order.
class Order {
  final String id;
  final DateTime date;
  final OrderStatus status;
  final String branch;
  final bool isDelivery;
  final List<OrderItem> items;
  final double discount;
  final double deliveryFee;
  final String paymentMethod;
  final int pointsEarned;
  final String? riderName;
  final String? etaLabel;
  final List<OrderTimelineStep> timeline;

  const Order({
    required this.id,
    required this.date,
    required this.status,
    required this.branch,
    required this.isDelivery,
    required this.items,
    this.discount = 0,
    required this.deliveryFee,
    required this.paymentMethod,
    required this.pointsEarned,
    this.riderName,
    this.etaLabel,
    this.timeline = const [],
  });

  double get subtotal => items.fold(0, (sum, i) => sum + i.total);
  double get total => subtotal - discount + deliveryFee;
  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);
}
