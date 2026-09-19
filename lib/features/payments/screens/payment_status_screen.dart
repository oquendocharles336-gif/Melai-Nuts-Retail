import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/dummy_data/dummy_payments.dart';
import '../../../data/models/payment.dart';
import 'payment_screen.dart';

class PaymentStatusScreen extends StatelessWidget {
  final String orderId;
  final double amount;

  const PaymentStatusScreen({super.key, required this.orderId, this.amount = 0});

  @override
  Widget build(BuildContext context) {
    final txn = findPaymentByOrderId(orderId);
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const MelaiAppBar(title: 'Payment Status', showBack: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
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
                      Expanded(child: Text('Order $orderId', style: AppTextStyles.titleMd, overflow: TextOverflow.ellipsis)),
                      if (txn != null) ...[const SizedBox(width: 8), _StatusBadge(status: txn.status)],
                    ],
                  ),
                  const Divider(height: 24),
                  if (txn != null) ...[
                    _Row('Transaction ID', txn.id),
                    _Row('Method', txn.method.label),
                    _Row('Reference No.', txn.referenceNumber),
                    _Row('Amount', '₱${txn.amount.toStringAsFixed(0)}'),
                  ] else
                    Text('No payment record found for this order yet.', style: AppTextStyles.bodyMd),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (txn == null || txn.status == PaymentStatus.failed || txn.status == PaymentStatus.pending)
              PrimaryButton(
                label: 'Pay Now',
                icon: Icons.lock_rounded,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PaymentScreen(orderId: orderId, amount: amount > 0 ? amount : (txn?.amount ?? 0)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final PaymentStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status.label, style: AppTextStyles.labelMd.copyWith(color: status.color)),
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