import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// The four major roles/portals of the Melai Nuts app.
enum UserRole { customer, staff, owner, delivery }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.staff:
        return 'Branch Staff';
      case UserRole.owner:
        return 'Owner';
      case UserRole.delivery:
        return 'Delivery Personnel';
    }
  }

  String get shortLabel {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.staff:
        return 'Staff';
      case UserRole.owner:
        return 'Owner';
      case UserRole.delivery:
        return 'Delivery';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.customer:
        return Icons.storefront_rounded;
      case UserRole.staff:
        return Icons.badge_rounded;
      case UserRole.owner:
        return Icons.workspace_premium_rounded;
      case UserRole.delivery:
        return Icons.local_shipping_rounded;
    }
  }

  Color get color {
    switch (this) {
      case UserRole.customer:
        return AppColors.roleCustomer;
      case UserRole.staff:
        return AppColors.roleStaff;
      case UserRole.owner:
        return AppColors.roleOwner;
      case UserRole.delivery:
        return AppColors.roleDelivery;
    }
  }
}
