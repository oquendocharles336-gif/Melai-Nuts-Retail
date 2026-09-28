import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Tracks real device connectivity (not a guess from a failed request) and
/// tells every customer-data screen apart from a network state:
///
///   - `isOnline == true`  -> the device has a network path. Individual
///     requests can still fail (server error, RLS rejection, timeout) —
///     this only means "not airplane mode / no wifi-or-cell".
///   - `isOnline == false` -> nothing customer-facing should claim a write
///     succeeded; screens should show cached data plainly labeled as such.
///
/// On a transition from offline -> online, [_onReconnect] callbacks
/// registered via [onReconnect] fire once each (debounced, so a flapping
/// connection doesn't trigger a refresh storm). `main.dart` registers the
/// real refreshes here: products/stock, orders, customer profile/loyalty,
/// notifications — see the call site for the exact list, matching what the
/// spec asks to resync when connectivity returns.
///
/// This is genuinely a signal about the network path, not a simulation:
/// `connectivity_plus` reports the OS's own connectivity state.
class ConnectivityService extends ChangeNotifier {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _debounce;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  final List<Future<void> Function()> _reconnectCallbacks = [];

  bool _started = false;

  /// Starts listening. Safe to call more than once (no-op after the first).
  Future<void> start() async {
    if (_started) return;
    _started = true;
    try {
      final initial = await _connectivity.checkConnectivity();
      _isOnline = _hasConnection(initial);
    } catch (_) {
      // Plugin unavailable (unsupported platform, etc.) — assume online
      // rather than permanently hiding customer data behind an offline banner.
      _isOnline = true;
    }
    notifyListeners();

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final nowOnline = _hasConnection(results);
      if (nowOnline == _isOnline) return;
      final wasOffline = !_isOnline;
      _isOnline = nowOnline;
      notifyListeners();
      if (nowOnline && wasOffline) {
        _debounce?.cancel();
        // Small settle delay: the OS can report "connected" a moment
        // before the network is actually usable (captive portals, DHCP).
        _debounce = Timer(const Duration(seconds: 1), _fireReconnectCallbacks);
      }
    });
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Registers a refresh to run once, shortly after connectivity comes
  /// back from being lost. Exceptions from [callback] are swallowed (best
  /// effort — the screens that need this data already retry/refresh on
  /// their own open, so a failed reconnect refresh is not fatal).
  void onReconnect(Future<void> Function() callback) {
    _reconnectCallbacks.add(callback);
  }

  Future<void> _fireReconnectCallbacks() async {
    for (final cb in _reconnectCallbacks) {
      try {
        await cb();
      } catch (_) {
        // Best-effort; individual screens still refresh themselves on open.
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _debounce?.cancel();
    super.dispose();
  }
}
