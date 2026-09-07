import 'package:flutter/material.dart';
import '../../../core/widgets/portal_placeholder_screen.dart';
import '../../../data/models/user_role.dart';

/// Customer portal entry point. Full storefront, cart, orders, and loyalty
/// screens are implemented in a later batch (see project flowchart).
class CustomerPortalScreen extends StatelessWidget {
  const CustomerPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PortalPlaceholderScreen(
      role: UserRole.customer,
      upcomingFeatures: [
        'Product catalog & categories',
        'Shopping cart & checkout',
        'Order tracking & history',
        'RFID loyalty & rewards',
      ],
    );
  }
}
