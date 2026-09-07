import 'package:flutter/material.dart';
import '../../../core/widgets/portal_placeholder_screen.dart';
import '../../../data/models/user_role.dart';

/// Branch Staff portal entry point. POS, transactions, inventory, and sales
/// screens are implemented in a later batch.
class StaffPortalScreen extends StatelessWidget {
  const StaffPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PortalPlaceholderScreen(
      role: UserRole.staff,
      upcomingFeatures: [
        'POS register & catalog',
        'Transactions & receipts',
        'Branch inventory & FEFO',
        'Daily sales reports',
      ],
    );
  }
}
