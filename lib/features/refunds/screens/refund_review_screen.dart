import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/order.dart';
import 'refund_confirmation_screen.dart';

class RefundReviewScreen extends StatefulWidget {
  final Order order;
  final List<OrderItem> items;
  final String reason;
  final String notes;
  final double amount;

  const RefundReviewScreen({
    super.key,
    required this.order,
    required this.items,
    required this.reason,
    required this.notes,
    required this.amount,
  });

  @override
  State<RefundReviewScreen> createState() => _RefundReviewScreenState();
}

class _RefundReviewScreenState extends State<RefundReviewScreen> {
  bool _agreed = false;
  bool _submitting = false;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RefundConfirmationScreen(
          order: widget.order,
          items: widget.items,
          reason: widget.reason,
          notes: widget.notes,
          amount: widget.amount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const MelaiAppBar(title: 'Review Refund Request', showBack: true),
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
                  Text('Order ${widget.order.id}', style: AppTextStyles.titleMd),
                  const Divider(height: 20),
                  for (final item in widget.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('${item.quantity}x ${item.productName}', style: AppTextStyles.bodyMd)),
                          Text('₱${item.total.toStringAsFixed(0)}', style: AppTextStyles.bodyMd),
                        ],
                      ),
                    ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Refund Amount', style: AppTextStyles.headlineSm),
                      Text(
                        '₱${widget.amount.toStringAsFixed(0)}',
                        style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary),
                      ),
                    ],
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
                  Text('Reason', style: AppTextStyles.bodySm),
                  Text(widget.reason, style: AppTextStyles.labelLg),
                  if (widget.notes.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text('Notes', style: AppTextStyles.bodySm),
                    Text(widget.notes, style: AppTextStyles.bodyMd),
                  ],
                  const SizedBox(height: 10),
                  Text('Refund Method', style: AppTextStyles.bodySm),
                  Text(widget.order.paymentMethod, style: AppTextStyles.labelLg),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            CheckboxListTile(
              value: _agreed,
              onChanged: (v) => setState(() => _agreed = v ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                'I confirm the details above are accurate and agree to Melai Nuts\' refund policy.',
                style: AppTextStyles.bodySm,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: PrimaryButton(
            label: 'Submit Refund Request',
            icon: Icons.send_rounded,
            loading: _submitting,
            onPressed: _agreed ? _submit : null,
          ),
        ),
      ),
    );
  }
}
