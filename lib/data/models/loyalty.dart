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

class RewardItem {
  final String id;
  final String title;
  final String description;
  final int pointsRequired;
  final String imageUrl;

  RewardItem({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.imageUrl,
  });
}
