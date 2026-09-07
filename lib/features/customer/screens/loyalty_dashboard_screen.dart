import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/dummy_data/dummy_loyalty.dart';
import '../../../data/models/loyalty.dart';
import '../widgets/loyalty_points_card.dart';

class LoyaltyDashboardScreen extends StatelessWidget {
  const LoyaltyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Loyalty Program'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LoyaltyPointsCard(
              points: 1250,
              status: 'Golden Kernel Member',
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildQuickActions(context),
            const SizedBox(height: AppSpacing.lg),
            _buildSectionHeader(
              context,
              'Recent Activity',
              () => Navigator.pushNamed(context, '/customer/loyalty/history'),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildRecentActivityList(),
            const SizedBox(height: AppSpacing.lg),
            _buildRfidPromotion(context),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.redeem,
            label: 'Redeem Rewards',
            onTap: () => Navigator.pushNamed(context, '/customer/loyalty/redeem'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _ActionCard(
            icon: Icons.history,
            label: 'Points History',
            onTap: () => Navigator.pushNamed(context, '/customer/loyalty/history'),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.headlineSm),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            'See All',
            style: AppTextStyles.labelLg.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivityList() {
    final recent = dummyLoyaltyTransactions.take(3).toList();
    return Column(
      children: recent.map((tx) => _buildActivityTile(tx)).toList(),
    );
  }

  Widget _buildActivityTile(LoyaltyPointTransaction tx) {
    final isEarn = tx.type == LoyaltyTransactionType.earn;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppShadows.sm,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isEarn ? AppColors.successBg : AppColors.errorBg,
          child: Icon(
            isEarn ? Icons.add : Icons.remove,
            color: isEarn ? AppColors.success : AppColors.error,
          ),
        ),
        title: Text(tx.description, style: AppTextStyles.titleMd),
        subtitle: Text(
          '${tx.date.day}/${tx.date.month}/${tx.date.year}',
          style: AppTextStyles.bodySm,
        ),
        trailing: Text(
          '${isEarn ? '+' : '-'}${tx.points}',
          style: AppTextStyles.labelLg.copyWith(
            color: isEarn ? AppColors.success : AppColors.error,
          ),
        ),
        onTap: () {}, // Navigate to transaction details
      ),
    );
  }

  Widget _buildRfidPromotion(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          const Icon(Icons.contactless, size: 48, color: AppColors.primary),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Fast Tap Loyalty',
            style: AppTextStyles.headlineSm,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tap your Melai RFID card at our physical stores to earn points instantly!',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd,
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/customer/loyalty/rfid-tap'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
            child: const Text('Try Demo RFID Tap'),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: AppSpacing.sm),
            Text(label, style: AppTextStyles.labelLg),
          ],
        ),
      ),
    );
  }
}
