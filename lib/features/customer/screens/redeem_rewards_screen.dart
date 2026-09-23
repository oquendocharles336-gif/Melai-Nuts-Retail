import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../data/dummy_data/dummy_loyalty.dart';
import '../widgets/reward_card.dart';

class RedeemRewardsScreen extends StatelessWidget {
  const RedeemRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const userPoints = 0;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: MelaiAppBar(
        title: 'Redeem Rewards',
        showBack: true,
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
      body: dummyRewards.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_giftcard_rounded, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('No rewards yet.', style: AppTextStyles.headlineSm.copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  Text('Keep earning points to see available rewards.', style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: dummyRewards.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
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
