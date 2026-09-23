import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/dummy_data/dummy_loyalty.dart';
import '../../../data/models/loyalty.dart';

class LoyaltyHistoryScreen extends StatelessWidget {
  const LoyaltyHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Points History'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: dummyLoyaltyTransactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('No history yet.', style: AppTextStyles.headlineSm.copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  Text('Your points activity will appear here.', style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: dummyLoyaltyTransactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final tx = dummyLoyaltyTransactions[index];
                final isEarn = tx.type == LoyaltyTransactionType.earn;

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.border),
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
                      '${tx.date.day}/${tx.date.month}/${tx.date.year} • ${tx.date.hour}:${tx.date.minute}',
                      style: AppTextStyles.bodySm,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isEarn ? '+' : '-'}${tx.points}',
                          style: AppTextStyles.labelLg.copyWith(
                            color: isEarn ? AppColors.success : AppColors.error,
                          ),
                        ),
                        Text(
                          'Points',
                          style: AppTextStyles.labelSm,
                        ),
                      ],
                    ),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/customer/loyalty/transaction',
                      arguments: tx,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
