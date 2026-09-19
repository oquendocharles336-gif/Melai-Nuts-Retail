import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Lifecycle status of an entire delivery dispatch.
enum DeliveryStatus { pending, optimized, dispatched, inTransit, completed, cancelled }

extension DeliveryStatusX on DeliveryStatus {
  String get label {
    switch (this) {
      case DeliveryStatus.pending:
        return 'Pending';
      case DeliveryStatus.optimized:
        return 'Route Optimized';
      case DeliveryStatus.dispatched:
        return 'Dispatched';
      case DeliveryStatus.inTransit:
        return 'In Transit';
      case DeliveryStatus.completed:
        return 'Completed';
      case DeliveryStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isActive => this != DeliveryStatus.completed && this != DeliveryStatus.cancelled;

  Color get color {
    switch (this) {
      case DeliveryStatus.pending:
        return AppColors.textSecondary;
      case DeliveryStatus.optimized:
        return AppColors.warning;
      case DeliveryStatus.dispatched:
        return AppColors.primary;
      case DeliveryStatus.inTransit:
        return AppColors.success;
      case DeliveryStatus.completed:
        return AppColors.success;
      case DeliveryStatus.cancelled:
        return AppColors.error;
    }
  }
}

/// Status of a single stop within a delivery route.
enum StopStatus { pending, enRoute, delivered, delayed, skipped }

extension StopStatusX on StopStatus {
  String get label {
    switch (this) {
      case StopStatus.pending:
        return 'Pending';
      case StopStatus.enRoute:
        return 'En Route';
      case StopStatus.delivered:
        return 'Delivered';
      case StopStatus.delayed:
        return 'Delayed';
      case StopStatus.skipped:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case StopStatus.pending:
        return AppColors.textSecondary;
      case StopStatus.enRoute:
        return AppColors.warning;
      case StopStatus.delivered:
        return AppColors.success;
      case StopStatus.delayed:
        return AppColors.warning;
      case StopStatus.skipped:
        return AppColors.error;
    }
  }
}

/// A single stop (customer drop-off) within a [Delivery] route.
class DeliveryStop {
  final String id;
  final String customerName;
  final String address;
  final String orderId;
  final List<String> items;

  /// Position in the *optimized* sequence (0 = first stop after branch).
  final int sequenceIndex;

  /// Distance/time from the previous stop (or from the branch, for the
  /// first stop) — simulated, not from a real routing engine.
  final double distanceFromPreviousKm;
  final int travelMinutesFromPrevious;
  final String eta;

  StopStatus status;
  String? issueReason; // populated when status is delayed/skipped
  String? proofNote; // delivery confirmation note (simulated proof)

  DeliveryStop({
    required this.id,
    required this.customerName,
    required this.address,
    required this.orderId,
    required this.items,
    required this.sequenceIndex,
    required this.distanceFromPreviousKm,
    required this.travelMinutesFromPrevious,
    required this.eta,
    this.status = StopStatus.pending,
    this.issueReason,
    this.proofNote,
  });
}

/// A delivery dispatch: one branch, one vehicle/rider, and an ordered list
/// of stops. All data here is static/dummy — there is no real GPS,
/// routing, or courier API behind this.
class Delivery {
  final String id;
  final String branch;
  final String vehicle;
  final String riderName;
  final DateTime createdAt;
  final List<DeliveryStop> stops;
  DeliveryStatus status;

  Delivery({
    required this.id,
    required this.branch,
    required this.vehicle,
    required this.riderName,
    required this.createdAt,
    required this.stops,
    this.status = DeliveryStatus.pending,
  });

  double get totalDistanceKm => stops.fold(0, (sum, s) => sum + s.distanceFromPreviousKm);
  int get totalTimeMinutes => stops.fold(0, (sum, s) => sum + s.travelMinutesFromPrevious);
  int get totalItems => stops.fold(0, (sum, s) => sum + s.items.length);
  int get deliveredCount => stops.where((s) => s.status == StopStatus.delivered).length;
  bool get isComplete => stops.isNotEmpty && stops.every((s) => s.status == StopStatus.delivered);
}
