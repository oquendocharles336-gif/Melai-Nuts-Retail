import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/payment.dart';
import 'payment_processing_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String orderId;
  final double amount;
  final PaymentMethod initialMethod;

  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.amount,
    this.initialMethod = PaymentMethod.gcash,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  late PaymentMethod _method = widget.initialMethod;
  final _refController = TextEditingController();

  @override
  void dispose() {
    _refController.dispose();
    super.dispose();
  }

  void _processPayment() {
    if (_method == PaymentMethod.card &&
        !_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PaymentProcessingScreen(
          orderId: widget.orderId,
          amount: widget.amount,
          method: _method,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const MelaiAppBar(
        title: 'Pay for Order',
        showBack: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Column(
                  children: [
                    Text(
                      'Amount Due',
                      style: AppTextStyles.labelMd,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₱${widget.amount.toStringAsFixed(0)}',
                      style: AppTextStyles.headlineLg.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Order ${widget.orderId}',
                      style: AppTextStyles.bodySm,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Choose Payment Method',
                style: AppTextStyles.titleMd,
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final m in PaymentMethod.values) ...[
                _MethodTile(
                  method: m,
                  selected: _method == m,
                  onTap: () => setState(() => _method = m),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: AppSpacing.sm),
              if (_method == PaymentMethod.gcash ||
                  _method == PaymentMethod.maya)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusMd,
                    ),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.qr_code_2_rounded,
                        size: 96,
                        color: AppColors.darkBrown,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Scan with ${_method.label}',
                        style: AppTextStyles.bodySm,
                      ),
                    ],
                  ),
                )
              else if (_method == PaymentMethod.card)
                Column(
                  children: [
                    TextFormField(
                      controller: _refController,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final req = ValidationUtils.validateRequired(
                          v,
                          'Card Number',
                        );

                        if (req != null) {
                          return req;
                        }

                        if (v!.replaceAll(' ', '').length < 16) {
                          return 'Please enter a valid card number.';
                        }

                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Card Number',
                        hintText: '4242 4242 4242 4242',
                        prefixIcon: Icon(
                          Icons.credit_card_rounded,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.warningBg,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusMd,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Pay the exact amount at the branch counter or to the rider upon arrival.',
                          style: AppTextStyles.bodySm,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: PrimaryButton(
            label: 'Pay ₱${widget.amount.toStringAsFixed(0)} Now',
            icon: Icons.lock_rounded,
            onPressed: _processPayment,
          ),
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  const _MethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Icon(
              method.icon,
              color: AppColors.darkBrown,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.label,
                    style: AppTextStyles.labelLg,
                  ),
                  Text(
                    method.subtitle,
                    style: AppTextStyles.bodySm,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
