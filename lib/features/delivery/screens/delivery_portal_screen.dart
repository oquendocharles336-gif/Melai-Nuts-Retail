import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/dummy_data/dummy_orders.dart';
import '../../../data/models/order.dart';

/// Delivery Personnel Portal — Assigned routes, optimized GPS navigation
/// simulation, and delivery confirmation in a single-file shell.
class DeliveryPortalScreen extends StatefulWidget {
  const DeliveryPortalScreen({super.key});

  @override
  State<DeliveryPortalScreen> createState() => _DeliveryPortalScreenState();
}

class _DeliveryPortalScreenState extends State<DeliveryPortalScreen> {
  int _currentIndex = 0;

  void _logout() {
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.roleDelivery,
              child: Icon(Icons.local_shipping_rounded, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rider Portal', style: AppTextStyles.labelLg),
                Text('Vehicle: Laguna-Van-04', style: AppTextStyles.bodySm),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.logout_rounded), onPressed: _logout),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _MyRouteTab(),
          _DeliveryHistoryTab(),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: AppColors.roleDelivery.withValues(alpha: 0.15),
          surfaceTintColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTextStyles.labelMd.copyWith(color: AppColors.roleDelivery);
            }
            return AppTextStyles.labelMd;
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.route_outlined),
              selectedIcon: Icon(Icons.route_rounded, color: AppColors.roleDelivery),
              label: 'My Route',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_rounded),
              selectedIcon: Icon(Icons.history_rounded, color: AppColors.roleDelivery),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}

class _MyRouteTab extends StatelessWidget {
  const _MyRouteTab();

  @override
  Widget build(BuildContext context) {
    final activeItems = kOrders.where((o) => o.status == OrderStatus.outForDelivery).toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _buildFleetStatusCard(),
        const SizedBox(height: AppSpacing.lg),
        Text('Active Assigned Deliveries', style: AppTextStyles.titleMd),
        const SizedBox(height: AppSpacing.sm),
        if (activeItems.isEmpty)
          const Center(child: Text('No active deliveries assigned.'))
        else
          ...activeItems.map((o) => _buildDeliveryCard(context, o)),
      ],
    );
  }

  Widget _buildFleetStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.roleDelivery,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ROUTING ENGINE ACTIVE', style: AppTextStyles.labelSm.copyWith(color: Colors.white70)),
              const Icon(Icons.gps_fixed_rounded, color: Colors.white, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text('8 Drops Optimized', style: AppTextStyles.headlineSm.copyWith(color: Colors.white)),
          Text('Next stop: Calamba Residence Area', style: AppTextStyles.bodySm.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(BuildContext context, Order o) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border), boxShadow: AppShadows.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(o.id, style: AppTextStyles.labelLg),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(20)), child: Text('Priority', style: AppTextStyles.labelSm.copyWith(color: AppColors.success))),
            ],
          ),
          const SizedBox(height: 10),
          Text('Elena Dimaculangan', style: AppTextStyles.titleMd),
          Text('Unit 4B, Lakeside Residences, Calamba, Laguna', style: AppTextStyles.bodySm),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.navigation_rounded, size: 18), label: const Text('Navigate'))),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.check_circle_outline_rounded, size: 18), label: const Text('Complete'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.success))),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeliveryHistoryTab extends StatelessWidget {
  const _DeliveryHistoryTab();

  @override
  Widget build(BuildContext context) {
    final completed = kOrders.where((o) => o.status == OrderStatus.completed).toList();
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: completed.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final o = completed[i];
        return ListTile(
          leading: const Icon(Icons.history_rounded, color: AppColors.textSecondary),
          title: Text(o.id, style: AppTextStyles.labelLg),
          subtitle: Text('Completed at 2:45 PM • Santa Cruz', style: AppTextStyles.bodySm),
          trailing: const Icon(Icons.chevron_right_rounded),
        );
      },
    );
  }
}
