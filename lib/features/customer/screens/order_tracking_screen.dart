import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/order.dart';
import '../../../data/repositories/orders_repository.dart';
import 'order_details_screen.dart';

/// Live order tracking — ETA banner, a simple decorative route panel, real
/// order timeline, and rider info. The order's status/timeline come from
/// Supabase and update live via realtime — there's no real GPS/maps
/// package, so the route panel is clearly labeled as a preview, not a live
/// map.
class OrderTrackingScreen extends StatefulWidget {
  final Order order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late Order _order;
  Stream<List<Map<String, dynamic>>>? _stream;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _stream = OrdersRepository.instance.watchOrder(_order.id);
  }

  Future<void> _refetch() async {
    try {
      final updated = await OrdersRepository.instance.refetch(_order.id);
      if (mounted) setState(() => _order = updated);
    } catch (_) {
      // Keep showing the last known state; the stream will retry.
    }
  }

  double _progressFor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0.1;
      case OrderStatus.confirmed:
        return 0.3;
      case OrderStatus.preparing:
        return 0.55;
      case OrderStatus.outForDelivery:
        return 0.85;
      case OrderStatus.completed:
        return 1.0;
      case OrderStatus.cancelled:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final rows = snapshot.data!;
          if (rows.isNotEmpty && rows.first['status'] != _order.status.name) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _refetch());
          }
        }
        return _buildScaffold(context);
      },
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final order = _order;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        leading: const BackButton(),
        title: Column(
          children: [
            Text('MELAI NUTS DELIVERY', style: AppTextStyles.labelSm),
            Text('Track Order ${order.id}', style: AppTextStyles.titleMd),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warningBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '● ${order.status.label}',
                          style: AppTextStyles.labelMd.copyWith(color: AppColors.warning),
                        ),
                      ),
                      Text(order.branch, style: AppTextStyles.bodySm),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ETA ${order.etaLabel ?? '—'}',
                    style: AppTextStyles.headlineLg.copyWith(color: AppColors.primary),
                  ),
                  Text(
                    order.isDelivery ? 'Delivery order' : 'Pickup order',
                    style: AppTextStyles.bodySm,
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _progressFor(order.status),
                      minHeight: 6,
                      backgroundColor: AppColors.border,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const _RouteMapPlaceholder(),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Order Timeline', style: AppTextStyles.titleMd),
                      Text('Tracking verified', style: AppTextStyles.bodySm),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (int i = 0; i < order.timeline.length; i++)
                    _TimelineRow(
                      step: order.timeline[i],
                      isLast: i == order.timeline.length - 1,
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (order.riderName != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primaryContainer,
                      child: Icon(Icons.person, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.riderName!, style: AppTextStyles.titleMd),
                          Text('Melai Laguna Fleet', style: AppTextStyles.bodySm),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Rider messaging isn't available yet.")),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                    ),
                    IconButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Rider calling isn't available yet.")),
                      ),
                      icon: const Icon(Icons.call_outlined),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.darkBrown),
                      const SizedBox(width: 8),
                      Text('Package Manifest', style: AppTextStyles.titleMd),
                      const Spacer(),
                      Text('${order.itemCount} Items', style: AppTextStyles.bodySm),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (final item in order.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 6, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${item.productName} (${item.variantLabel})',
                              style: AppTextStyles.bodyMd,
                            ),
                          ),
                          Text('${item.quantity}x', style: AppTextStyles.bodySm),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order)),
              ),
              icon: const Icon(Icons.receipt_long_outlined, size: 18),
              label: const Text('View Order Details & Receipt'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteMapPlaceholder extends StatelessWidget {
  const _RouteMapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _DottedRoutePainter()),
          ),
          const Positioned(
            left: 4,
            bottom: 4,
            child: _MapPin(icon: Icons.storefront_rounded, label: 'Branch'),
          ),
          const Positioned(
            right: 4,
            top: 4,
            child: _MapPin(icon: Icons.home_rounded, label: 'You'),
          ),
          const Align(
            alignment: Alignment.center,
            child: _MapPin(icon: Icons.local_shipping_rounded, label: 'Van', filled: true),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)),
              child: const Text('ROUTE PREVIEW', style: TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;

  const _MapPin({required this.icon, required this.label, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: filled ? AppColors.primary : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary),
          ),
          child: Icon(icon, size: 16, color: filled ? Colors.white : AppColors.primary),
        ),
        Text(label, style: AppTextStyles.bodySm),
      ],
    );
  }
}

class _DottedRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(16, size.height - 24)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.3, size.width - 24, 20);

    const dashWidth = 6.0;
    const dashSpace = 5.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TimelineRow extends StatelessWidget {
  final OrderTimelineStep step;
  final bool isLast;

  const _TimelineRow({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final color = step.done
        ? AppColors.success
        : step.current
        ? AppColors.primary
        : AppColors.border;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(
                  step.done
                      ? Icons.check
                      : step.current
                      ? Icons.local_shipping_rounded
                      : Icons.circle,
                  size: 13,
                  color: Colors.white,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: AppColors.border),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.label,
                          style: AppTextStyles.labelLg.copyWith(
                            color: step.current ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                        Text(step.description, style: AppTextStyles.bodySm),
                      ],
                    ),
                  ),
                  Text(step.time, style: AppTextStyles.bodySm),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
