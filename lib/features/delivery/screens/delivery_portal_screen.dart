import 'package:flutter/material.dart';
import '../../../core/widgets/portal_placeholder_screen.dart';
import '../../../data/models/user_role.dart';

/// Delivery Personnel portal entry point. Route optimization and live
/// tracking screens are implemented in a later batch.
class DeliveryPortalScreen extends StatelessWidget {
  const DeliveryPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PortalPlaceholderScreen(
      role: UserRole.delivery,
      upcomingFeatures: [
        'Assigned deliveries',
        'Optimized route & GPS tracking',
        'Delivery confirmation & sign-off',
        'Delivery history',
      ],
    );
  }
}
