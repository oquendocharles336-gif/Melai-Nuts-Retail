import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../data/models/app_user.dart';
import '../../data/models/user_role.dart';

/// A user-facing authentication failure. The [message] is already written
/// to be shown directly in a SnackBar/dialog — no FirebaseAuthException
/// codes leak past this service.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Wraps Firebase Authentication + the `users` Firestore collection so every
/// screen (customer, staff, owner, delivery) goes through one real,
/// validated sign-in / sign-up path instead of the old dummy-account lookup.
///
/// Firestore is the source of truth for *who someone is* (their name, role,
/// branch, and whether an admin has deactivated them) — Firebase Auth only
/// proves *that* they own the email + password. [signIn] always checks both.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _usersCollection = 'users';

  /// Fires whenever the signed-in Firebase user changes (sign in, sign out,
  /// token refresh across app restarts). Use this for the splash-screen
  /// auth gate rather than checking [currentFirebaseUser] once.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentFirebaseUser => _auth.currentUser;

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
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        throw const AuthException('Sign-in failed. Please try again.');
      }
      return await _loadAndValidateProfile(uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  /// Self-service registration — customers only. Staff, owner, and delivery
  /// accounts are provisioned by an owner via [createManagedAccount].
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
      final uid = credential.user?.uid;
      if (uid == null) {
        throw const AuthException('Account creation failed. Please try again.');
      }
      await credential.user!.updateDisplayName(name.trim());

      final appUser = AppUser(
        uid: uid,
        email: email.trim(),
        name: name.trim(),
        role: UserRole.customer,
        phone: phone.trim(),
        isActive: true,
      );
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .set(appUser.toFirestore(serverTimestamp: true));
      return appUser;
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
  /// NOTE: this is a client-side workaround suitable for early development.
  /// Because any signed-in owner's device can call this directly, it should
  /// be paired with a Firestore rule that only lets `role == 'owner'`
  /// accounts write to `users/*` with a non-customer role (see the security
  /// rules provided alongside this change), and ideally moved to a Cloud
  /// Function with the Admin SDK before this ships to real users.
  Future<AppUser> createManagedAccount({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
    String? branch,
  }) async {
    if (role == UserRole.customer) {
      throw const AuthException(
        'Customers create their own account from the Customer Access screen.',
      );
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
      final uid = credential.user?.uid;
      if (uid == null) {
        throw const AuthException('Account creation failed. Please try again.');
      }
      await credential.user!.updateDisplayName(name.trim());

      final appUser = AppUser(
        uid: uid,
        email: email.trim(),
        name: name.trim(),
        role: role,
        phone: phone?.trim(),
        branch: branch,
        isActive: true,
      );
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .set(appUser.toFirestore(serverTimestamp: true));
      await tempAuth.signOut();
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    } finally {
      await tempApp.delete();
    }
  }

  /// Sets whether a managed (non-customer) account can sign in. This is a
  /// soft-delete: [signIn] rejects any profile with `isActive == false`.
  /// Actually deleting the Firebase Auth user requires the Admin SDK.
  Future<void> setAccountActive(String uid, bool isActive) async {
    await _firestore.collection(_usersCollection).doc(uid).update({
      'isActive': isActive,
    });
  }

  /// Live list of every managed (staff/owner/delivery) account, for the
  /// owner's User Management screen.
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

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    }
  }

  /// Changes the password of the currently signed-in user (used by the
  /// "Login & Security" > Change Password flow, as opposed to
  /// [sendPasswordResetEmail] which is for someone who's locked out).
  /// Firebase requires a *recent* sign-in for this; if the session is too
  /// old it throws an [AuthException] asking the person to sign in again.
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

  Future<void> signOut() => _auth.signOut();

  Future<AppUser> _loadAndValidateProfile(String uid) async {
    final doc = await _firestore.collection(_usersCollection).doc(uid).get();
    if (!doc.exists) {
      await _auth.signOut();
      throw const AuthException(
        'No account profile found. Please contact your administrator.',
      );
    }

    final AppUser appUser;
    try {
      appUser = AppUser.fromFirestore(doc);
    } on FormatException {
      await _auth.signOut();
      throw const AuthException(
        'This account is misconfigured. Please contact your administrator.',
      );
    }

    if (!appUser.isActive) {
      await _auth.signOut();
      throw const AuthException(
        'This account has been deactivated. Please contact your administrator.',
      );
    }
    return appUser;
  }

  String _messageFor(FirebaseAuthException e) {
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
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}