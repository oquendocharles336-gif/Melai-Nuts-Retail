import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/dummy_data/dummy_sales.dart';
import '../widgets/branch_performance_card.dart';
import 'owner_dashboard_screen.dart';

/// Owner Executive Dashboard — Sales analytics, multi-branch comparisons,
/// and total oversight in a single-file shell.
class OwnerPortalScreen extends StatefulWidget {
  const OwnerPortalScreen({super.key});

  @override
  State<OwnerPortalScreen> createState() => _OwnerPortalScreenState();
}

class _OwnerPortalScreenState extends State<OwnerPortalScreen> {
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
              backgroundColor: AppColors.roleOwner,
              child: Icon(Icons.insights_rounded, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Owner Dashboard', style: AppTextStyles.labelLg),
                Text('Laguna Enterprise Overview', style: AppTextStyles.bodySm),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.productManagement),
            tooltip: 'Product & Pricing Hub',
          ),
          IconButton(
            icon: const Icon(Icons.manage_accounts_rounded),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.ownerUserManagement),
            tooltip: 'Manage Users',
          ),
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.logout_rounded), onPressed: _logout),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          OwnerDashboardScreen(),
          _BranchComparisonTab(),
          _SystemLogsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: AppColors.roleOwner.withValues(alpha: 0.15),
          surfaceTintColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTextStyles.labelMd.copyWith(color: AppColors.roleOwner);
            }
            return AppTextStyles.labelMd;
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.roleOwner),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.compare_arrows_rounded),
              selectedIcon: Icon(Icons.compare_arrows_rounded, color: AppColors.roleOwner),
              label: 'Branches',
            ),
            NavigationDestination(
              icon: Icon(Icons.security_rounded),
              selectedIcon: Icon(Icons.security_rounded, color: AppColors.roleOwner),
              label: 'Security',
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchComparisonTab extends StatelessWidget {
  const _BranchComparisonTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Branch Operations', style: AppTextStyles.headlineSm),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.ownerBranchComparison),
              child: const Text('Full Comparison'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final sales in kBranchSalesList)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: BranchPerformanceCard(
              sales: sales,
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.ownerBranchPerformance, arguments: sales.branch),
            ),
          ),
      ],
    );
  }
}

class _SystemLogsTab extends StatelessWidget {
  const _SystemLogsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text('Enterprise Audit Logs', style: AppTextStyles.labelSm),
        const SizedBox(height: 10),
        _buildLogTile('POS Login', 'Manager Elena (Calamba)', '10:24 AM'),
        _buildLogTile('Inventory Adjustment', 'Staff Juan (Santa Cruz)', '09:15 AM'),
        _buildLogTile('Price Update', 'System Automate (HQ)', '08:00 AM'),
      ],
    );
  }

  Widget _buildLogTile(String action, String user, String time) {
    return ListTile(
      leading: const Icon(Icons.history_toggle_off_rounded, size: 20),
      title: Text(action, style: AppTextStyles.labelLg),
      subtitle: Text(user, style: AppTextStyles.bodySm),
      trailing: Text(time, style: AppTextStyles.bodySm),
    );
  }
}
