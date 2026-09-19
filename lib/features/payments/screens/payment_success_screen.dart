import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/payment.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String transactionId;
  final String orderId;
  final double amount;
  final PaymentMethod method;

  const PaymentSuccessScreen({
    super.key,
    required this.transactionId,
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
                decoration: const BoxDecoration(color: AppColors.successBg, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, color: AppColors.success, size: 46),
              ),
              const SizedBox(height: 16),
              Text('Payment Successful', style: AppTextStyles.headlineMd),
              const SizedBox(height: 6),
              Text(
                '₱${amount.toStringAsFixed(0)} paid via ${method.label}',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd,
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.sm,
                ),
                child: Column(
                  children: [
                    _Row('Transaction ID', transactionId),
                    _Row('Order Reference', orderId),
                    _Row('Payment Method', method.label),
                    _Row('Amount Paid', '₱${amount.toStringAsFixed(0)}'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Done',
                icon: Icons.check_rounded,
                onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySm),
          Expanded(child: Text(value, style: AppTextStyles.labelLg, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}