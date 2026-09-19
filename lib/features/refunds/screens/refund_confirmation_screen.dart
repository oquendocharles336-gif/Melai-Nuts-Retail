import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../data/models/order.dart';
import '../../../data/models/refund.dart';
import 'refund_processing_screen.dart';

class RefundConfirmationScreen extends StatelessWidget {
  final Order order;
  final List<OrderItem> items;
  final String reason;
  final String notes;
  final double amount;

  const RefundConfirmationScreen({
    super.key,
    required this.order,
    required this.items,
    required this.reason,
    required this.notes,
    required this.amount,
  });

  RefundRequest _buildRequest() {
    return RefundRequest(
      id: 'RFD-${DateTime.now().millisecondsSinceEpoch % 10000}',
      orderId: order.id,
      requestedDate: DateTime.now(),
      status: RefundStatus.pending,
      reason: reason,
      notes: notes,
      items: items,
      amount: amount,
      paymentMethod: order.paymentMethod,
      timeline: const [
        OrderTimelineStep(label: 'Request Submitted', description: 'Refund request received', time: 'Just now', done: true, current: true),
        OrderTimelineStep(label: 'Under Review', description: 'Awaiting branch staff review', time: '—'),
        OrderTimelineStep(label: 'Approved', description: 'Pending', time: '—'),
        OrderTimelineStep(label: 'Processing', description: 'Pending', time: '—'),
        OrderTimelineStep(label: 'Refunded', description: 'Pending', time: '—'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = _buildRequest();
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
                decoration: const BoxDecoration(color: AppColors.warningBg, shape: BoxShape.circle),
                child: const Icon(Icons.hourglass_top_rounded, color: AppColors.warning, size: 44),
              ),
              const SizedBox(height: 16),
              Text('Refund Request Submitted', style: AppTextStyles.headlineMd, textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Text(
                'Request ${request.id} for Order ${order.id} is now pending review.',
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
                    _Row('Refund Amount', '₱${amount.toStringAsFixed(0)}'),
                    _Row('Reason', reason),
                    _Row('Refund To', order.paymentMethod),
                    _Row('Review Time', '1–2 business days'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Track Refund Status',
                icon: Icons.timeline_rounded,
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => RefundProcessingScreen(request: request)),
                ),
              ),
              const SizedBox(height: 10),
              SecondaryButton(
                label: 'Back to Orders',
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
