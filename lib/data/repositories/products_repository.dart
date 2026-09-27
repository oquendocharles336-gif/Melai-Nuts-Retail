import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../dummy_data/dummy_products.dart';
import '../models/product.dart';

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
  Future<void> loadCatalog() async {
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
      final inventoryRaw = await _client.from('branch_inventory').select();

      final branchNameById = <String, String>{
        for (final b in List<Map<String, dynamic>>.from(branchesRaw)) b['id'] as String: b['name'] as String,
      };

      final variantsByProduct = <String, List<Map<String, dynamic>>>{};
      for (final v in List<Map<String, dynamic>>.from(variantsRaw)) {
        variantsByProduct.putIfAbsent(v['product_id'] as String, () => []).add(v);
      }

      // stock per variant id, and which branches carry each product at all.
      final stockByVariant = <String, int>{};
      final branchesByProduct = <String, Set<String>>{};
      for (final inv in List<Map<String, dynamic>>.from(inventoryRaw)) {
        final variantId = inv['variant_id'] as String?;
        final productId = inv['product_id'] as String;
        final qty = inv['quantity'] as int;
        if (variantId != null) {
          stockByVariant[variantId] = (stockByVariant[variantId] ?? 0) + qty;
        }
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
        );
      }).toList();

      final categories = List<Map<String, dynamic>>.from(categoriesRaw)
          .map(ProductCategory.fromRow)
          .toList();

      if (categories.isNotEmpty) {
        kProductCategories
          ..clear()
          ..addAll(categories);
      }
      kProducts
        ..clear()
        ..addAll(products);
    } catch (_) {
      // Offline or the schema isn't set up yet — leave whatever's already
      // cached (the fallback categories, and any previously loaded
      // products) so the storefront's existing empty-state UI handles it
      // gracefully instead of crashing.
    } finally {
      _loading = false;
    }
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
