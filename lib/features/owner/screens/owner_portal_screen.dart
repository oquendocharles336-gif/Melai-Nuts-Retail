import 'package:flutter/material.dart';
import '../../../core/widgets/portal_placeholder_screen.dart';
import '../../../data/models/user_role.dart';

/// Owner portal entry point. Business overview, analytics, and multi-branch
/// management screens are implemented in a later batch.
class OwnerPortalScreen extends StatelessWidget {
  const OwnerPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PortalPlaceholderScreen(
      role: UserRole.owner,
      upcomingFeatures: [
        'Business & sales overview',
        'Branch comparison & performance',
        'Inventory & FEFO oversight',
        'Delivery & route optimization',
      ],
    );
  }
}
