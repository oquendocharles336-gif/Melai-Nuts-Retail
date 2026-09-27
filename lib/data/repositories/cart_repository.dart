import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';

/// Persists the shopping cart to Supabase (`carts` / `cart_items`) so it
/// survives app restarts and follows the customer across devices. See
/// [CartController] for how this is used behind the existing synchronous
/// cart API.
class CartRepository {
  CartRepository._();
  static final CartRepository instance = CartRepository._();

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Returns the customer's open cart id, creating one if none exists.
  Future<String> getOrCreateOpenCartId(String firebaseUid) async {
    final existing = await _client
        .from('carts')
        .select('id')
        .eq('firebase_uid', firebaseUid)
        .eq('status', 'open')
        .maybeSingle();
    if (existing != null) return existing['id'] as String;

    final created = await _client
        .from('carts')
        .insert({'firebase_uid': firebaseUid})
        .select('id')
        .single();
    return created['id'] as String;
  }

  /// Fetches the persisted cart lines for [cartId], each row joined with
  /// its product/variant ids so [CartController] can rehydrate real
  /// [Product]/[ProductVariant] objects from the already-loaded catalog.
  Future<List<Map<String, dynamic>>> fetchItems(String cartId) async {
    final raw = await _client.from('cart_items').select().eq('cart_id', cartId);
    return List<Map<String, dynamic>>.from(raw);
  }

  Future<void> upsertLine({
    required String cartId,
    required String productId,
    String? variantId,
    required String variantLabel,
    required int quantity,
    required double unitPrice,
  }) async {
    await _client.from('cart_items').upsert(
      {
        'cart_id': cartId,
        'product_id': productId,
        'variant_id': variantId,
        'variant_label': variantLabel,
        'quantity': quantity,
        'unit_price': unitPrice,
      },
      onConflict: 'cart_id,product_id,variant_label',
    );
  }

  Future<void> removeLine({
    required String cartId,
    required String productId,
    required String variantLabel,
  }) async {
    await _client
        .from('cart_items')
        .delete()
        .eq('cart_id', cartId)
        .eq('product_id', productId)
        .eq('variant_label', variantLabel);
  }

  /// Empties [cartId] (used after a successful checkout).
  Future<void> clearCart(String cartId) async {
    await _client.from('cart_items').delete().eq('cart_id', cartId);
  }

  /// Marks [cartId] as checked out so the next add-to-cart opens a fresh one.
  Future<void> markCheckedOut(String cartId) async {
    await _client.from('carts').update({'status': 'checked_out'}).eq('id', cartId);
  }
}
