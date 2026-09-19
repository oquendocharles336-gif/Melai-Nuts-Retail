import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../data/models/payment.dart';
import 'payment_screen.dart';

class PaymentFailedScreen extends StatelessWidget {
  final String orderId;
  final double amount;
  final PaymentMethod method;

  const PaymentFailedScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.method,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(color: AppColors.errorBg, shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded, color: AppColors.error, size: 46),
              ),
              const SizedBox(height: 16),
              Text('Payment Failed', style: AppTextStyles.headlineMd),
              const SizedBox(height: 6),
              Text(
                '${method.label} declined the ₱${amount.toStringAsFixed(0)} charge for Order $orderId.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd,
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.errorBg.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.error),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Check your balance or try a different payment method.',
                        style: AppTextStyles.bodySm,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Try Again',
                icon: Icons.refresh_rounded,
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => PaymentScreen(orderId: orderId, amount: amount, initialMethod: method),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SecondaryButton(
                label: 'Cancel',
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
