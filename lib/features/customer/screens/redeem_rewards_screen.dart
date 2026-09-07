import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/dummy_data/dummy_loyalty.dart';
import '../widgets/reward_card.dart';

class RedeemRewardsScreen extends StatelessWidget {
  const RedeemRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const userPoints = 1250;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Redeem Rewards'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  '$userPoints pts',
                  style: AppTextStyles.labelMd.copyWith(color: AppColors.primary),
                ),
              ),
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.7,
        ),
        itemCount: dummyRewards.length,
        itemBuilder: (context, index) {
          final reward = dummyRewards[index];
          return RewardCard(
            reward: reward,
            canRedeem: userPoints >= reward.pointsRequired,
            onRedeem: () {
              Navigator.pushNamed(
                context,
                '/customer/loyalty/redemption-success',
                arguments: reward,
              );
            },
          );
        },
      ),
    );
  }
}
