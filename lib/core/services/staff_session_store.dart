import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/staff_context.dart';
import '../../data/repositories/staff_profile_repository.dart';
import '../utils/app_error.dart';
import 'local_cache_service.dart';
import 'pending_writes_service.dart';

/// Where the staff session stands. Only [ready] unlocks staff screens.
enum StaffSessionStatus {
  /// No staff member is bound to this session.
  signedOut,

  /// The profile / branch / permissions are being fetched.
  loading,

  /// Loaded from the server and confirmed active.
  ready,

  /// Signed in, but no staff profile exists for this Firebase account.
  notProvisioned,

  /// An administrator deactivated this staff account.
  inactive,

  /// The server could not be reached / answered badly. Fail closed: staff
  /// screens stay locked until a retry succeeds. See [StaffSessionStore.error].
  failed,
}

/// The single, identity-bound source of truth for the signed-in staff member's
/// profile, branch assignment and permissions:
///
///   Firebase UID  ->  staff_members row  ->  branch + permissions
///
/// IDENTITY BINDING (no data leakage between accounts)
///  * The store belongs to exactly one Firebase UID at a time ([ownerUid]).
///  * Whenever the Firebase identity changes or disappears — a normal logout,
///    a revoked / expired session, a different person signing in — the store
///    is cleared immediately: profile, branch, permissions, errors, and every
///    hook registered with [registerResetHook] (use that from any later staff
///    store that holds private state: notifications, drafts, in-progress
///    sales, ...). [bindToAuth] wires this to Firebase once at startup, so it
///    does not depend on every logout path remembering to call [clear].
///  * A fetch that finishes after the identity changed is thrown away
///    ([_isCurrent]), so a slow response for Staff A can never land in Staff
///    B's session.
///  * Nothing here is persisted to disk. A cold start always re-reads the
///    server, so a permission revoked while the app was closed is honoured.
///
/// FAIL CLOSED: a staff member is [StaffSessionStatus.ready] only after the
/// server confirmed an active profile for THIS uid. On a refresh that fails
/// only because of connectivity the last confirmed context stays usable
/// (staff screens read the database, which enforces the same rules on every
/// request); any other failure locks the session.
///
/// A [ChangeNotifier] so widgets can wrap themselves in
/// `ListenableBuilder(listenable: StaffSessionStore.instance, ...)`, the same
/// pattern as [CustomerDataStore] and [CartController].
class StaffSessionStore extends ChangeNotifier {
  StaffSessionStore._();
  static final StaffSessionStore instance = StaffSessionStore._();

  StaffSessionStatus _status = StaffSessionStatus.signedOut;
  StaffContext? _context;
  AppError? _error;

  /// The Firebase UID this store is currently loading / holding data for.
  String? _ownerUid;

  /// Bumped by every [clear]; invalidates fetches started before it.
  int _generation = 0;

  Future<StaffSessionStatus>? _inFlight;
  String? _inFlightUid;

  StreamSubscription<User?>? _authSub;
  final List<VoidCallback> _resetHooks = <VoidCallback>[];

  // ---- Read API -------------------------------------------------------------

  StaffSessionStatus get status => _status;

  /// The validated staff context, or null unless [status] is
  /// [StaffSessionStatus.ready] (or a connectivity-only refresh failed after a
  /// successful load).
  StaffContext? get context => _context;

  /// Customer-safe error from the last failed load; null after a success.
  AppError? get error => _error;

  /// The Firebase UID the store is bound to, if any.
  String? get ownerUid => _ownerUid;

  bool get isReady => _status == StaffSessionStatus.ready && _context != null;

  /// True only when the store holds a confirmed context for [uid] AND [uid] is
  /// the account Firebase currently has signed in. Screens should gate on this,
  /// not on [isReady] alone.
  bool isReadyFor(String uid) =>
      isReady &&
      _context!.firebaseUid == uid &&
      FirebaseAuth.instance.currentUser?.uid == uid;

  String? get branchId => _context?.branchId;
  bool get isOwner => _context?.isOwner ?? false;
  String? get displayName => _context?.fullName;
  Set<String> get permissions => _context?.permissions ?? const <String>{};

  /// UX-only permission check (see [StaffContext]): false unless [isReady].
  /// The database enforces the same rule independently.
  bool can(String permission) => isReady && _context!.can(permission);

  bool canAny(Iterable<String> candidates) => isReady && _context!.canAny(candidates);

  // ---- Identity binding -----------------------------------------------------

  /// Starts following the Firebase identity. Call once after
  /// `Firebase.initializeApp` (see main.dart). Idempotent.
  ///
  ///  * A different account (or nobody) is now signed in -> clear everything
  ///    the previous staff member had, synchronously, before any screen can
  ///    rebuild with the new identity.
  ///  * A new account is now signed in -> purge on-device caches and queued
  ///    writes that belong to anyone else (on a shared device, a forced or
  ///    expired sign-out never ran the normal wipe).
  void bindToAuth() {
    if (_authSub != null) return;
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      final uid = user?.uid;
      if (uid != _ownerUid) clear();
      if (uid != null) {
        // Never touches the signed-in account's own data; 'anon' is the public
        // catalog cache shared by everyone.
        unawaited(LocalCache.instance.keepOnly(<String>{'anon', uid}));
        unawaited(PendingWritesService.instance.keepOnlyUser(uid));
      }
    });
  }

  /// Registers a callback that runs every time the staff identity is cleared.
  /// Later staff stores that keep per-person state (notifications, pending
  /// sales, drafts, cached lists, realtime subscriptions) MUST register one so
  /// nothing survives into the next account. Returns a function that
  /// unregisters it.
  VoidCallback registerResetHook(VoidCallback hook) {
    _resetHooks.add(hook);
    return () => _resetHooks.remove(hook);
  }

  // ---- Loading --------------------------------------------------------------

  /// Loads (or reloads) the staff context for [uid] — the Firebase UID that is
  /// signed in right now. Concurrent calls for the same uid share one request.
  /// If the store still holds a different account's data it is cleared first.
  ///
  /// Never throws; the returned status (also [status]) is the outcome, with
  /// [error] set for [StaffSessionStatus.failed].
  Future<StaffSessionStatus> loadForStaff(String uid, {bool force = false}) {
    if (_ownerUid != null && _ownerUid != uid) clear();
    if (!force && _ownerUid == uid && _status == StaffSessionStatus.ready) {
      return Future<StaffSessionStatus>.value(_status);
    }
    final running = _inFlight;
    if (running != null && _inFlightUid == uid) return running;

    _ownerUid = uid;
    final generation = _generation;
    final future = _run(uid, generation);
    _inFlight = future;
    _inFlightUid = uid;
    unawaited(future.whenComplete(() {
      if (identical(_inFlight, future)) {
        _inFlight = null;
        _inFlightUid = null;
      }
    }));
    return future;
  }

  /// Re-reads the server for the account this store is bound to (retry after a
  /// failure, reconnect, pull-to-refresh). A no-op signed-out.
  Future<StaffSessionStatus> refresh() {
    final uid = _ownerUid ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Future<StaffSessionStatus>.value(_status);
    return loadForStaff(uid, force: true);
  }

  Future<StaffSessionStatus> _run(String uid, int generation) async {
    // A refresh of an already-confirmed session keeps showing it (no lock
    // flash); a first load shows the loading state.
    final refreshingConfirmed = isReady && _context!.firebaseUid == uid;
    if (!refreshingConfirmed) {
      _context = null;
      _status = StaffSessionStatus.loading;
    }
    _error = null;
    notifyListeners();

    StaffContextResult? result;
    AppError? failure;
    try {
      result = await StaffProfileRepository.instance.fetchMyContext(expectedUid: uid);
    } catch (e) {
      failure = AppErrors.from(e, scope: ErrorScope.profile);
    }

    // The account changed (or the store was cleared) while we waited: this
    // answer belongs to somebody else. Drop it without touching any state.
    if (!_isCurrent(generation, uid)) return _status;

    if (failure != null) {
      _error = failure;
      final keepConfirmed = refreshingConfirmed && failure.isConnectivity;
      if (!keepConfirmed) {
        _context = null;
        _status = StaffSessionStatus.failed;
      }
    } else {
      switch (result!.status) {
        case StaffContextStatus.active:
          _context = result.context;
          _status = StaffSessionStatus.ready;
        case StaffContextStatus.inactive:
          _context = null;
          _status = StaffSessionStatus.inactive;
        case StaffContextStatus.notProvisioned:
          _context = null;
          _status = StaffSessionStatus.notProvisioned;
      }
    }
    notifyListeners();
    return _status;
  }

  bool _isCurrent(int generation, String uid) =>
      generation == _generation &&
      _ownerUid == uid &&
      FirebaseAuth.instance.currentUser?.uid == uid;

  // ---- Reset ----------------------------------------------------------------

  /// Forgets the current staff member completely. Runs on sign-out (see
  /// `AuthService.signOut`) and automatically on any identity change (see
  /// [bindToAuth]). Safe to call repeatedly.
  void clear() {
    final hadState = _ownerUid != null ||
        _context != null ||
        _status != StaffSessionStatus.signedOut ||
        _error != null;
    _generation++;
    _ownerUid = null;
    _context = null;
    _error = null;
    _inFlight = null;
    _inFlightUid = null;
    _status = StaffSessionStatus.signedOut;

    // Run even when nothing looked loaded: a hook may own state (e.g. a draft)
    // that was created before the context finished loading.
    for (final hook in List<VoidCallback>.of(_resetHooks)) {
      try {
        hook();
      } catch (e) {
        if (kDebugMode) debugPrint('Staff reset hook failed: ${e.runtimeType}');
      }
    }
    if (hadState) notifyListeners();
  }
}
