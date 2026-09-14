import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/order.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Order order;
  const TransactionDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: Text('Details ${order.id}')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _StatusBadge(status: order.status),
                const SizedBox(height: 16),
                Text('₱${order.total.toStringAsFixed(2)}', style: AppTextStyles.headlineLg.copyWith(color: AppColors.primary)),
                Text('Payment via ${order.paymentMethod}', style: AppTextStyles.bodySm),
                const Divider(height: 40),
                _InfoRow(label: 'Transaction ID', value: order.id),
                _InfoRow(label: 'Date & Time', value: '${order.date.day}/${order.date.month}/${order.date.year} ${order.date.hour}:${order.date.minute}'),
                _InfoRow(label: 'Branch', value: order.branch),
                _InfoRow(label: 'Register ID', value: 'REG-04-CAL'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Items Sold', style: AppTextStyles.titleMd),
          const SizedBox(height: 10),
          ...order.items.map((item) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item.productName, style: AppTextStyles.labelLg),
            subtitle: Text('Quantity: ${item.quantity}'),
            trailing: Text('₱${item.total.toStringAsFixed(0)}', style: AppTextStyles.labelLg),
          )),
          const Divider(),
          const SizedBox(height: 10),
          _SummaryRow(label: 'Subtotal', value: '₱${order.subtotal.toStringAsFixed(0)}'),
          _SummaryRow(label: 'Discount', value: '-₱${order.discount.toStringAsFixed(0)}', color: AppColors.success),
          _SummaryRow(label: 'Total', value: '₱${order.total.toStringAsFixed(0)}', isBold: true),
          const SizedBox(height: AppSpacing.xl),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.print_rounded),
            label: const Text('Re-print Receipt'),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.email_outlined),
            label: const Text('Send Digital Receipt'),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: status.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(status.label.toUpperCase(), style: AppTextStyles.labelMd.copyWith(color: status.color, letterSpacing: 1.2)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTextStyles.labelMd),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool isBold;
  const _SummaryRow({required this.label, required this.value, this.color, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isBold ? AppTextStyles.labelLg : AppTextStyles.bodyMd),
          Text(value, style: (isBold ? AppTextStyles.labelLg : AppTextStyles.bodyMd).copyWith(color: color)),
        ],
      ),
    );
  }
}
