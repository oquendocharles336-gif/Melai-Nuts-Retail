import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class RfidTapScreen extends StatefulWidget {
  const RfidTapScreen({super.key});

  @override
  State<RfidTapScreen> createState() => _RfidTapScreenState();
}

class _RfidTapScreenState extends State<RfidTapScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Simulate auto-detection after 3 seconds
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
      appBar: AppBar(
        title: const Text('Tap RFID Card'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _animation,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.contactless,
                    size: 80,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl2),
              Text(
                'Ready to Scan',
                style: AppTextStyles.headlineMd,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Hold your Melai physical loyalty card near the back of your phone to sync points.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd,
              ),
              const SizedBox(height: AppSpacing.xl),
              const CircularProgressIndicator(strokeWidth: 3),
              const SizedBox(height: AppSpacing.md),
              Text('Searching for RFID card...', style: AppTextStyles.labelMd.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.xl2),
              OutlinedButton.icon(
                onPressed: () => Navigator.pushReplacementNamed(context, '/customer/loyalty/rfid-detected'),
                icon: const Icon(Icons.touch_app_rounded, size: 18),
                label: const Text('Simulate Manual Tap'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
