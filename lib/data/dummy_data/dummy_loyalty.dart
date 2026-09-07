import '../models/loyalty.dart';

final List<LoyaltyPointTransaction> dummyLoyaltyTransactions = [
  LoyaltyPointTransaction(
    id: 'tx1',
    date: DateTime.now().subtract(const Duration(days: 2)),
    points: 150,
    type: LoyaltyTransactionType.earn,
    description: 'Purchase - Roasted Cashews',
  ),
  LoyaltyPointTransaction(
    id: 'tx2',
    date: DateTime.now().subtract(const Duration(days: 5)),
    points: 500,
    type: LoyaltyTransactionType.redeem,
    description: 'Redeemed: Free 250g Garlic Peanuts',
  ),
  LoyaltyPointTransaction(
    id: 'tx3',
    date: DateTime.now().subtract(const Duration(days: 10)),
    points: 200,
    type: LoyaltyTransactionType.earn,
    description: 'Purchase - Mixed Nuts Platter',
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
    title: 'Free 250g Garlic Peanuts',
    description: 'Our signature garlic roasted peanuts.',
    pointsRequired: 500,
    imageUrl: 'https://images.unsplash.com/photo-1599599810769-bcde5a160d32',
  ),
  RewardItem(
    id: 'r2',
    title: '10% Discount Coupon',
    description: 'Valid for your next purchase over P500.',
    pointsRequired: 800,
    imageUrl: 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da',
  ),
  RewardItem(
    id: 'r3',
    title: 'Free Melai Nuts Tote Bag',
    description: 'Limited edition eco-friendly tote bag.',
    pointsRequired: 1200,
    imageUrl: 'https://images.unsplash.com/photo-1544816155-12df9643f363',
  ),
  RewardItem(
    id: 'r4',
    title: 'Golden Kernel Gift Box',
    description: 'A premium selection of our best-selling nuts.',
    pointsRequired: 2500,
    imageUrl: 'https://images.unsplash.com/photo-1534939561126-855b8675edd7',
  ),
];
