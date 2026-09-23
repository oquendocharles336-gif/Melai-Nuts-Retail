import 'package:flutter/material.dart';

import '../data/models/user_role.dart';
import '../data/models/product.dart';
import '../data/models/order.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
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
import '../features/staff/screens/pos_flow_screens.dart';
import '../features/staff/screens/staff_transactions_screen.dart';
import '../features/staff/screens/staff_extra_screens.dart';
import '../features/inventory/screens/inventory_dashboard_screen.dart';
import '../features/inventory/screens/inventory_list_screen.dart';
import '../features/inventory/screens/branch_inventory_screen.dart';
import '../features/inventory/screens/inventory_product_details_screen.dart';
import '../features/inventory/screens/fefo_screen.dart';
import '../features/inventory/screens/batch_details_screen.dart';
import '../features/inventory/screens/low_stock_screen.dart';
import '../features/inventory/screens/inventory_adjustment_screen.dart';
import '../features/inventory/screens/inventory_adjustment_success_screen.dart';
import '../features/inventory/screens/add_inventory_screen.dart';
import '../data/models/inventory_batch.dart';
import '../features/products/screens/product_management_screen.dart';
import '../features/products/screens/product_list_screen.dart' as pm;
import '../features/products/screens/product_details_screen.dart' as pm;
import '../features/products/screens/add_product_screen.dart';
import '../features/products/screens/edit_product_screen.dart';
import '../features/products/screens/product_variants_screen.dart';
import '../features/products/screens/product_pricing_screen.dart';
import '../features/products/screens/product_performance_screen.dart';
import '../features/ocr/screens/ocr_capture_screen.dart';
import '../features/ocr/screens/ocr_preview_screen.dart';
import '../features/ocr/screens/ocr_processing_screen.dart';
import '../features/ocr/screens/ocr_verify_screen.dart';
import '../features/ocr/screens/ocr_success_screen.dart';
import '../features/ocr/screens/ocr_error_screen.dart';
import '../features/ocr/ocr_scan_result.dart';
import '../features/owner/screens/owner_portal_screen.dart';
import '../features/owner/screens/user_management_screen.dart';
import '../features/owner/screens/owner_dashboard_screen.dart';
import '../features/owner/screens/business_overview_screen.dart';
import '../features/owner/screens/sales_overview_screen.dart';
import '../features/owner/screens/sales_analytics_screen.dart';
import '../features/owner/screens/sales_trends_screen.dart';
import '../features/owner/screens/sales_forecast_screen.dart';
import '../features/owner/screens/branch_comparison_screen.dart';
import '../features/owner/screens/branch_performance_screen.dart';
import '../features/owner/screens/product_performance_screen.dart';
import '../features/delivery/screens/delivery_portal_screen.dart';
import '../features/delivery/screens/delivery_dashboard_screen.dart';
import '../features/delivery/screens/create_delivery_screen.dart';
import '../features/delivery/screens/route_optimization_screen.dart';
import '../features/delivery/screens/route_map_screen.dart';
import '../features/delivery/screens/delivery_manifest_screen.dart';
import '../features/delivery/screens/delivery_details_screen.dart';
import '../features/delivery/screens/delivery_history_screen.dart';
import '../features/delivery/screens/assigned_deliveries_screen.dart';
import '../features/delivery/screens/active_delivery_screen.dart';
import '../features/delivery/screens/delivery_route_screen.dart';
import '../features/delivery/screens/gps_tracking_screen.dart';
import '../features/delivery/screens/route_details_screen.dart';
import '../features/delivery/screens/delivery_progress_screen.dart';
import '../features/delivery/screens/next_stop_screen.dart';
import '../features/delivery/screens/delivery_confirmation_screen.dart';
import '../features/delivery/screens/completed_delivery_screen.dart';
import '../features/delivery/screens/delayed_delivery_screen.dart';
import '../features/delivery/screens/cancelled_delivery_screen.dart';
import '../data/models/delivery.dart';
import '../data/models/payment.dart';
import '../data/models/refund.dart';
import '../features/payments/screens/payment_screen.dart';
import '../features/payments/screens/payment_status_screen.dart';
import '../features/refunds/screens/refund_request_screen.dart';
import '../features/refunds/screens/refund_history_screen.dart';
import '../features/refunds/screens/refund_processing_screen.dart';
import '../data/models/notification_item.dart';
import '../features/notifications/screens/notification_center_screen.dart';
import '../features/notifications/screens/notification_detail_screen.dart';
import '../features/notifications/screens/notification_settings_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/settings/screens/security_screen.dart';
import '../features/settings/screens/branch_settings_screen.dart';
import '../features/settings/screens/logout_confirmation_screen.dart';
import '../features/settings/screens/logout_success_screen.dart';

/// Centralized route names. Keep every navigable screen registered here so
/// navigation logic never has to hard-code route strings in feature code.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String customerAccess = '/customer-access';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String resetSuccess = '/reset-success';
  static const String security = '/security';

  static const String customerHome = '/customer';
  static const String staffHome = '/staff';
  static const String ownerHome = '/owner';
  static const String deliveryHome = '/delivery';

  // Owner Delivery Management feature screens (lib/features/delivery/).
  static const String deliveryDashboard = '/delivery/dashboard';
  static const String deliveryCreate = '/delivery/create';
  static const String routeOptimization = '/delivery/route-optimization';
  static const String routeMap = '/delivery/route-map';
  static const String deliveryManifest = '/delivery/manifest';
  static const String deliveryDetails = '/delivery/details';
  static const String deliveryHistory = '/delivery/history';

  // Delivery Personnel (rider) flow screens.
  static const String deliveryAssigned = '/delivery/assigned';
  static const String deliveryActive = '/delivery/active';
  static const String deliveryRoute = '/delivery/route';
  static const String gpsTracking = '/delivery/gps-tracking';
  static const String deliveryRouteDetails = '/delivery/route-details';
  static const String deliveryProgress = '/delivery/progress';
  static const String deliveryNextStop = '/delivery/next-stop';
  static const String deliveryConfirmation = '/delivery/confirmation';
  static const String deliveryCompleted = '/delivery/completed';
  static const String deliveryDelayed = '/delivery/delayed';
  static const String deliveryCancelled = '/delivery/cancelled';

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

  // Payments feature screens (lib/features/payments/).
  static const String paymentPay = '/payments/pay';
  static const String paymentStatus = '/payments/status';

  // Refunds feature screens (lib/features/refunds/).
  static const String customerRefundRequest = '/refunds/request';
  static const String customerRefundHistory = '/refunds/history';
  static const String refundProcessing = '/refunds/processing';

  // Notifications feature screens (lib/features/notifications/) — shared
  // across all roles.
  static const String notificationCenter = '/notifications';
  static const String notificationDetail = '/notifications/detail';
  static const String notificationSettings = '/notifications/settings';

  // Settings feature screens (lib/features/settings/) — shared across all
  // roles.
  static const String appSettings = '/settings';
  static const String accountSecurity = '/settings/security';
  static const String branchSettings = '/settings/branch';
  static const String logoutConfirmation = '/settings/logout';
  static const String logoutSuccess = '/settings/logout-success';

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

  // Staff feature screens
  static const String staffPosCart = '/staff/pos/cart';
  static const String staffPosPayment = '/staff/pos/payment';
  static const String staffPosCashInput = '/staff/pos/cash-input';
  static const String staffPosProcessing = '/staff/pos/processing';
  static const String staffPosReceipt = '/staff/pos/receipt';
  static const String staffPosFailed = '/staff/pos/failed';
  static const String staffTransactionDetails = '/staff/transactions/details';
  static const String staffNotifications = '/staff/notifications';
  static const String staffProfile = '/staff/profile';

  // Staff Inventory (FEFO) feature screens.
  // Inventory & FEFO feature screens (lib/features/inventory/).
  static const String inventoryDashboard = '/inventory';
  static const String inventoryList = '/inventory/list';
  static const String inventoryBranch = '/inventory/branch';
  static const String inventoryProductDetails = '/inventory/product-details';
  static const String inventoryFefo = '/inventory/fefo';
  static const String inventoryBatchDetails = '/inventory/batch-details';
  static const String inventoryLowStock = '/inventory/low-stock';
  static const String inventoryAdjustment = '/inventory/adjust';
  static const String inventoryAdjustmentSuccess = '/inventory/adjust-success';
  static const String inventoryAdd = '/inventory/add';

  // Product Management & Pricing feature screens (lib/features/products/).
  static const String productManagement = '/products';
  static const String productList = '/products/list';
  static const String productDetails = '/products/details';
  static const String productAdd = '/products/add';
  static const String productEdit = '/products/edit';
  static const String productVariants = '/products/variants';
  static const String productPricing = '/products/pricing';
  static const String productPerformance = '/products/performance';

  // OCR (simulated) feature screens (lib/features/ocr/).
  static const String ocrCapture = '/ocr/capture';
  static const String ocrPreview = '/ocr/preview';
  static const String ocrProcessing = '/ocr/processing';
  static const String ocrVerify = '/ocr/verify';
  static const String ocrSuccess = '/ocr/success';
  static const String ocrError = '/ocr/error';

  static const String ownerUserManagement = '/owner/users';

  // Owner module screens (lib/features/owner/).
  static const String ownerDashboard = '/owner/dashboard';
  static const String ownerBusinessOverview = '/owner/business-overview';
  static const String ownerSalesOverview = '/owner/sales-overview';
  static const String ownerSalesAnalytics = '/owner/sales-analytics';
  static const String ownerSalesTrends = '/owner/sales-trends';
  static const String ownerSalesForecast = '/owner/sales-forecast';
  static const String ownerBranchComparison = '/owner/branch-comparison';
  static const String ownerBranchPerformance = '/owner/branch-performance';
  static const String ownerProductPerformance = '/owner/product-performance';

  static Map<String, WidgetBuilder> get routes => {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    customerAccess: (_) => const CustomerAccessScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    resetPassword: (_) => const ResetPasswordScreen(),
    resetSuccess: (_) => const PasswordResetSuccessScreen(),
    security: (_) => const SecurityLoginScreen(),
    customerHome: (_) => const CustomerPortalScreen(),
    staffHome: (_) => const StaffPortalScreen(),
    ownerHome: (_) => const OwnerPortalScreen(),
    deliveryHome: (_) => const DeliveryPortalScreen(),

    deliveryDashboard: (_) => const DeliveryDashboardScreen(),
    deliveryCreate: (_) => const CreateDeliveryScreen(),
    deliveryHistory: (_) => const DeliveryHistoryScreen(),
    deliveryAssigned: (_) => const AssignedDeliveriesScreen(),
    // NOTE: deliveryActive, deliveryRoute, gpsTracking, deliveryRouteDetails,
    // deliveryProgress, deliveryNextStop, deliveryConfirmation,
    // deliveryCompleted, deliveryDelayed, and deliveryCancelled all take a
    // Delivery (and sometimes a DeliveryStop) argument and are handled
    // exclusively in onGenerateRoute below (see the earlier note on route
    // shadowing).
    // NOTE: routeOptimization, routeMap, deliveryManifest, and
    // deliveryDetails all take a Delivery argument and are handled
    // exclusively in onGenerateRoute below (see the earlier note on route
    // shadowing).

    // Customer feature screens — reachable directly for testing/deep-links.
    customerStore: (_) => const CustomerHomeScreen(),
    customerCatalog: (_) => const ProductCatalogScreen(),
    customerCategories: (_) => const ProductCategoriesScreen(),
    // NOTE: customerProductList, customerProductDetails,
    // customerOrderDetails, and customerRepeatOrder are intentionally NOT
    // registered here — they take optional arguments and are handled
    // exclusively in onGenerateRoute below (see note above the inventory
    // routes for why registering them in both places is a bug).
    customerSearch: (_) => const SearchResultsScreen(),
    customerCart: (_) => const CartScreen(),
    customerCheckout: (_) => const CheckoutScreen(),
    // customerOrderConfirmation is NOT registered here — it now requires a
    // real Order argument (built at checkout time) and is only reachable
    // via the direct MaterialPageRoute push from CheckoutScreen.
    customerOrderHistory: (_) => const OrderHistoryScreen(),
    customerProfile: (_) => const CustomerProfileScreen(),
    customerEditProfile: (_) => const EditProfileScreen(),

    customerLoyaltyDashboard: (_) => const LoyaltyDashboardScreen(),
    customerRfidTap: (_) => const RfidTapScreen(),
    customerRfidDetected: (_) => const RfidDetectedScreen(),
    customerLoyaltyHistory: (_) => const LoyaltyHistoryScreen(),
    customerRedeemRewards: (_) => const RedeemRewardsScreen(),
    customerRefundHistory: (_) => const RefundHistoryScreen(),
    notificationCenter: (_) => const NotificationCenterScreen(),
    notificationSettings: (_) => const NotificationSettingsScreen(),
    appSettings: (_) => const SettingsScreen(),
    accountSecurity: (_) => const SecurityScreen(),
    branchSettings: (_) => const BranchSettingsScreen(),
    logoutConfirmation: (_) => const LogoutConfirmationScreen(),
    logoutSuccess: (_) => const LogoutSuccessScreen(),
    // NOTE: paymentPay, paymentStatus, customerRefundRequest,
    // refundProcessing, and notificationDetail all take arguments and are
    // handled exclusively in onGenerateRoute below (see the earlier note on
    // route shadowing).

    staffPosFailed: (_) => const PosFailedScreen(),
    staffNotifications: (_) => const StaffNotificationsScreen(),
    staffProfile: (_) => const StaffProfileScreen(),

    inventoryDashboard: (_) => const InventoryDashboardScreen(),
    inventoryList: (_) => const InventoryListScreen(),
    inventoryLowStock: (_) => const LowStockScreen(),
    inventoryAdd: (_) => const AddInventoryScreen(),

    productManagement: (_) => const ProductManagementScreen(),
    productList: (_) => const pm.ProductListScreen(),
    productAdd: (_) => const AddProductScreen(),
    productPerformance: (_) => const ProductPerformanceScreen(),
    // NOTE: productDetails, productEdit, productVariants, productPricing
    // take a productId argument and are handled exclusively in
    // onGenerateRoute below (see the earlier note on route shadowing).

    ocrCapture: (_) => const OcrCaptureScreen(),
    ocrPreview: (_) => const OcrPreviewScreen(),
    ocrError: (_) => const OcrErrorScreen(),
    // NOTE: ocrProcessing, ocrVerify, and ocrSuccess take arguments and are
    // handled exclusively in onGenerateRoute below.
    // NOTE: inventoryBranch, inventoryProductDetails, inventoryFefo,
    // inventoryBatchDetails, and inventoryAdjustment are intentionally NOT
    // registered here — they take (optional or required) arguments and are
    // handled exclusively in onGenerateRoute below. A static `routes` map
    // entry always wins over onGenerateRoute for the same name, so
    // registering them in both places would silently swallow their
    // arguments.

    ownerUserManagement: (_) => const UserManagementScreen(),

    ownerDashboard: (_) => const OwnerDashboardScreen(),
    ownerBusinessOverview: (_) => const BusinessOverviewScreen(),
    ownerSalesOverview: (_) => const SalesOverviewScreen(),
    ownerSalesAnalytics: (_) => const SalesAnalyticsScreen(),
    ownerSalesTrends: (_) => const SalesTrendsScreen(),
    ownerSalesForecast: (_) => const SalesForecastScreen(),
    ownerBranchComparison: (_) => const BranchComparisonScreen(),
    ownerProductPerformance: (_) => const OwnerProductPerformanceScreen(),
    // NOTE: ownerBranchPerformance takes a branch-name argument and is
    // handled exclusively in onGenerateRoute below.
  };

  /// Dynamic route generator for screens that require complex objects as
  /// arguments (e.g. Product, Order).
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case customerProductDetails:
        final product = settings.arguments as Product;
        return MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(product: product),
        );
      case customerOrderTracking:
        final order = settings.arguments as Order;
        return MaterialPageRoute(
          builder: (_) => OrderTrackingScreen(order: order),
        );
      case customerOrderConfirmation:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => OrderConfirmationScreen(
            order: args['order'] as Order,
            itemCount: args['itemCount'] as int? ?? 1,
            total: args['total'] as double? ?? 0.0,
          ),
        );
      case customerProductList:
        final categoryId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ProductListScreen(categoryId: categoryId),
        );
      case customerOrderDetails:
        final order = settings.arguments as Order;
        return MaterialPageRoute(
          builder: (_) => OrderDetailsScreen(order: order),
        );
      case customerRepeatOrder:
        final order = settings.arguments as Order;
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
      case paymentPay:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PaymentScreen(
            orderId: args['orderId'] as String,
            amount: args['amount'] as double,
            initialMethod: args['method'] as PaymentMethod? ?? PaymentMethod.gcash,
          ),
        );
      case paymentStatus:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PaymentStatusScreen(
            orderId: args['orderId'] as String,
            amount: args['amount'] as double? ?? 0,
          ),
        );
      case customerRefundRequest:
        final order = settings.arguments as Order;
        return MaterialPageRoute(
          builder: (_) => RefundRequestScreen(order: order),
        );
      case refundProcessing:
        final request = settings.arguments as RefundRequest;
        return MaterialPageRoute(
          builder: (_) => RefundProcessingScreen(request: request),
        );
      case notificationDetail:
        final item = settings.arguments as NotificationItem;
        return MaterialPageRoute(
          builder: (_) => NotificationDetailScreen(item: item),
        );
      case staffPosCart:
        final cart = settings.arguments as Map<String, int>;
        return MaterialPageRoute(
          builder: (_) => PosCartScreen(initialCart: cart),
        );
      case staffPosPayment:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PosPaymentScreen(
            amount: args['amount'] as double,
            cart: args['cart'] as Map<String, int>,
          ),
        );
      case staffPosCashInput:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PosCashInputScreen(
            amount: args['amount'] as double,
            cart: args['cart'] as Map<String, int>,
          ),
        );
      case staffPosProcessing:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PosProcessingScreen(
            method: args['method'] as String,
            amount: args['amount'] as double,
            cart: args['cart'] as Map<String, int>,
          ),
        );
      case staffPosReceipt:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => PosReceiptScreen(
            method: args?['method'] as String? ?? 'GCash',
            amount: args?['amount'] as double? ?? 245,
            cart: args?['cart'] as Map<String, int>?,
            cashReceived: args?['cashReceived'] as double?,
          ),
        );
      case staffTransactionDetails:
        final order = settings.arguments as Order;
        return MaterialPageRoute(
          builder: (_) => TransactionDetailsScreen(order: order),
        );
      case inventoryBranch:
        final branch = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BranchInventoryScreen(branch: branch),
        );
      case inventoryProductDetails:
        final productId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => InventoryProductDetailsScreen(productId: productId),
        );
      case inventoryFefo:
        final priority = settings.arguments as FefoPriority?;
        return MaterialPageRoute(
          builder: (_) => FefoScreen(initialFilter: priority),
        );
      case inventoryBatchDetails:
        final batch = settings.arguments as InventoryBatch;
        return MaterialPageRoute(
          builder: (_) => BatchDetailsScreen(batch: batch),
        );
      case inventoryAdjustment:
        final batch = settings.arguments as InventoryBatch;
        return MaterialPageRoute(
          builder: (_) => InventoryAdjustmentScreen(batch: batch),
        );
      case inventoryAdjustmentSuccess:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => InventoryAdjustmentSuccessScreen(
            productId: args['productId'] as String,
            batch: args['batch'] as InventoryBatch,
            adjustment: args['adjustment'] as int,
            newStock: args['newStock'] as int,
          ),
        );
      case productDetails:
        final productId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => pm.ProductDetailsScreen(productId: productId),
        );
      case productEdit:
        final productId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => EditProductScreen(productId: productId),
        );
      case productVariants:
        final productId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ProductVariantsScreen(productId: productId),
        );
      case productPricing:
        final productId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ProductPricingScreen(productId: productId),
        );
      case ocrProcessing:
        final simulateFailure = settings.arguments as bool? ?? false;
        return MaterialPageRoute(
          builder: (_) => OcrProcessingScreen(simulateFailure: simulateFailure),
        );
      case ocrVerify:
        final result = settings.arguments as OcrScanResult;
        return MaterialPageRoute(
          builder: (_) => OcrVerifyScreen(result: result),
        );
      case ocrSuccess:
        final result = settings.arguments as OcrScanResult;
        return MaterialPageRoute(
          builder: (_) => OcrSuccessScreen(result: result),
        );
      case ownerBranchPerformance:
        final branch = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BranchPerformanceScreen(branch: branch),
        );
      case routeOptimization:
        final delivery = settings.arguments as Delivery;
        return MaterialPageRoute(
          builder: (_) => RouteOptimizationScreen(delivery: delivery),
        );
      case routeMap:
        final delivery = settings.arguments as Delivery;
        return MaterialPageRoute(
          builder: (_) => RouteMapScreen(delivery: delivery),
        );
      case deliveryManifest:
        final delivery = settings.arguments as Delivery;
        return MaterialPageRoute(
          builder: (_) => DeliveryManifestScreen(delivery: delivery),
        );
      case deliveryDetails:
        final delivery = settings.arguments as Delivery;
        return MaterialPageRoute(
          builder: (_) => DeliveryDetailsScreen(delivery: delivery),
        );
      case deliveryActive:
        final delivery = settings.arguments as Delivery;
        return MaterialPageRoute(
          builder: (_) => ActiveDeliveryScreen(delivery: delivery),
        );
      case deliveryRoute:
        final delivery = settings.arguments as Delivery;
        return MaterialPageRoute(
          builder: (_) => DeliveryRouteScreen(delivery: delivery),
        );
      case gpsTracking:
        final delivery = settings.arguments as Delivery;
        return MaterialPageRoute(
          builder: (_) => GpsTrackingScreen(delivery: delivery),
        );
      case deliveryRouteDetails:
        final delivery = settings.arguments as Delivery;
        return MaterialPageRoute(
          builder: (_) => RouteDetailsScreen(delivery: delivery),
        );
      case deliveryProgress:
        final delivery = settings.arguments as Delivery;
        return MaterialPageRoute(
          builder: (_) => DeliveryProgressScreen(delivery: delivery),
        );
      case deliveryNextStop:
        final delivery = settings.arguments as Delivery;
        return MaterialPageRoute(
          builder: (_) => NextStopScreen(delivery: delivery),
        );
      case deliveryConfirmation:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => DeliveryConfirmationScreen(
            delivery: args['delivery'] as Delivery,
            stop: args['stop'] as DeliveryStop,
          ),
        );
      case deliveryCompleted:
        final delivery = settings.arguments as Delivery;
        return MaterialPageRoute(
          builder: (_) => CompletedDeliveryScreen(delivery: delivery),
        );
      case deliveryDelayed:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => DelayedDeliveryScreen(
            delivery: args['delivery'] as Delivery,
            stop: args['stop'] as DeliveryStop,
          ),
        );
      case deliveryCancelled:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CancelledDeliveryScreen(
            delivery: args['delivery'] as Delivery,
            stop: args['stop'] as DeliveryStop,
          ),
        );
      default:
        return null;
    }
  }
}