import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'order.dart';

enum RefundStatus { pending, approved, processing, completed, rejected }

extension RefundStatusX on RefundStatus {
  String get label {
    switch (this) {
      case RefundStatus.pending:
        return 'Pending Review';
      case RefundStatus.approved:
        return 'Approved';
      case RefundStatus.processing:
        return 'Processing';
      case RefundStatus.completed:
        return 'Refunded';
      case RefundStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case RefundStatus.pending:
        return AppColors.warning;
      case RefundStatus.approved:
      case RefundStatus.processing:
        return AppColors.primary;
      case RefundStatus.completed:
        return AppColors.success;
      case RefundStatus.rejected:
        return AppColors.error;
    }
  }

  bool get isFinal => this == RefundStatus.completed || this == RefundStatus.rejected;
}

const List<String> kRefundReasons = [
  'Damaged / Spoiled Product',
  'Wrong Item Delivered',
  'Missing Item(s)',
  'Order Arrived Too Late',
  'Changed My Mind',
  'Other',
];

class RefundRequest {
  final String id;
  final String orderId;
  final DateTime requestedDate;
  final RefundStatus status;
  final String reason;
  final String notes;
  final List<OrderItem> items;
  final double amount;
  final String paymentMethod;
  final List<OrderTimelineStep> timeline;

  const RefundRequest({
    required this.id,
    required this.orderId,
    required this.requestedDate,
    required this.status,
    required this.reason,
    this.notes = '',
    required this.items,
    required this.amount,
    required this.paymentMethod,
    this.timeline = const [],
  });

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);
}
