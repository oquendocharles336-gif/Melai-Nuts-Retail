import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:melai_nuts/core/config/supabase_config.dart';
import 'package:melai_nuts/data/models/staff_context.dart';

Map<String, dynamic> _activePayload({
  String uid = 'staff-a',
  String role = 'staff',
  Object? branchId = '11111111-1111-1111-1111-111111111111',
  bool inventory = true,
  bool refunds = false,
}) =>
    {
      'status': 'active',
      'profile': {
        'firebase_uid': uid,
        'full_name': 'Staff A',
        'email': 'a@test.local',
        'role': role,
        'branch_id': branchId,
        'branch_name': 'Calamba Branch',
        'is_active': true,
        'can_manage_inventory': inventory,
        'can_review_refunds': refunds,
        'created_at': '2026-09-30T00:00:00Z',
      },
    };

String _jwtWithRole(String role) {
  String seg(Object o) => base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${seg({'alg': 'HS256'})}.${seg({'role': role})}.signature';
}

void main() {
  group('StaffContext.fromJson', () {
    test('parses profile, branch and permissions', () {
      final ctx = StaffContext.fromJson(_activePayload());
      expect(ctx.firebaseUid, 'staff-a');
      expect(ctx.fullName, 'Staff A');
      expect(ctx.branchId, '11111111-1111-1111-1111-111111111111');
      expect(ctx.branchName, 'Calamba Branch');
      expect(ctx.isOwner, isFalse);
      expect(ctx.can(StaffPermission.inventoryManage), isTrue);
      expect(ctx.can(StaffPermission.refundsReview), isFalse);
      expect(
        ctx.canAny([StaffPermission.refundsReview, StaffPermission.inventoryManage]),
        isTrue,
      );
    });

    test('permissions cannot be mutated after loading', () {
      final ctx = StaffContext.fromJson(_activePayload());
      expect(() => ctx.permissions.add(StaffPermission.refundsReview), throwsUnsupportedError);
      expect(ctx.can(StaffPermission.refundsReview), isFalse);
    });

    test('no flags means no permissions', () {
      final ctx = StaffContext.fromJson(_activePayload(inventory: false, refunds: false));
      expect(ctx.permissions, isEmpty);
    });

    test('an owner needs no branch', () {
      final ctx = StaffContext.fromJson(
        _activePayload(uid: 'owner-1', role: 'owner', branchId: null, inventory: true, refunds: true),
      );
      expect(ctx.isOwner, isTrue);
      expect(ctx.branchId, isNull);
    });

    test('rejects an incomplete payload instead of guessing', () {
      expect(() => StaffContext.fromJson({'status': 'active'}), throwsFormatException);
      expect(
        () => StaffContext.fromJson({
          ..._activePayload(),
          'profile': {'full_name': 'No uid', 'role': 'staff'},
        }),
        throwsFormatException,
      );
    });

    test('rejects staff without a branch and unknown roles', () {
      expect(() => StaffContext.fromJson(_activePayload(branchId: null)), throwsFormatException);
      expect(() => StaffContext.fromJson(_activePayload(role: 'admin')), throwsFormatException);
    });
  });

  group('SupabaseConfig.isPrivilegedKey', () {
    test('flags a service_role JWT', () {
      expect(SupabaseConfig.isPrivilegedKey(_jwtWithRole('service_role')), isTrue);
    });

    test('flags a new-style secret key', () {
      expect(SupabaseConfig.isPrivilegedKey('sb_secret_abc123'), isTrue);
    });

    test('allows the anon JWT and a publishable key', () {
      expect(SupabaseConfig.isPrivilegedKey(_jwtWithRole('anon')), isFalse);
      expect(SupabaseConfig.isPrivilegedKey('sb_publishable_abc123'), isFalse);
    });

    test('does not throw on garbage or empty input', () {
      expect(SupabaseConfig.isPrivilegedKey(''), isFalse);
      expect(SupabaseConfig.isPrivilegedKey('a.b.c'), isFalse);
      expect(SupabaseConfig.isPrivilegedKey('not a key'), isFalse);
    });
  });
}
