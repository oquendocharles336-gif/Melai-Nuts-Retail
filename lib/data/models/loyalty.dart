import 'package:flutter/material.dart';

enum LoyaltyTransactionType { earn, redeem }

class LoyaltyPointTransaction {
  final String id;
  final DateTime date;
  final int points;
  final LoyaltyTransactionType type;
  final String description;

  LoyaltyPointTransaction({
    required this.id,
    required this.date,
    required this.points,
    required this.type,
    required this.description,
  });
}

/// A redeemable loyalty reward.
///
/// [icon] + [color] render an on-brand placeholder tile (matching
/// [ProductThumbnail] elsewhere in the app) instead of a network photo, so
/// rewards stay consistent with the rest of the frontend-only, offline app.
class RewardItem {
  final String id;
  final String title;
  final String description;
  final int pointsRequired;
  final String badgeLabel; // e.g. "Instant Voucher", "Most Popular"
  final IconData icon;
  final Color color;

  RewardItem({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.badgeLabel,
    required this.icon,
    required this.color,
  });
}
