/// The Supabase-side identity of a signed-in staff member or owner: who they
/// are, which branch they work at, and what they are allowed to do.
///
/// This is the answer to `get_my_staff_context()` (see
/// supabase/migrations/20260930000000_staff_backend.sql), keyed by the Firebase
/// UID and backed by the single `staff_members` registry:
///
///   Firebase UID  ->  staff_members row  ->  branch  +  permissions
///
/// SECURITY: everything here is a UX convenience (hide a button, pick a
/// default branch filter). The database re-checks the same rules on every
/// request (`_require_staff`, `staff_has_permission()`, RLS), so editing this
/// object on a modified device grants nothing.
library;

import 'staff_models.dart';

/// Permission keys the app checks. They are derived from the flags on
/// `staff_members` (owners hold all of them); the database enforces the same
/// rules independently through `staff_has_permission('inventory' | 'refunds')`.
class StaffPermission {
  StaffPermission._();

  static const String inventoryManage = 'inventory.manage';
  static const String refundsReview = 'refunds.review';
}

/// Profile + permissions for one staff member or owner, loaded in a single
/// atomic server read so they can never disagree with each other.
class StaffContext {
  /// The Firebase UID this context belongs to.
  final String firebaseUid;
  final StaffProfile profile;

  /// Unmodifiable set of granted permission keys (see [StaffPermission]).
  final Set<String> permissions;

  /// When this context was fetched from the server.
  final DateTime loadedAt;

  StaffContext({
    required this.firebaseUid,
    required this.profile,
    DateTime? loadedAt,
  })  : permissions = Set<String>.unmodifiable(<String>{
          if (profile.canManageInventory) StaffPermission.inventoryManage,
          if (profile.canReviewRefunds) StaffPermission.refundsReview,
        }),
        loadedAt = loadedAt ?? DateTime.now();

  bool get isOwner => profile.isOwner;
  String? get branchId => profile.branchId;
  String? get branchName => profile.branchName;
  String get fullName => profile.fullName;

  bool can(String permission) => permissions.contains(permission);

  bool canAny(Iterable<String> candidates) => candidates.any(permissions.contains);

  /// Parses the `active` payload of `get_my_staff_context()`. Throws a
  /// [FormatException] on anything malformed rather than guessing — a partial
  /// profile must never be treated as a valid one.
  factory StaffContext.fromJson(Map<String, dynamic> json) {
    final raw = json['profile'];
    if (raw is! Map) throw const FormatException('Staff context is incomplete.');
    final p = Map<String, dynamic>.from(raw);
    final uid = p['firebase_uid'];
    final role = p['role'];
    if (uid is! String || uid.isEmpty || p['full_name'] is! String) {
      throw const FormatException('Staff profile is incomplete.');
    }
    if (role != 'staff' && role != 'owner') {
      throw const FormatException('Staff role is unknown.');
    }
    // Staff must be tied to a branch; only owners may have none.
    if (role == 'staff' && (p['branch_id'] is! String || (p['branch_id'] as String).isEmpty)) {
      throw const FormatException('Staff profile has no branch.');
    }
    return StaffContext(firebaseUid: uid, profile: StaffProfile.fromJson(p));
  }
}
