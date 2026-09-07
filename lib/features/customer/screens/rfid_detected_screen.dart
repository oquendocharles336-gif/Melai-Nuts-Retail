import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class RfidDetectedScreen extends StatelessWidget {
  const RfidDetectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: const BoxDecoration(
                  color: AppColors.successBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 100,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Card Recognized!',
                style: AppTextStyles.headlineLg,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Welcome back,',
                style: AppTextStyles.bodyMd,
              ),
              Text(
                'Melai Santos',
                style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.md,
                ),
                child: Column(
                  children: [
                    Text(
                      'LOYALTY POINTS UPDATED',
                      style: AppTextStyles.labelSm.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('1,250', style: AppTextStyles.headlineSm.copyWith(color: AppColors.textMuted)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text('1,400', style: AppTextStyles.headlineSm.copyWith(color: AppColors.success)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        '+150 points earned this visit',
                        style: AppTextStyles.labelMd.copyWith(color: AppColors.success),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/customer/loyalty')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  child: const Text('Back to Dashboard'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
