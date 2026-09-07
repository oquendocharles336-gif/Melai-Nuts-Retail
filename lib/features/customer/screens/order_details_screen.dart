import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/dummy_data/dummy_orders.dart';
import '../../../data/models/order.dart';
import '../widgets/order_status_badge.dart';
import 'repeat_order_screen.dart';

/// Full order receipt — items, per-item "Reorder SKU", billing summary,
/// branch info, and "Repeat Entire Order" (matches the prototype's Order
/// Details / Reorder screen).
class OrderDetailsScreen extends StatelessWidget {
  final Order order;

  OrderDetailsScreen({super.key, Order? order}) : order = order ?? kOrders.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: MelaiAppBar(
        title: 'Order ${order.id}',
        showBack: true,
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OrderStatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              order.isDelivery ? 'Delivery Order' : 'Pickup Order',
              style: AppTextStyles.headlineMd.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
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
                  _InfoRow(label: 'Placed on', value: _formatDate(order.date)),
                  _InfoRow(
                    label: 'Fulfillment Mode',
                    value: order.isDelivery ? 'Home delivery from ${order.branch}' : 'Picked up at ${order.branch}',
                  ),
                  _InfoRow(label: 'Payment Method', value: order.paymentMethod),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order Manifest', style: AppTextStyles.titleMd),
                Text('${order.items.length} SKUs • ${order.itemCount} units', style: AppTextStyles.bodySm),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final item in order.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.productName, style: AppTextStyles.labelLg),
                                Text(item.variantLabel, style: AppTextStyles.bodySm),
                                Text(
                                  'Qty: ${item.quantity} • ₱${item.unitPrice.toStringAsFixed(0)} each',
                                  style: AppTextStyles.bodySm,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₱${item.total.toStringAsFixed(0)}',
                            style: AppTextStyles.titleMd.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Simulated reorder of ${item.productName}')),
                          ),
                          icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                          label: const Text('Reorder SKU'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Billing & Payment Summary', style: AppTextStyles.titleMd),
                  const SizedBox(height: 10),
                  _SummaryLine('Subtotal', '₱${order.subtotal.toStringAsFixed(0)}'),
                  _SummaryLine(
                    'Delivery / Fulfillment',
                    order.deliveryFee == 0
                        ? '₱0.00 (Store Pickup)'
                        : '₱${order.deliveryFee.toStringAsFixed(0)}',
                    color: AppColors.success,
                  ),
                  if (order.discount > 0)
                    _SummaryLine('Discount', '-₱${order.discount.toStringAsFixed(0)}', color: AppColors.success),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Paid', style: AppTextStyles.headlineSm),
                      Text(
                        '₱${order.total.toStringAsFixed(0)}',
                        style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                  if (order.pointsEarned > 0) ...[
                    const SizedBox(height: 6),
                    Text('+${order.pointsEarned} Golden Kernel Points credited', style: AppTextStyles.bodySm),
                  ],
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
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.storefront_outlined, color: AppColors.darkBrown),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Melai Nuts ${order.branch}', style: AppTextStyles.labelLg),
                        Text('Laguna, Philippines', style: AppTextStyles.bodySm),
                      ],
                    ),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Get Directions')),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Repeat Entire Order (${order.items.length} items • ₱${order.total.toStringAsFixed(0)})',
              icon: Icons.replay_rounded,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => RepeatOrderScreen(order: order)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    final minute = d.minute.toString().padLeft(2, '0');
    return '${months[d.month - 1]} ${d.day}, ${d.year} at $hour:$minute $ampm';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: AppTextStyles.bodySm)),
          Expanded(child: Text(value, style: AppTextStyles.labelLg)),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _SummaryLine(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMd),
          Text(value, style: AppTextStyles.bodyMd.copyWith(color: color)),
        ],
      ),
    );
  }
}
