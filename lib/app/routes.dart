import 'package:flutter/material.dart';

import '../data/models/user_role.dart';
import '../data/models/product.dart';
import '../data/models/order.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/customer_access_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/reset_password_screen.dart';
import '../features/auth/screens/password_reset_success_screen.dart';
import '../features/auth/screens/security_login_screen.dart';
import '../features/customer/screens/customer_portal_screen.dart';
import '../features/customer/screens/customer_home_screen.dart';
import '../features/customer/screens/product_catalog_screen.dart';
import '../features/customer/screens/product_categories_screen.dart';
import '../features/customer/screens/product_list_screen.dart';
import '../features/customer/screens/product_details_screen.dart';
import '../features/customer/screens/search_results_screen.dart';
import '../features/customer/screens/cart_screen.dart';
import '../features/customer/screens/checkout_screen.dart';
import '../features/customer/screens/order_confirmation_screen.dart';
import '../features/customer/screens/order_history_screen.dart';
import '../features/customer/screens/order_details_screen.dart';
import '../features/customer/screens/repeat_order_screen.dart';
import '../features/customer/screens/order_tracking_screen.dart';
import '../features/customer/screens/customer_profile_screen.dart';
import '../features/customer/screens/edit_profile_screen.dart';
import '../features/customer/screens/loyalty_dashboard_screen.dart';
import '../features/customer/screens/rfid_tap_screen.dart';
import '../features/customer/screens/rfid_detected_screen.dart';
import '../features/customer/screens/loyalty_history_screen.dart';
import '../features/customer/screens/redeem_rewards_screen.dart';
import '../features/customer/screens/loyalty_transaction_screen.dart';
import '../features/customer/screens/redemption_success_screen.dart';
import '../features/staff/screens/staff_portal_screen.dart';
import '../features/owner/screens/owner_portal_screen.dart';
import '../features/delivery/screens/delivery_portal_screen.dart';

/// Centralized route names. Keep every navigable screen registered here so
/// navigation logic never has to hard-code route strings in feature code.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String customerAccess = '/customer-access';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String resetSuccess = '/reset-success';
  static const String security = '/security';

  static const String customerHome = '/customer';
  static const String staffHome = '/staff';
  static const String ownerHome = '/owner';
  static const String deliveryHome = '/delivery';

  // Customer feature screens (see lib/features/customer/screens/).
  // Screens that take arguments (product/category/order) expose sensible
  // defaults so they also work when reached via Navigator.pushNamed; normal
  // in-app navigation instead pushes them directly with real data.
  static const String customerStore = '/customer/store';
  static const String customerCatalog = '/customer/catalog';
  static const String customerCategories = '/customer/categories';
  static const String customerProductList = '/customer/product-list';
  static const String customerProductDetails = '/customer/product-details';
  static const String customerSearch = '/customer/search';
  static const String customerCart = '/customer/cart';
  static const String customerCheckout = '/customer/checkout';
  static const String customerOrderConfirmation = '/customer/order-confirmation';
  static const String customerOrderHistory = '/customer/order-history';
  static const String customerOrderDetails = '/customer/order-details';
  static const String customerRepeatOrder = '/customer/repeat-order';
  static const String customerOrderTracking = '/customer/order-tracking';
  static const String customerProfile = '/customer/profile';
  static const String customerEditProfile = '/customer/edit-profile';

  static const String customerLoyaltyDashboard = '/customer/loyalty';
  static const String customerRfidTap = '/customer/loyalty/rfid-tap';
  static const String customerRfidDetected = '/customer/loyalty/rfid-detected';
  static const String customerLoyaltyTransaction = '/customer/loyalty/transaction';
  static const String customerLoyaltyHistory = '/customer/loyalty/history';
  static const String customerRedeemRewards = '/customer/loyalty/redeem';
  static const String customerRedemptionSuccess = '/customer/loyalty/redemption-success';

  /// Returns the portal route for a given role, used after successful
  /// sign-in (staff/owner/delivery) or account access (customer).
  static String homeFor(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return customerHome;
      case UserRole.staff:
        return staffHome;
      case UserRole.owner:
        return ownerHome;
      case UserRole.delivery:
        return deliveryHome;
    }
  }

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    customerAccess: (_) => const CustomerAccessScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    resetPassword: (_) => const ResetPasswordScreen(),
    resetSuccess: (_) => const PasswordResetSuccessScreen(),
    security: (_) => const SecurityLoginScreen(),
    customerHome: (_) => const CustomerPortalScreen(),
    staffHome: (_) => const StaffPortalScreen(),
    ownerHome: (_) => const OwnerPortalScreen(),
    deliveryHome: (_) => const DeliveryPortalScreen(),

    // Customer feature screens — reachable directly for testing/deep-links.
    customerStore: (_) => const CustomerHomeScreen(),
    customerCatalog: (_) => const ProductCatalogScreen(),
    customerCategories: (_) => const ProductCategoriesScreen(),
    customerProductList: (_) => const ProductListScreen(),
    customerProductDetails: (_) => ProductDetailsScreen(),
    customerSearch: (_) => const SearchResultsScreen(),
    customerCart: (_) => const CartScreen(),
    customerCheckout: (_) => const CheckoutScreen(),
    customerOrderConfirmation: (_) => const OrderConfirmationScreen(),
    customerOrderHistory: (_) => const OrderHistoryScreen(),
    customerOrderDetails: (_) => OrderDetailsScreen(),
    customerRepeatOrder: (_) => RepeatOrderScreen(),
    customerOrderTracking: (_) => OrderTrackingScreen(),
    customerProfile: (_) => const CustomerProfileScreen(),
    customerEditProfile: (_) => const EditProfileScreen(),

    customerLoyaltyDashboard: (_) => const LoyaltyDashboardScreen(),
    customerRfidTap: (_) => const RfidTapScreen(),
    customerRfidDetected: (_) => const RfidDetectedScreen(),
    customerLoyaltyHistory: (_) => const LoyaltyHistoryScreen(),
    customerRedeemRewards: (_) => const RedeemRewardsScreen(),
  };

  /// Dynamic route generator for screens that require complex objects as
  /// arguments (e.g. Product, Order).
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case customerProductDetails:
        final product = settings.arguments as Product?;
        return MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(product: product),
        );
      case customerProductList:
        final categoryId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ProductListScreen(categoryId: categoryId ?? 'garlic'),
        );
      case customerOrderDetails:
        final order = settings.arguments as Order?;
        return MaterialPageRoute(
          builder: (_) => OrderDetailsScreen(order: order),
        );
      case customerRepeatOrder:
        final order = settings.arguments as Order?;
        return MaterialPageRoute(
          builder: (_) => RepeatOrderScreen(order: order),
        );
      case customerLoyaltyTransaction:
        // Assume arguments is LoyaltyPointTransaction if needed
        return MaterialPageRoute(
          builder: (_) => const LoyaltyTransactionScreen(),
        );
      case customerRedemptionSuccess:
        return MaterialPageRoute(
          builder: (_) => const RedemptionSuccessScreen(),
        );
      default:
        return null;
    }
  }
}
