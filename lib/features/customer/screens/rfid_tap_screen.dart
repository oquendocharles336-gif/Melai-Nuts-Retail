import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../core/widgets/info_banner.dart';
import '../../../core/widgets/secondary_button.dart';

/// "Tap your Melai Nuts Loyalty Card" — simulated in-store RFID tap.
/// Matches the prototype's Tap Loyalty Card screen: a stylized membership
/// card over an "NFC PAD", reader diagnostics, and a manual simulate button.
class RfidTapScreen extends StatefulWidget {
  const RfidTapScreen({super.key});

  @override
  State<RfidTapScreen> createState() => _RfidTapScreenState();
}

class _RfidTapScreenState extends State<RfidTapScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<double> _animation = Tween<double>(begin: 0.97, end: 1.03).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/customer/loyalty/rfid-detected');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: MelaiAppBar(
        title: 'Golden Kernel Club',
        showBack: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('1,450 pts', style: AppTextStyles.labelMd.copyWith(color: AppColors.primaryDark)),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Santa Cruz Main • Counter Terminal #02', style: AppTextStyles.bodySm),
                  ),
                  const Icon(Icons.wifi_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('Online', style: AppTextStyles.bodySm),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              height: 260,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.border),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ScaleTransition(
                    scale: _animation,
                    child: Container(
                      width: 220,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.darkBrown, AppColors.primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppShadows.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'MELAI GOLDEN KERNEL',
                                style: AppTextStyles.labelSm.copyWith(color: Colors.white),
                              ),
                              const Icon(Icons.contactless_rounded, size: 16, color: Colors.white),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Container(
                                width: 26,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('•••• 4892', style: AppTextStyles.labelLg.copyWith(color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text('CLUB TIER MEMBER', style: AppTextStyles.labelSm.copyWith(color: Colors.white70)),
                          Text('MARIA CLARA S.', style: AppTextStyles.labelLg.copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.contactless_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text('NFC PAD', style: AppTextStyles.labelMd),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '📡 In-Store RFID Loyalty Tap',
                  style: AppTextStyles.labelMd.copyWith(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tap your Melai Nuts Loyalty Card',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMd,
            ),
            const SizedBox(height: 8),
            Text(
              'Hold your physical Golden Kernel Club card against the contactless NFC/RFID reader pad at any Melai Laguna counter.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd,
            ),
            const SizedBox(height: AppSpacing.md),
            const InfoBanner(
              icon: Icons.vpn_key_outlined,
              title: 'Seamless Pre-linked Verification',
              text: 'Your card is pre-linked to your account. No PIN or mobile phone required at checkout.',
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _StatTile(label: 'SPEED', value: '< 0.4s Tap Speed', icon: Icons.bolt_rounded),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(label: 'INSTANT PERK', value: '5% Snack Bonus', icon: Icons.card_giftcard_rounded),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text('Reader Diagnostics: ', style: AppTextStyles.bodySm),
                  Text('Ready / Listening', style: AppTextStyles.labelMd.copyWith(color: AppColors.success)),
                  const Spacer(),
                  Text('FREQ: 13.56MHz', style: AppTextStyles.bodySm),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              label: 'Simulate Customer Tap',
              icon: Icons.contactless_rounded,
              onPressed: () => Navigator.pushReplacementNamed(context, '/customer/loyalty/rfid-detected'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.labelSm),
                Text(value, style: AppTextStyles.labelMd),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
