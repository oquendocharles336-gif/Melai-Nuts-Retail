import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Thin, honest "you're offline" strip. Shown only while
/// [ConnectivityService] reports no network path — never a guess from a
/// single failed request, and never shown just because one screen's fetch
/// was slow. Wrap any customer screen's body in this (see
/// `CustomerPortalScreen`) so stale/cached data on screen is never
/// mistaken for current.
class OfflineBanner extends StatelessWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ConnectivityService.instance,
      builder: (context, _) {
        final isOnline = ConnectivityService.instance.isOnline;
        return Column(
          children: [
            if (!isOnline)
              Container(
                width: double.infinity,
                color: AppColors.textMuted,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off_rounded, size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        'You\'re offline — showing the last saved data. Orders and payments cannot be placed right now.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelSm.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}
