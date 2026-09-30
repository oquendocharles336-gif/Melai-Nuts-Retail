import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/supabase_service.dart';
import '../../core/utils/app_error.dart';
import '../models/staff_context.dart';

/// What the server says about the signed-in account's staff standing.
enum StaffContextStatus {
  /// A staff profile exists and is active; [StaffContextResult.context] is set.
  active,

  /// A profile exists but an administrator deactivated it.
  inactive,

  /// The account is signed in but no staff profile has been created for it.
  notProvisioned,
}

class StaffContextResult {
  final StaffContextStatus status;
  final StaffContext? context;

  const StaffContextResult(this.status, [this.context]);
}

/// Reads the signed-in staff member's identity from Supabase.
///
/// Uses the existing shared Supabase client ([SupabaseService]), whose
/// `accessToken` hook attaches the caller's live Firebase ID token — the
/// server decides who is asking from that verified token, never from anything
/// this class sends.
///
/// Deliberately goes through the `get_my_staff_context()` RPC and NOT a table
/// read: `staff_members` is only readable for the caller's own row, and RPC
/// responses are never
/// stored by the offline read cache, so permissions can't be served stale from
/// disk after an administrator revokes them.
class StaffProfileRepository {
  StaffProfileRepository._();
  static final StaffProfileRepository instance = StaffProfileRepository._();

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Fetches the caller's staff context. [expectedUid] is the Firebase UID the
  /// caller believes is signed in; if the server answers for a different
  /// account (a token swapped mid-request) the result is rejected instead of
  /// being attributed to the wrong person.
  ///
  /// Throws [AppError] (customer-safe message) on network / auth / server
  /// failure. "Not provisioned" and "inactive" are normal results, not errors.
  Future<StaffContextResult> fetchMyContext({required String expectedUid}) async {
    final Object? raw = await AppErrors.guard<dynamic>(
      () => _client.rpc('get_my_staff_context'),
      scope: ErrorScope.profile,
      timeout: AppErrors.rpcTimeout,
    );

    if (raw is! Map) throw _malformed();
    final json = Map<String, dynamic>.from(raw);

    switch (json['status']) {
      case 'not_provisioned':
        return const StaffContextResult(StaffContextStatus.notProvisioned);
      case 'inactive':
        return const StaffContextResult(StaffContextStatus.inactive);
      case 'active':
        final StaffContext context;
        try {
          context = StaffContext.fromJson(json);
        } on FormatException {
          throw _malformed();
        }
        if (context.firebaseUid != expectedUid) {
          throw const AppError(
            AppErrorKind.authExpired,
            'Your session is out of date. Please sign in again.',
          );
        }
        return StaffContextResult(StaffContextStatus.active, context);
      default:
        throw _malformed();
    }
  }

  AppError _malformed() => const AppError(
        AppErrorKind.invalidData,
        'We received some unexpected data. Please try again.',
      );
}
