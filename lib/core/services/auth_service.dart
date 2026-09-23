import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/app_user.dart';
import '../../data/models/user_role.dart';
import '../../features/customer/cart_controller.dart';
import '../constants/app_constants.dart';
import 'data_sync_service.dart';

/// A user-facing authentication failure. The [message] is already written
/// to be shown directly in a SnackBar/dialog — no FirebaseAuthException
/// codes leak past this service.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// In-memory brake on repeated failures (exponential back-off after a few
/// free attempts). This is a UX / accidental-hammering brake only — it lives
/// on the device and can be bypassed by a modified client. The real
/// enforcement is Firebase Auth's server-side throttling
/// (`too-many-requests`); see SECURITY.md.
class _FailureBrake {
  static const int freeAttempts = 5;
  static const Duration baseDelay = Duration(seconds: 30);
  static const Duration maxDelay = Duration(minutes: 5);

  int _failures = 0;
  DateTime? _lockedUntil;

  Duration? get remaining {
    final until = _lockedUntil;
    if (until == null) return null;
    final left = until.difference(DateTime.now());
    if (left.isNegative) {
      _lockedUntil = null;
      return null;
    }
    return left;
  }

  void recordFailure() {
    _failures++;
    if (_failures >= freeAttempts) {
      final int exp = (_failures - freeAttempts).clamp(0, 4).toInt();
      var delay = baseDelay * (1 << exp);
      if (delay > maxDelay) delay = maxDelay;
      _lockedUntil = DateTime.now().add(delay);
    }
  }

  void reset() {
    _failures = 0;
    _lockedUntil = null;
  }
}

/// Wraps Firebase Authentication + the `users` Firestore collection so every
/// screen (customer, staff, owner, delivery) goes through one real,
/// validated sign-in / sign-up path.
///
/// Firestore is the source of truth for *who someone is* (their name, role,
/// branch, and whether an admin has deactivated them) — Firebase Auth only
/// proves *that* they own the email + password. [signIn] always checks both.
///
/// OFFLINE: Firebase Auth itself persists the signed-in session on the device
/// (a refresh token managed by the SDK — this app never stores or sees the
/// password). After a restart with no network, that persisted session plus the
/// Firestore-cached profile lets a *previously authenticated* user keep
/// working. There is deliberately NO custom offline-login mechanism: nobody
/// can "log in" offline without an existing Firebase session.
///
/// AUTHORIZATION: role checks in Dart (this file, route guards, hidden
/// buttons) are a UX layer. The real enforcement is `firestore.rules`.
class AuthService {
  AuthService._() {
    // Drop the cached profile whenever the Firebase identity goes away or changes.
    _auth.authStateChanges().listen((user) {
      if (user == null || user.uid != _currentProfile?.uid) {
        _currentProfile = null;
      }
    });
  }
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _usersCollection = 'users';

  final _FailureBrake _signInBrake = _FailureBrake();
  final Map<String, DateTime> _lastResetRequest = {};
  static const Duration _resetCooldown = Duration(seconds: 60);

  AppUser? _currentProfile;

  /// True once the *user* has chosen to sign out, until the next sign-in.
  /// Route guards use it to avoid hijacking the logout flow's own navigation.
  bool _userInitiatedSignOut = false;
  bool get userInitiatedSignOut => _userInitiatedSignOut;

  /// Fires whenever the signed-in Firebase user changes (sign in, sign out,
  /// session invalidated).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentFirebaseUser => _auth.currentUser;

  /// The validated profile (role, branch, active flag) of the signed-in user,
  /// or `null` if nobody is signed in / it has not been loaded yet. Only ever
  /// set after [_loadAndValidateProfile] succeeded.
  AppUser? get currentProfile => _currentProfile;

  /// Loads the Firestore profile for the currently signed-in Firebase user,
  /// or `null` if nobody is signed in. Throws [AuthException] if the
  /// account is signed in but has no matching/active profile (and signs it
  /// out), so callers never route a "ghost" session into a portal.
  Future<AppUser?> loadCurrentProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _loadAndValidateProfile(user.uid);
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    _throwIfBraked(_signInBrake);
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        throw const AuthException('Sign-in failed. Please try again.');
      }
      final profile = await _loadAndValidateProfile(uid);
      _signInBrake.reset();
      _userInitiatedSignOut = false;
      return profile;
    } on FirebaseAuthException catch (e) {
      if (e.code != 'network-request-failed') _signInBrake.recordFailure();
      throw AuthException(_messageFor(e));
    }
  }

  /// Self-service registration — customers only. Staff, owner, and delivery
  /// accounts are provisioned by an owner via [createManagedAccount].
  /// The role is fixed to `customer` here and again by Firestore rules; a
  /// modified client cannot self-register as anything else.
  Future<AppUser> registerCustomer({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Account creation failed. Please try again.');
      }
      try {
        await user.updateDisplayName(name.trim());

        final appUser = AppUser(
          uid: user.uid,
          // Use the identity Firebase actually recorded (it normalises case);
          // Firestore rules require the profile email to match it.
          email: user.email ?? email.trim(),
          name: name.trim(),
          role: UserRole.customer,
          phone: phone.trim(),
          isActive: true,
        );
        await _firestore
            .collection(_usersCollection)
            .doc(user.uid)
            .set(appUser.toFirestore(serverTimestamp: true));
        _currentProfile = appUser;
        _userInitiatedSignOut = false;
        return appUser;
      } on FirebaseException {
        // Roll back so no sign-in exists without a profile.
        try {
          await user.delete();
        } catch (_) {}
        throw const AuthException(
          'We could not finish creating your account. Please try again.',
        );
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  /// Owner-only: creates a staff / owner / delivery account.
  ///
  /// Creating a Firebase Auth user normally signs that user in on the
  /// current app instance, which would kick the owner out of their own
  /// session. To avoid that, this runs the creation on a short-lived
  /// secondary [FirebaseApp] instance and tears it down immediately after,
  /// so the owner's session is never touched.
  ///
  /// Authorization: this method refuses non-owners, but that is only a UX
  /// check. `firestore.rules` allows creating a non-customer profile ONLY for
  /// an active owner, so a modified client cannot mint privileged accounts.
  /// NOTE: creating the Auth user itself is still client-side (anyone with the
  /// public API key can create an *Auth* user, but without a profile document
  /// that user is rejected at sign-in and by the rules). Moving this to a
  /// Cloud Function with the Admin SDK is the stronger long-term design.
  Future<AppUser> createManagedAccount({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
    String? branch,
  }) async {
    _requireActiveOwner();
    if (role == UserRole.customer) {
      throw const AuthException(
        'Customers create their own account from the Customer Access screen.',
      );
    }
    final needsBranch = role == UserRole.staff || role == UserRole.delivery;
    if (needsBranch && (branch == null || !AppConstants.branches.contains(branch))) {
      throw const AuthException('Please select a valid branch.');
    }

    final tempAppName = 'melai_nuts_admin_create_${DateTime.now().microsecondsSinceEpoch}';
    final tempApp = await Firebase.initializeApp(
      name: tempAppName,
      options: Firebase.app().options,
    );
    try {
      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
      final credential = await tempAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final newUser = credential.user;
      if (newUser == null) {
        throw const AuthException('Account creation failed. Please try again.');
      }
      try {
        await newUser.updateDisplayName(name.trim());

        final appUser = AppUser(
          uid: newUser.uid,
          email: newUser.email ?? email.trim(),
          name: name.trim(),
          role: role,
          phone: phone?.trim(),
          branch: needsBranch ? branch : null,
          isActive: true,
        );
        await _firestore
            .collection(_usersCollection)
            .doc(newUser.uid)
            .set(appUser.toFirestore(serverTimestamp: true));
        await tempAuth.signOut();
        return appUser;
      } on FirebaseException {
        // Roll back the half-created Auth user (still signed in on tempAuth).
        try {
          await newUser.delete();
        } catch (_) {}
        throw const AuthException(
          'Could not save the new account. Please try again.',
        );
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    } finally {
      await tempApp.delete();
    }
  }

  /// Sets whether a managed (non-customer) account can sign in. This is a
  /// soft-delete: [signIn] rejects any profile with `isActive == false`, and
  /// `firestore.rules` stops honouring an inactive user's role immediately,
  /// even if their device still holds a valid session.
  /// Actually deleting the Firebase Auth user requires the Admin SDK.
  Future<void> setAccountActive(String uid, bool isActive) async {
    _requireActiveOwner();
    await _firestore.collection(_usersCollection).doc(uid).update({
      'isActive': isActive,
    });
  }

  /// Live list of every managed (staff/owner/delivery) account, for the
  /// owner's User Management screen. Firestore rules only serve this to owners.
  Stream<List<AppUser>> watchManagedAccounts() {
    return _firestore
        .collection(_usersCollection)
        .where('role', whereIn: [
      UserRole.staff.name,
      UserRole.owner.name,
      UserRole.delivery.name,
    ])
        .snapshots()
        .map((snap) => snap.docs.map(AppUser.fromFirestore).toList());
  }

  /// Sends a password-reset email. To avoid revealing which emails have
  /// accounts, an unknown address behaves exactly like a known one.
  Future<void> sendPasswordResetEmail(String email) async {
    final key = email.trim().toLowerCase();
    final last = _lastResetRequest[key];
    if (last != null && DateTime.now().difference(last) < _resetCooldown) {
      throw const AuthException(
        'A reset link was just requested. Please wait a minute before trying again.',
      );
    }
    _lastResetRequest[key] = DateTime.now();
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return; // do not reveal account existence
      _lastResetRequest.remove(key); // request failed; allow a retry
      throw AuthException(_messageFor(e));
    }
  }

  /// Changes the password of the currently signed-in user (used by the
  /// "Login & Security" > Change Password flow, as opposed to
  /// [sendPasswordResetEmail] which is for someone who's locked out).
  /// Firebase requires a *recent* sign-in for this; if the session is too
  /// old it throws an [AuthException] asking the person to sign in again.
  /// Changing a password also invalidates the user's other sessions.
  Future<void> changePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('You need to be signed in to change your password.');
    }
    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw const AuthException(
          'For your security, please sign out and sign in again before changing your password.',
        );
      }
      throw AuthException(_messageFor(e));
    }
  }

  /// Signs out of Firebase and clears everything held in memory for the
  /// previous user. Queued offline writes are flushed first (while still
  /// authenticated) on a best-effort basis; the on-disk Firestore cache is
  /// wiped on the next app start (see [DataSyncService.initializeLocalDatabase]).
  Future<void> signOut() async {
    _userInitiatedSignOut = true;
    _currentProfile = null;
    CartController.instance.clear();
    await DataSyncService.instance.syncPendingWrites();
    await _auth.signOut();
  }

  Future<AppUser> _loadAndValidateProfile(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> doc;
    try {
      doc = await _firestore.collection(_usersCollection).doc(uid).get();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied' || e.code == 'unauthenticated') {
        await signOut();
        throw const AuthException(
          'Your session is no longer valid. Please sign in again.',
        );
      }
      // Offline with nothing cached, timeouts, etc.: fail closed, keep session.
      throw const AuthException(
        'We could not verify your account right now. Please check your connection and try again.',
      );
    }

    if (!doc.exists) {
      await signOut();
      throw const AuthException(
        'No account profile found. Please contact your administrator.',
      );
    }

    final AppUser appUser;
    try {
      appUser = AppUser.fromFirestore(doc);
    } on FormatException {
      await signOut();
      throw const AuthException(
        'This account is misconfigured. Please contact your administrator.',
      );
    }

    if (!appUser.isActive) {
      await signOut();
      throw const AuthException(
        'This account has been deactivated. Please contact your administrator.',
      );
    }
    _currentProfile = appUser;
    return appUser;
  }

  void _requireActiveOwner() {
    final caller = _currentProfile;
    if (caller == null || caller.role != UserRole.owner || !caller.isActive) {
      throw const AuthException('Only an active owner can do this.');
    }
  }

  void _throwIfBraked(_FailureBrake brake) {
    final left = brake.remaining;
    if (left != null) {
      final secs = left.inSeconds + 1;
      final wait = secs >= 60 ? '${(secs / 60).ceil()} minute(s)' : '$secs seconds';
      throw AuthException('Too many attempts. Please wait $wait and try again.');
    }
  }

  String _messageFor(FirebaseAuthException e) {
    // Debug builds only: log the code and Firebase's error text (which names
    // console/config problems such as CONFIGURATION_NOT_FOUND). Never logged
    // in release, and never includes the email or password.
    if (kDebugMode) {
      debugPrint('FirebaseAuthException code: ${e.code} | ${e.message}');
    }
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact your administrator.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'That password is too weak. Please choose a stronger one.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      case 'user-token-expired':
      case 'requires-recent-login':
        return 'Your session has expired. Please sign in again.';
      case 'internal-error':
      case 'operation-not-allowed':
        return 'This sign-in method is not available right now. Please try again later.';
      default:
      // Never surface raw SDK messages: they can contain internal details.
        return 'Something went wrong. Please try again.';
    }
  }
}