import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';

/// "RFID Loyalty Card Detected" — confirmation shown right after a
/// (simulated) NFC tap, matching the prototype's card-detected screen:
/// member info, current balance, active perks, and redeem/attach actions.
class RfidDetectedScreen extends StatelessWidget {
  const RfidDetectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: MelaiAppBar(
        title: 'Golden Kernel Club',
        showBack: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('1,450 pts', style: AppTextStyles.labelMd.copyWith(color: AppColors.primaryDark)),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.successBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Column(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.contactless_rounded, size: 14, color: AppColors.success),
                        const SizedBox(width: 6),
                        Text(
                          '13.56 MHz NFC Tap Confirmed',
                          style: AppTextStyles.labelMd.copyWith(color: AppColors.success),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'RFID Loyalty Card Detected',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineMd,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Customer matched in Laguna Regional Database in 142ms.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMd,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.workspace_premium_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text('VIP Golden Kernel Member', style: AppTextStyles.labelLg.copyWith(color: AppColors.primary)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(20)),
                        child: Text('Verified Active', style: AppTextStyles.labelSm.copyWith(color: AppColors.success)),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(12)),
                        child: Center(
                          child: Text('JD', style: AppTextStyles.titleMd.copyWith(color: AppColors.primaryDark)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Juan Dela Cruz', style: AppTextStyles.titleMd),
                            Text('MLN-RFID-5419', style: AppTextStyles.bodySm),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.storefront_outlined, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text('Laguna Branch Station', style: AppTextStyles.bodySm),
                        const Spacer(),
                        Text('Santa Cruz Main Counter #01', style: AppTextStyles.labelMd.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CURRENT LOYALTY BALANCE', style: AppTextStyles.labelSm),
                        const SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            style: AppTextStyles.headlineLg.copyWith(color: AppColors.darkBrown),
                            children: [
                              const TextSpan(text: '250 '),
                              TextSpan(text: 'Kernel Points', style: AppTextStyles.titleMd),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.attach_money_rounded, size: 14, color: AppColors.success),
                            Text('Available value: ₱75 discount', style: AppTextStyles.bodySm.copyWith(color: AppColors.success)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.card_giftcard_rounded, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.percent_rounded, size: 16, color: AppColors.darkBrown),
                      const SizedBox(width: 8),
                      Text('VIP Tier Patron Perks Applied', style: AppTextStyles.labelLg),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_rounded, size: 16, color: AppColors.success),
                        const SizedBox(width: 8),
                        Expanded(child: Text('Roasted Garlic Peanuts SKUs', style: AppTextStyles.bodyMd)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(20)),
                          child: Text('+10% Multiplier', style: AppTextStyles.labelSm.copyWith(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Redeem Rewards Now (250 pts available)',
              icon: Icons.card_giftcard_rounded,
              onPressed: () => Navigator.pushNamed(context, '/customer/loyalty/redeem'),
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              label: 'Attach to In-Store Purchase',
              icon: Icons.shopping_cart_outlined,
              onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/customer/loyalty')),
            ),
          ],
        ),
      ),
    );
  }
}
