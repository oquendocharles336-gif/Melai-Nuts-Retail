import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../models/loyalty.dart';

/// TEMPORARY PLACEHOLDER DATA — see dummy_products.dart for context.
/// Replace with real loyalty data from a backend before shipping.

final DateTime _now = DateTime.now();

final List<RewardItem> dummyRewards = [
  RewardItem(
    id: 'r-1',
    title: '₱50 Off Voucher',
    description: 'Use on any order of ₱300 or more.',
    pointsRequired: 200,
    badgeLabel: 'Instant Voucher',
    icon: Icons.confirmation_number_rounded,
    color: AppColors.primary,
  ),
  RewardItem(
    id: 'r-2',
    title: 'Free 100g Classic Roasted Peanuts',
    description: 'Redeem for a free bag on your next visit.',
    pointsRequired: 150,
    badgeLabel: 'Most Popular',
    icon: Icons.redeem_rounded,
    color: AppColors.warning,
  ),
  RewardItem(
    id: 'r-3',
    title: 'Free Delivery Voucher',
    description: 'Waive the delivery fee on your next order.',
    pointsRequired: 80,
    badgeLabel: 'Instant Voucher',
    icon: Icons.local_shipping_rounded,
    color: AppColors.success,
  ),
  RewardItem(
    id: 'r-4',
    title: '₱150 Off Voucher',
    description: 'Use on any order of ₱800 or more.',
    pointsRequired: 500,
    badgeLabel: 'Big Saver',
    icon: Icons.card_giftcard_rounded,
    color: AppColors.error,
  ),
];

final List<LoyaltyPointTransaction> dummyLoyaltyTransactions = [
  LoyaltyPointTransaction(
    id: 'tx-1',
    date: _now.subtract(const Duration(minutes: 45)),
    points: 33,
    type: LoyaltyTransactionType.earn,
    description: 'Earned from order ORD-1005',
  ),
  LoyaltyPointTransaction(
    id: 'tx-2',
    date: _now.subtract(const Duration(days: 1)),
    points: 21,
    type: LoyaltyTransactionType.earn,
    description: 'Earned from order ORD-1004',
  ),
  LoyaltyPointTransaction(
    id: 'tx-3',
    date: _now.subtract(const Duration(days: 5)),
    points: 80,
    type: LoyaltyTransactionType.redeem,
    description: 'Redeemed: Free Delivery Voucher',
  ),
  LoyaltyPointTransaction(
    id: 'tx-4',
    date: _now.subtract(const Duration(days: 9)),
    points: 38,
    type: LoyaltyTransactionType.earn,
    description: 'Earned from order ORD-1003',
  ),
];
