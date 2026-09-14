import 'package:flutter/material.dart';
import '../models/loyalty.dart';

final List<LoyaltyPointTransaction> dummyLoyaltyTransactions = [
  LoyaltyPointTransaction(
    id: 'tx1',
    date: DateTime.now().subtract(const Duration(days: 2)),
    points: 35,
    type: LoyaltyTransactionType.earn,
    description: 'Purchase: 500g Adobo Nuts',
  ),
  LoyaltyPointTransaction(
    id: 'tx2',
    date: DateTime.now().subtract(const Duration(days: 5)),
    points: 100,
    type: LoyaltyTransactionType.redeem,
    description: 'RFID Tap Redemption: ₱25 Cash Voucher',
  ),
  LoyaltyPointTransaction(
    id: 'tx3',
    date: DateTime.now().subtract(const Duration(days: 10)),
    points: 150,
    type: LoyaltyTransactionType.earn,
    description: 'VIP Kernel Anniversary Bonus',
  ),
  LoyaltyPointTransaction(
    id: 'tx4',
    date: DateTime.now().subtract(const Duration(days: 15)),
    points: 50,
    type: LoyaltyTransactionType.earn,
    description: 'Daily Check-in Bonus',
  ),
];

final List<RewardItem> dummyRewards = [
  RewardItem(
    id: 'r1',
    title: '₱10 Branch Discount',
    description: 'Valid on any snack tub or garlic pouch.',
    pointsRequired: 50,
    badgeLabel: 'Instant Voucher',
    icon: Icons.confirmation_number_outlined,
    color: const Color(0xFFA06235),
  ),
  RewardItem(
    id: 'r2',
    title: '₱25 Counter Discount',
    description: 'Min. purchase of ₱150 at POS.',
    pointsRequired: 100,
    badgeLabel: 'Most Popular',
    icon: Icons.percent_rounded,
    color: const Color(0xFFD9822B),
  ),
  RewardItem(
    id: 'r3',
    title: '₱75 Premium Discount',
    description: 'Applicable on wholesale & bulk jars.',
    pointsRequired: 250,
    badgeLabel: 'Best Value',
    icon: Icons.card_giftcard_rounded,
    color: const Color(0xFF7B563F),
  ),
  RewardItem(
    id: 'r4',
    title: 'Free 100g Garlic Pouch',
    description: 'Freshly roasted Melai Laguna batch.',
    pointsRequired: 250,
    badgeLabel: 'Free Item',
    icon: Icons.eco_rounded,
    color: const Color(0xFF387B44),
  ),
];
