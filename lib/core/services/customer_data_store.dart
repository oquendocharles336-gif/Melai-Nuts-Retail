import 'package:flutter/foundation.dart';
import '../../data/dummy_data/dummy_loyalty.dart';
import '../../data/dummy_data/dummy_notifications.dart';
import '../../data/dummy_data/dummy_orders.dart';
import '../../data/dummy_data/dummy_payments.dart';
import '../../data/dummy_data/dummy_refunds.dart';
import '../../data/models/customer_profile.dart';
import '../../data/models/loyalty.dart';
import '../../data/models/notification_item.dart';
import '../../data/models/order.dart';
import '../../data/models/payment.dart';
import '../../data/models/refund.dart';
import '../../data/repositories/customer_profile_repository.dart';
import '../../data/repositories/loyalty_repository.dart';
import '../../data/repositories/notifications_repository.dart';
import '../../data/repositories/orders_repository.dart';
import '../../data/repositories/payments_repository.dart';
import '../../data/repositories/refunds_repository.dart';

/// Loads every customer-scoped record (orders, loyalty, notifications,
/// refunds, profile, addresses) from Supabase after sign-in, and keeps the
/// existing shared globals (`kOrders`, `dummyRewards`,
/// `dummyLoyaltyTransactions`, `kNotifications`, `kRefundRequests`) in sync
/// so the screens that already read them directly need no further changes.
///
/// A [ChangeNotifier] so screens can wrap their body in a
/// `ListenableBuilder(listenable: CustomerDataStore.instance, ...)` — the
/// same pattern this app already uses for [CartController].
class CustomerDataStore extends ChangeNotifier {
  CustomerDataStore._();
  static final CustomerDataStore instance = CustomerDataStore._();

  String? _uid;
  bool _loading = false;
  bool get isLoading => _loading;
  bool get hasLoaded => _uid != null;

  int pointsBalance = 0;
  CustomerProfile? profile;

  /// Loads (or reloads) everything for [firebaseUid]. Safe to call multiple
  /// times — screens call this from `initState` and it's a cheap no-op if
  /// already loaded for the same customer (use [refresh] to force a reload).
  Future<void> loadForCustomer(String firebaseUid) async {
    if (_uid == firebaseUid && !_loading) return;
    await _load(firebaseUid);
  }

  Future<void> refresh() async {
    final uid = _uid;
    if (uid != null) await _load(uid);
  }

  Future<void> _load(String firebaseUid) async {
    _loading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        OrdersRepository.instance.fetchOrders(firebaseUid),
        LoyaltyRepository.instance.fetchBalance(firebaseUid),
        LoyaltyRepository.instance.fetchTransactions(firebaseUid),
        LoyaltyRepository.instance.fetchRewards(),
        NotificationsRepository.instance.fetchAll(firebaseUid),
        RefundsRepository.instance.fetchAll(firebaseUid),
        PaymentsRepository.instance.fetchAll(firebaseUid),
      ]);

      kOrders
        ..clear()
        ..addAll(results[0] as List<Order>);
      pointsBalance = results[1] as int;
      dummyLoyaltyTransactions
        ..clear()
        ..addAll(results[2] as List<LoyaltyPointTransaction>);
      dummyRewards
        ..clear()
        ..addAll(results[3] as List<RewardItem>);
      kNotifications
        ..clear()
        ..addAll(results[4] as List<NotificationItem>);
      kRefundRequests
        ..clear()
        ..addAll(results[5] as List<RefundRequest>);
      kPayments
        ..clear()
        ..addAll(results[6] as List<PaymentTransaction>);

      _uid = firebaseUid;
    } catch (_) {
      // Offline or not yet configured — keep whatever was last loaded (or
      // the empty starting state) and let the existing empty-state UI
      // handle it; nothing here should crash the app.
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Ensures the given customer's profile row exists (creating it from
  /// their Firebase name/email the first time), and caches it here.
  Future<CustomerProfile> ensureProfile({
    required String firebaseUid,
    required String fallbackName,
    required String fallbackEmail,
  }) async {
    final p = await CustomerProfileRepository.instance.ensureProfile(
      firebaseUid: firebaseUid,
      fallbackName: fallbackName,
      fallbackEmail: fallbackEmail,
    );
    profile = p;
    notifyListeners();
    return p;
  }

  void updateCachedProfile(CustomerProfile updated) {
    profile = updated;
    notifyListeners();
  }

  /// Clears every cached customer record — call on sign-out so the next
  /// signed-in account (on a shared device) never sees a previous
  /// customer's data.
  void clear() {
    _uid = null;
    pointsBalance = 0;
    profile = null;
    kOrders.clear();
    dummyLoyaltyTransactions.clear();
    dummyRewards.clear();
    kNotifications.clear();
    kRefundRequests.clear();
    kPayments.clear();
    notifyListeners();
  }
}