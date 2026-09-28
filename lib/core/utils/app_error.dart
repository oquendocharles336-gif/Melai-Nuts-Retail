/// Scope / context of an operation where an error occurred, used to tailor
/// friendly customer-facing error messages.
enum ErrorScope {
  general,
  auth,
  cart,
  checkout,
  orders,
  products,
  loyalty,
  notifications,
  profile,
}

/// Normalized, customer-safe error model.
class AppError {
  final String message;
  final bool isConnectivity;
  final Object? rawError;

  const AppError({
    required this.message,
    this.isConnectivity = false,
    this.rawError,
  });
}

/// Helper utility converting raw exceptions into clean, customer-safe [AppError]s.
class AppErrors {
  AppErrors._();

  static AppError from(Object error, {ErrorScope scope = ErrorScope.general}) {
    final str = error.toString().toLowerCase();

    final isOffline = str.contains('socketexception') ||
        str.contains('clientexception') ||
        str.contains('network') ||
        str.contains('offline') ||
        str.contains('connection refused') ||
        str.contains('failed host lookup') ||
        str.contains('semaphore timeout');

    if (isOffline) {
      return AppError(
        message: 'No internet connection. Please check your network and try again.',
        isConnectivity: true,
        rawError: error,
      );
    }

    String message;
    switch (scope) {
      case ErrorScope.auth:
        message = 'Authentication failed. Please check your credentials.';
        break;
      case ErrorScope.cart:
        message = 'Unable to update cart. Please try again.';
        break;
      case ErrorScope.checkout:
        message = 'Unable to complete checkout. Please review your order details.';
        break;
      case ErrorScope.orders:
        message = 'Unable to load order details. Please try again.';
        break;
      case ErrorScope.products:
        message = 'Unable to load products catalog.';
        break;
      case ErrorScope.loyalty:
        message = 'Unable to process rewards.';
        break;
      case ErrorScope.notifications:
        message = 'Unable to load notifications.';
        break;
      case ErrorScope.profile:
        message = 'Unable to update profile.';
        break;
      case ErrorScope.general:
        message = 'Something went wrong. Please try again.';
        break;
    }

    final rawMsg = error.toString().replaceFirst('Exception: ', '').trim();
    if (rawMsg.isNotEmpty &&
        !rawMsg.contains('Instance of') &&
        !rawMsg.contains('PostgrestException') &&
        rawMsg.length < 120) {
      message = rawMsg;
    }

    return AppError(
      message: message,
      isConnectivity: false,
      rawError: error,
    );
  }
}
