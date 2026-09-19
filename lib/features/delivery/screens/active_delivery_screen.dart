import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/dummy_data/dummy_deliveries.dart';
import '../../../data/models/delivery.dart';

/// The rider's "control center" for a delivery that's already in
/// progress — current status, next stop preview, and quick access into
/// GPS Tracking, Next Stop, Route Details, and overall Progress.
///
/// Reached when a rider taps an already-started delivery from Assigned
/// Deliveries (a not-yet-started delivery goes to Delivery Details →
/// Optimized Route → Start Delivery instead).
class ActiveDeliveryScreen extends StatelessWidget {
  final Delivery delivery;

  ActiveDeliveryScreen({super.key, Delivery? delivery}) : delivery = delivery ?? kDeliveries.first;

  @override
  Widget build(BuildContext context) {
    final nextStop = delivery.stops.where((s) => s.status == StopStatus.pending || s.status == StopStatus.enRoute).toList();
    final progress = delivery.stops.isEmpty ? 0.0 : delivery.deliveredCount / delivery.stops.length;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: Text('Active: ${delivery.id}')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.roleDelivery, borderRadius: BorderRadius.circular(20), boxShadow: AppShadows.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(delivery.status.label.toUpperCase(), style: AppTextStyles.labelSm.copyWith(color: Colors.white70)),
                      const Icon(Icons.local_shipping_rounded, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('${delivery.deliveredCount} of ${delivery.stops.length} stops delivered', style: AppTextStyles.headlineSm.copyWith(color: Colors.white)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: Colors.white24, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (nextStop.isNotEmpty) ...[
              Text('Next Stop', style: AppTextStyles.headlineSm),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSpacing.radiusMd), border: Border.all(color: AppColors.border), boxShadow: AppShadows.sm),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nextStop.first.customerName, style: AppTextStyles.labelLg, maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('${nextStop.first.distanceFromPreviousKm.toStringAsFixed(1)} km • ETA ${nextStop.first.eta}', style: AppTextStyles.bodySm),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            Text('Quick Actions', style: AppTextStyles.headlineSm),
            const SizedBox(height: AppSpacing.sm),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.6,
              children: [
                _ActionTile(
                  icon: Icons.gps_fixed_rounded,
                  label: 'GPS Tracking',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.gpsTracking, arguments: delivery),
                ),
                _ActionTile(
                  icon: Icons.arrow_forward_rounded,
                  label: 'Next Stop',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.deliveryNextStop, arguments: delivery),
                ),
                _ActionTile(
                  icon: Icons.alt_route_rounded,
                  label: 'Route Details',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.deliveryRouteDetails, arguments: delivery),
                ),
                _ActionTile(
                  icon: Icons.checklist_rounded,
                  label: 'Progress',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.deliveryProgress, arguments: delivery),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('All Stops', style: AppTextStyles.headlineSm),
            const SizedBox(height: AppSpacing.sm),
            for (int i = 0; i < delivery.stops.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSpacing.radiusMd), border: Border.all(color: AppColors.border)),
                  child: Row(
                    children: [
                      Icon(
                        delivery.stops[i].status == StopStatus.delivered ? Icons.check_circle : Icons.radio_button_unchecked,
                        size: 16,
                        color: delivery.stops[i].status.color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text('${i + 1}. ${delivery.stops[i].customerName}', style: AppTextStyles.bodyMd, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Text(delivery.stops[i].status.label, style: AppTextStyles.labelSm.copyWith(color: delivery.stops[i].status.color)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(AppSpacing.radiusMd), border: Border.all(color: AppColors.border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.roleDelivery),
            const Spacer(),
            Text(label, style: AppTextStyles.labelLg),
          ],
        ),
      ),
    );
  }
}
