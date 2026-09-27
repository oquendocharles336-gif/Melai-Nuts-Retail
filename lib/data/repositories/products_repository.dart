import 'package:melai_nuts/data/catalog_store.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/supabase_service.dart';
import '../dummy_data/dummy_promotions.dart';
import '../models/product.dart';
import '../models/promotion.dart';

/// Loads the public product catalog (categories, products, variants, and
/// per-branch stock) from Supabase and keeps [kProducts]/[kProductCategories]
/// in sync — every existing customer/owner/staff screen that already reads
/// those globals picks the real data up automatically, with no further
/// changes needed on their end.
class ProductsRepository {
  ProductsRepository._();
  static final ProductsRepository instance = ProductsRepository._();

  bool _loading = false;

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Fetches categories + products + variants + stock and replaces the
  /// contents of [kProductCategories]/[kProducts] in place.
  ///
  /// When [branchId] is given, stock and branch-availability are scoped to
  /// that one branch's `branch_inventory` rows — this is what
  /// [BranchController.selectBranch] calls so switching branches updates
  /// real product availability/stock everywhere `kProducts` is read. With
  /// no [branchId] (the app-boot default, before any branch is chosen),
  /// stock is aggregated across every active branch, as before.
  Future<void> loadCatalog({String? branchId}) async {
    if (_loading) return;
    _loading = true;
    try {
      final categoriesRaw = await _client
          .from('product_categories')
          .select()
          .order('sort_order');
      final branchesRaw = await _client.from('branches').select().eq('is_active', true);
      final productsRaw = await _client
          .from('products')
          .select()
          .eq('is_active', true)
          .order('name');
      final variantsRaw = await _client
          .from('product_variants')
          .select()
          .order('sort_order');
      final inventoryRaw = branchId == null
          ? await _client.from('branch_inventory').select()
          : await _client.from('branch_inventory').select().eq('branch_id', branchId);

      final branchNameById = <String, String>{
        for (final b in List<Map<String, dynamic>>.from(branchesRaw)) b['id'] as String: b['name'] as String,
      };

      final variantsByProduct = <String, List<Map<String, dynamic>>>{};
      for (final v in List<Map<String, dynamic>>.from(variantsRaw)) {
        variantsByProduct.putIfAbsent(v['product_id'] as String, () => []).add(v);
      }

      // Stock per variant id, total stock per product (regardless of
      // whether a row is tied to a specific variant), and which branches
      // carry each product at all.
      final stockByVariant = <String, int>{};
      final stockByProduct = <String, int>{};
      final branchesByProduct = <String, Set<String>>{};
      for (final inv in List<Map<String, dynamic>>.from(inventoryRaw)) {
        final variantId = inv['variant_id'] as String?;
        final productId = inv['product_id'] as String;
        final qty = inv['quantity'] as int;
        if (variantId != null) {
          stockByVariant[variantId] = (stockByVariant[variantId] ?? 0) + qty;
        }
        stockByProduct[productId] = (stockByProduct[productId] ?? 0) + qty;
        if (qty > 0) {
          final branchName = branchNameById[inv['branch_id'] as String];
          if (branchName != null) {
            branchesByProduct.putIfAbsent(productId, () => {}).add(branchName);
          }
        }
      }

      final products = List<Map<String, dynamic>>.from(productsRaw).map((row) {
        final id = row['id'] as String;
        return Product.fromRow(
          row,
          variantRows: variantsByProduct[id] ?? const [],
          stockByVariantId: stockByVariant,
          branchAvailability: (branchesByProduct[id] ?? const <String>{}).toList()..sort(),
          totalStock: stockByProduct[id] ?? 0,
        );
      }).toList();

      final categories = List<Map<String, dynamic>>.from(categoriesRaw)
          .map(ProductCategory.fromRow)
          .toList();

      kProductCategories
        ..clear()
        ..addAll(categories);
      kProducts
        ..clear()
        ..addAll(products);

      // These depend on `products` already being populated above, and are
      // each independently best-effort: a failure in either must not wipe
      // out the catalog we just loaded.
      await Future.wait([
        _loadPromotions(),
        _loadPopularProducts(),
      ]);
    } catch (_) {
      // Offline or the schema isn't set up yet — leave whatever's already
      // cached (the fallback categories, and any previously loaded
      // products) so the storefront's existing empty-state UI handles it
      // gracefully instead of crashing.
    } finally {
      _loading = false;
    }
  }

  /// Fetches active, in-date-window promo banners for the Home dashboard.
  /// Never fabricates a banner: on any failure [kPromotions] is just left
  /// empty (or whatever was last loaded), which the Home screen treats as
  /// "no promo section right now".
  Future<void> _loadPromotions() async {
    try {
      final raw = await _client
          .from('promotions')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      final now = DateTime.now();
      final promotions = List<Map<String, dynamic>>.from(raw).where((row) {
        final startsAt = row['starts_at'] as String?;
        final endsAt = row['ends_at'] as String?;
        if (startsAt != null && DateTime.parse(startsAt).isAfter(now)) return false;
        if (endsAt != null && DateTime.parse(endsAt).isBefore(now)) return false;
        return true;
      }).map(Promotion.fromRow).toList();
      kPromotions
        ..clear()
        ..addAll(promotions);
    } catch (_) {
      // Leave kPromotions as-is; Home hides the section when it's empty.
    }
  }

  /// Ranks the just-loaded [kProducts] by real units sold (via the
  /// `get_popular_products` RPC, which aggregates across every branch and
  /// every customer's orders — data no single customer's RLS grant can see
  /// directly). Falls back to staff-curated [Product.isFeatured] products,
  /// then to the first few active products, only when nothing has sold yet
  /// (e.g. a brand-new store) rather than leaving the section empty.
  Future<void> _loadPopularProducts() async {
    List<Product> ranked = const [];
    try {
      final raw = await _client.rpc('get_popular_products', params: {'p_limit': 8});
      final rows = List<Map<String, dynamic>>.from(raw as List);
      final byId = {for (final p in kProducts) p.id: p};
      ranked = rows
          .map((r) => byId[r['product_id'] as String])
          .whereType<Product>()
          .toList();
    } catch (_) {
      // RPC not available yet (older schema) or offline — fall through.
    }

    if (ranked.isEmpty) {
      ranked = kProducts.where((p) => p.isFeatured).toList();
    }
    if (ranked.isEmpty) {
      ranked = kProducts.take(4).toList();
    }

    kPopularProducts
      ..clear()
      ..addAll(ranked);
  }

  /// Public list of active branches (for the branch picker on Cart/Checkout).
  Future<List<String>> fetchBranchNames() async {
    try {
      final raw = await _client.from('branches').select('name').eq('is_active', true).order('name');
      return List<Map<String, dynamic>>.from(raw).map((r) => r['name'] as String).toList();
    } catch (_) {
      return const [];
    }
  }
}
