import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../dummy_data/dummy_branches.dart';
import '../models/branch.dart';

/// Loads the real branch list (`branches` table) into [kBranches].
///
/// Branches are public read data (any signed-in or guest customer needs to
/// see them to pick one), same as the product catalog.
class BranchRepository {
  BranchRepository._();
  static final BranchRepository instance = BranchRepository._();

  SupabaseClient get _client => SupabaseService.instance.client;

  bool _loading = false;

  /// Fetches every branch and refreshes [kBranches] in place. Safe to call
  /// repeatedly (e.g. pull-to-refresh on the branch picker); concurrent
  /// calls collapse into one in-flight request.
  Future<void> loadBranches() async {
    if (_loading) return;
    _loading = true;
    try {
      final raw = await _client.from('branches').select().order('name');
      final branches = List<Map<String, dynamic>>.from(raw).map(Branch.fromRow).toList();
      kBranches
        ..clear()
        ..addAll(branches);
    } catch (_) {
      // Offline or schema not migrated yet — leave whatever's cached so the
      // branch picker's existing empty-state UI handles it.
    } finally {
      _loading = false;
    }
  }

  Branch? findById(String id) {
    for (final b in kBranches) {
      if (b.id == id) return b;
    }
    return null;
  }
}
