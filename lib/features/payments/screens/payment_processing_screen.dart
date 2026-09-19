import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/payment.dart';
import 'payment_success_screen.dart';
import 'payment_failed_screen.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final String orderId;
  final double amount;
  final PaymentMethod method;

  const PaymentProcessingScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.method,
  });

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _process();
  }

  Future<void> _process() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    final success = Random().nextDouble() > 0.12;
    final txnId = 'PAY-${100000 + Random().nextInt(899999)}';
    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            transactionId: txnId,
            orderId: widget.orderId,
            amount: widget.amount,
            method: widget.method,
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentFailedScreen(
            orderId: widget.orderId,
            amount: widget.amount,
            method: widget.method,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 20),
              Text('Processing Payment…', style: AppTextStyles.titleMd),
              const SizedBox(height: 6),
              Text('Confirming with ${widget.method.label}', style: AppTextStyles.bodySm),
            ],
          ),
        ),
      ),
    );
  }
}
