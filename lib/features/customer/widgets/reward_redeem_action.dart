import 'package:flutter/material.dart';
import '../../../core/services/customer_data_store.dart';
import '../../../data/models/loyalty.dart';
import '../../../data/repositories/loyalty_repository.dart';

/// Redeems [reward] for real (atomic check-and-deduct via the
/// `redeem_reward` Supabase function), refreshes the cached balance/history,
/// and navigates to [RedemptionSuccessScreen] with the real new balance —
/// or shows an error (e.g. not enough points) if it fails. No points ever
/// move locally before the server confirms it.
Future<void> redeemRewardAndNavigate(BuildContext context, RewardItem reward) async {
  try {
    final newBalance = await LoyaltyRepository.instance.redeemReward(reward.id);
    await CustomerDataStore.instance.refresh();
    if (!context.mounted) return;
    Navigator.pushNamed(
      context,
      '/customer/loyalty/redemption-success',
      arguments: RedemptionResult(reward: reward, pointsAfter: newBalance),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not redeem: ${e.toString()}')),
    );
  }
}
