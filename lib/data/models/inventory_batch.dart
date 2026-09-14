import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// FEFO (First Expired, First Out) urgency tier for a batch, derived from
/// how many days remain until its expiration date.
enum FefoPriority { high, medium, low }

extension FefoPriorityX on FefoPriority {
  String get label {
    switch (this) {
      case FefoPriority.high:
        return 'HIGH';
      case FefoPriority.medium:
        return 'MEDIUM';
      case FefoPriority.low:
        return 'LOW';
    }
  }

  String get description {
    switch (this) {
      case FefoPriority.high:
        return 'Sell within 15 days';
      case FefoPriority.medium:
        return 'Sell within 45 days';
      case FefoPriority.low:
        return 'Fresh batch, no urgency';
    }
  }

  Color get color {
    switch (this) {
      case FefoPriority.high:
        return AppColors.error;
      case FefoPriority.medium:
        return AppColors.warning;
      case FefoPriority.low:
        return AppColors.success;
    }
  }

  Color get background {
    switch (this) {
      case FefoPriority.high:
        return AppColors.errorBg;
      case FefoPriority.medium:
        return AppColors.warningBg;
      case FefoPriority.low:
        return AppColors.successBg;
    }
  }
}

/// A single dummy/static inventory batch: one product, one branch, one
/// roast/pack batch, tracked for FEFO rotation and restock planning.
class InventoryBatch {
  final String id;
  final String productId;
  final String batchCode;
  final String branch;
  final DateTime receivedDate;
  final DateTime expirationDate;
  final int quantity;
  final int restockThreshold;

  const InventoryBatch({
    required this.id,
    required this.productId,
    required this.batchCode,
    required this.branch,
    required this.receivedDate,
    required this.expirationDate,
    required this.quantity,
    this.restockThreshold = 20,
  });

  int get daysUntilExpiry => expirationDate.difference(DateTime.now()).inDays;

  FefoPriority get fefoPriority {
    final days = daysUntilExpiry;
    if (days <= 15) return FefoPriority.high;
    if (days <= 45) return FefoPriority.medium;
    return FefoPriority.low;
  }

  bool get isLowStock => quantity <= restockThreshold;

  /// A simple "top up to 2x threshold" restock suggestion.
  int get recommendedRestockQty =>
      isLowStock ? (restockThreshold * 2 - quantity).clamp(0, 999) : 0;
}
