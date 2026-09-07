import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

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
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.logout_rounded), onPressed: _logout),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _AnalyticsTab(),
          _BranchComparisonTab(),
          _SystemLogsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: AppColors.roleOwner.withValues(alpha: 0.15),
          surfaceTintColor: Colors.transparent,
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
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
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics_rounded, color: AppColors.roleOwner),
              label: 'Analytics',
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

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _buildSummaryCard(),
        const SizedBox(height: AppSpacing.lg),
        Text('Revenue Trends', style: AppTextStyles.titleMd),
        const SizedBox(height: AppSpacing.sm),
        _buildChartPlaceholder(),
        const SizedBox(height: AppSpacing.lg),
        Text('Top Performing SKUs', style: AppTextStyles.titleMd),
        const SizedBox(height: AppSpacing.sm),
        _buildTopProduct('Garlic Peanuts', '₱124,500', 0.85),
        _buildTopProduct('Spicy Skinless', '₱82,200', 0.62),
        _buildTopProduct('Mixed Nuts Blend', '₱45,100', 0.35),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.roleOwner, AppColors.secondaryBrown]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TOTAL REVENUE (OCT)', style: AppTextStyles.labelSm.copyWith(color: Colors.white70)),
          const SizedBox(height: 6),
          Text('₱482,910.50', style: AppTextStyles.headlineLg.copyWith(color: Colors.white, fontSize: 32)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.trending_up_rounded, color: Colors.greenAccent, size: 20),
              const SizedBox(width: 6),
              Text('+12.4% from last month', style: AppTextStyles.bodySm.copyWith(color: Colors.greenAccent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartPlaceholder() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bar_chart_rounded, size: 48, color: AppColors.primaryContainer),
            Text('Live Revenue Chart Simulation', style: AppTextStyles.bodySm),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProduct(String name, String rev, double val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border), boxShadow: AppShadows.sm),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: AppTextStyles.labelLg),
                Text(rev, style: AppTextStyles.labelLg.copyWith(color: AppColors.roleOwner)),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: val, backgroundColor: AppColors.border, color: AppColors.roleOwner, minHeight: 6, borderRadius: BorderRadius.circular(3)),
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
        _buildBranchCard('Santa Cruz Main', '₱210.4k', '98% Stock', AppColors.success),
        _buildBranchCard('Calamba Branch', '₱154.2k', '82% Stock', AppColors.success),
        _buildBranchCard('Los Baños Hub', '₱118.3k', '14% Stock', AppColors.error),
      ],
    );
  }

  Widget _buildBranchCard(String name, String rev, String stock, Color stockColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border), boxShadow: AppShadows.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.titleMd),
                Text('Active Terminal: 02 • Laguna South', style: AppTextStyles.bodySm),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(rev, style: AppTextStyles.labelLg.copyWith(color: AppColors.roleOwner)),
              Text(stock, style: AppTextStyles.labelSm.copyWith(color: stockColor)),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
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
