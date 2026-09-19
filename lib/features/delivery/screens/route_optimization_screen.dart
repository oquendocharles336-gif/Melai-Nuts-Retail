import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/dummy_data/dummy_deliveries.dart';
import '../../../data/models/delivery.dart';

/// Route Optimization — shows the simulated optimized stop sequence:
///
///   Branch
///     ↓
///   Customer A
///     ↓
///   Customer C
///     ↓
///   Customer B
///
/// with per-leg distance/time/ETA and a running total, plus a link to the
/// visual route map. Frontend simulation only — no real routing engine.
class RouteOptimizationScreen extends StatelessWidget {
  final Delivery delivery;

  RouteOptimizationScreen({super.key, Delivery? delivery}) : delivery = delivery ?? kDeliveries.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: MelaiAppBar(
        title: 'Route Optimization',
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'View Map',
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.routeMap, arguments: delivery),
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
                color: AppColors.successBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: AppColors.success),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Simulated route optimized for ${delivery.stops.length} stops. Sequence below reflects the shortest simulated path.',
                      style: AppTextStyles.bodyMd,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSpacing.radiusMd), border: Border.all(color: AppColors.border), boxShadow: AppShadows.sm),
              child: Row(
                children: [
                  Expanded(child: _SummaryStat(label: 'Total Distance', value: '${delivery.totalDistanceKm.toStringAsFixed(1)} km')),
                  Expanded(child: _SummaryStat(label: 'Total Time', value: '${delivery.totalTimeMinutes} min')),
                  Expanded(child: _SummaryStat(label: 'Stops', value: '${delivery.stops.length}')),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Optimized Stop Sequence', style: AppTextStyles.headlineSm),
            const SizedBox(height: AppSpacing.sm),
            _SequenceNode(
              icon: Icons.storefront_rounded,
              iconColor: AppColors.roleOwner,
              title: delivery.branch,
              subtitle: 'Dispatch origin • ${delivery.vehicle} • ${delivery.riderName}',
              isFirst: true,
              isLast: false,
            ),
            for (int i = 0; i < delivery.stops.length; i++)
              _SequenceNode(
                icon: Icons.location_on_rounded,
                iconColor: delivery.stops[i].status.color,
                title: delivery.stops[i].customerName,
                subtitle: delivery.stops[i].address,
                distanceLabel: '${delivery.stops[i].distanceFromPreviousKm.toStringAsFixed(1)} km • ${delivery.stops[i].travelMinutesFromPrevious} min',
                etaLabel: 'ETA ${delivery.stops[i].eta}',
                statusLabel: delivery.stops[i].status.label,
                statusColor: delivery.stops[i].status.color,
                isFirst: false,
                isLast: i == delivery.stops.length - 1,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.deliveryManifest, arguments: delivery),
              ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.routeMap, arguments: delivery),
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: const Text('View on Map'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.deliveryManifest, arguments: delivery),
                    icon: const Icon(Icons.checklist_rounded, size: 16),
                    label: const Text('Manifest'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Confirm & Dispatch',
              icon: Icons.local_shipping_outlined,
              onPressed: () {
                delivery.status = DeliveryStatus.dispatched;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Simulated: ${delivery.id} dispatched to ${delivery.riderName}.')),
                );
                Navigator.of(context).pushReplacementNamed(AppRoutes.deliveryDetails, arguments: delivery);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySm),
        Text(value, style: AppTextStyles.titleMd),
      ],
    );
  }
}

class _SequenceNode extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? distanceLabel;
  final String? etaLabel;
  final String? statusLabel;
  final Color? statusColor;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  const _SequenceNode({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.distanceLabel,
    this.etaLabel,
    this.statusLabel,
    this.statusColor,
    required this.isFirst,
    required this.isLast,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                if (!isFirst)
                  Container(width: 2, height: 16, color: AppColors.border),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: Icon(icon, size: 16, color: iconColor),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: AppColors.border)),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: 16, top: isFirst ? 0 : 8),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSpacing.radiusMd), border: Border.all(color: AppColors.border), boxShadow: AppShadows.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(title, style: AppTextStyles.labelLg)),
                          if (statusLabel != null)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: (statusColor ?? AppColors.textSecondary).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                              child: Text(statusLabel!, style: AppTextStyles.labelSm.copyWith(color: statusColor)),
                            ),
                        ],
                      ),
                      Text(subtitle, style: AppTextStyles.bodySm),
                      if (distanceLabel != null || etaLabel != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (distanceLabel != null) Text(distanceLabel!, style: AppTextStyles.bodySm),
                            if (etaLabel != null) Text(etaLabel!, style: AppTextStyles.labelMd.copyWith(color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
