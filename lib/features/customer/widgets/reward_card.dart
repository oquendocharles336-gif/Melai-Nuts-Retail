import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/loyalty.dart';

class RewardCard extends StatelessWidget {
  final RewardItem reward;
  final bool canRedeem;
  final VoidCallback onRedeem;

  const RewardCard({
    super.key,
    required this.reward,
    required this.canRedeem,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Image.network(
                reward.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.surfaceContainerHigh,
                  child: const Icon(Icons.image, color: AppColors.textMuted),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            reward.title,
            style: AppTextStyles.titleMd,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs2),
          Text(
            reward.description,
            style: AppTextStyles.bodySm,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${reward.pointsRequired} pts',
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.primary,
                ),
              ),
              ElevatedButton(
                onPressed: canRedeem ? onRedeem : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
                child: const Text('Redeem'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
