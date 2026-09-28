import 'dart:async';

import 'package:flutter/foundation.dart';
import '../utils/app_error.dart';
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

  /// The customer whose records were last loaded *successfully*.
  String? _uid;

  /// The customer a load was most recently requested for, whether or not it
  /// succeeded — this is what [refresh]/[retry] reload after a failure.
  String? _requestedUid;

  Future<void>? _inFlight;
  String? _inFlightUid;

  /// Bumped by [clear] so a response that arrives after sign-out is dropped
  /// instead of repopulating the shared lists with the previous customer's data.
  int _generation = 0;

  bool _loading = false;

  /// True while any customer record load is running.
  bool get isLoading => _loading;

  /// True while loading and nothing has been loaded yet — screens should show
  /// their loading state (not an empty state) in this case.
  bool get isInitialLoading => _loading && !hasLoaded;

  AppError? _error;

  /// Customer-safe error from the most recent load, or null if it succeeded.
  /// When non-null and [hasLoaded] is false, screens should show an error
  /// state with a retry; when [hasLoaded] is true the last good data is still
  /// in the lists and a stale-data notice is enough.
  AppError? get error => _error;

  /// True once the customer's records have loaded successfully.
  bool get hasLoaded => _uid != null;

  int pointsBalance = 0;
  CustomerProfile? profile;
  List<CustomerAddress> addresses = [];

  /// The address to prefill on checkout / show as "delivery address" on the
  /// profile screen: the one marked default, or the first saved address if
  /// none is marked, or null if the customer hasn't saved any yet.
  CustomerAddress? get defaultAddress {
    if (addresses.isEmpty) return null;
    for (final a in addresses) {
      if (a.isDefault) return a;
    }
    return addresses.first;
  }

  String? _fallbackName;
  String? _fallbackEmail;

  /// Records who is signing in (no network) so that [refresh]/[retry] work
  /// even if the very first load — or the profile-creation step before it —
  /// failed. Call right after sign-in, before any load.
  void rememberCustomer({
    required String firebaseUid,
    required String fallbackName,
    required String fallbackEmail,
  }) {
    _requestedUid = firebaseUid;
    _fallbackName = fallbackName;
    _fallbackEmail = fallbackEmail;
  }

  /// Loads (or reloads) everything for [firebaseUid]. Safe to call multiple
  /// times — screens call this from `initState` and it's a cheap no-op if
  /// already loaded for the same customer (use [refresh] to force a reload).
  /// Concurrent calls for the same customer share one request.
  ///
  /// Never throws; check [error] / [hasLoaded] for the outcome.
  Future<void> loadForCustomer(String firebaseUid) {
    if (_uid == firebaseUid && !_loading) return Future.value();
    return _load(firebaseUid);
  }

  /// Forces a reload for the current customer. Also works after a failed
  /// first load (when [hasLoaded] is still false). With [throwOnError] the
  /// [AppError] is rethrown so pull-to-refresh handlers can show a snackbar.
  Future<void> refresh({bool throwOnError = false}) async {
    final uid = _uid ?? _requestedUid;
    if (uid == null) return;
    await _load(uid);
    final e = _error;
    if (throwOnError && e != null) throw e;
  }

  /// Retry after a failed load (same as [refresh]).
  Future<void> retry() => refresh();

  Future<void> _load(String firebaseUid) {
    final running = _inFlight;
    if (running != null && _inFlightUid == firebaseUid) return running;
    final future = _runLoad(firebaseUid);
    _inFlight = future;
    _inFlightUid = firebaseUid;
    return future;
  }

  Future<void> _runLoad(String firebaseUid) async {
    final generation = _generation;
    _requestedUid = firebaseUid;
    _loading = true;
    _error = null;
    // Deferred: screens call this from `initState`, i.e. mid-build, and a
    // synchronous notify there would throw "setState() called during build".
    scheduleMicrotask(notifyListeners);
    try {
      final results = await AppErrors.guard(
        () async {
          // The profile row is created on first sign-in. If that step failed
          // earlier (e.g. offline), redo it here so Retry recovers fully.
          final fallbackEmail = _fallbackEmail;
          if (profile == null && fallbackEmail != null) {
            profile = await CustomerProfileRepository.instance.ensureProfile(
              firebaseUid: firebaseUid,
              fallbackName: _fallbackName ?? '',
              fallbackEmail: fallbackEmail,
            );
          }
          return Future.wait([
            OrdersRepository.instance.fetchOrders(firebaseUid),
            LoyaltyRepository.instance.fetchBalance(firebaseUid),
            LoyaltyRepository.instance.fetchTransactions(firebaseUid),
            LoyaltyRepository.instance.fetchRewards(),
            NotificationsRepository.instance.fetchAll(firebaseUid),
            RefundsRepository.instance.fetchAll(firebaseUid),
            PaymentsRepository.instance.fetchAll(firebaseUid),
            CustomerProfileRepository.instance.fetchAddresses(firebaseUid),
          ]);
        },
        timeout: AppErrors.rpcTimeout,
      );

      // Signed out (or switched account) while this was loading: drop it.
      if (generation != _generation) return;

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
      addresses = results[7] as List<CustomerAddress>;

      _uid = firebaseUid;
      _error = null;
    } catch (e) {
      if (generation != _generation) return;
      // Keep whatever was last loaded (or the empty starting state) and
      // record the failure so screens can show an error + retry rather than
      // pretending there is simply no data.
      _error = AppErrors.from(e);
    } finally {
      if (generation == _generation) {
        _loading = false;
        _inFlight = null;
        _inFlightUid = null;
        notifyListeners();
      }
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

  /// Lets [SavedAddressesScreen] push its freshly-fetched address list back
  /// in here after an add/edit/delete, instead of triggering a full
  /// `refresh()` re-fetch of every other customer record just to update one.
  void setAddresses(List<CustomerAddress> updated) {
    addresses = updated;
    notifyListeners();
  }

  /// Clears every cached customer record — call on sign-out so the next
  /// signed-in account (on a shared device) never sees a previous
  /// customer's data.
  void clear() {
    _generation++;
    _uid = null;
    _requestedUid = null;
    _fallbackName = null;
    _fallbackEmail = null;
    _inFlight = null;
    _inFlightUid = null;
    _loading = false;
    _error = null;
    pointsBalance = 0;
    profile = null;
    addresses = [];
    kOrders.clear();
    dummyLoyaltyTransactions.clear();
    dummyRewards.clear();
    kNotifications.clear();
    kRefundRequests.clear();
    kPayments.clear();
    notifyListeners();
  }
}