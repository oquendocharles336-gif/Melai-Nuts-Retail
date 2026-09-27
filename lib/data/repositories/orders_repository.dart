import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../models/order.dart';

/// Creates and reads real orders in Supabase (`orders` / `order_items` /
/// `order_status_events`). Points are awarded and the initial status event
/// is logged entirely by database triggers (see supabase/schema.sql) — this
/// repository never computes or writes `points_earned` itself.
class OrdersRepository {
  OrdersRepository._();
  static final OrdersRepository instance = OrdersRepository._();

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Places the order through the `place_order` Postgres function instead
  /// of inserting `orders`/`order_items` directly. That function is the
  /// only place stock is genuinely, atomically checked and decremented for
  /// real: it locks each item's `branch_inventory` row, rejects the whole
  /// order (nothing is written) if any line now asks for more than what's
  /// actually on the shelf at [branchId] or the product has since gone
  /// inactive, and otherwise decrements stock and creates the order in one
  /// transaction. This is the "trust the server, not the client's cached
  /// stock number" step for checkout — the app never assumes the catalog
  /// it loaded a few screens ago is still accurate.
  ///
  /// Throws with a customer-readable message (e.g. "Only 2 of Roasted
  /// Cashew left at this branch") when a line can no longer be fulfilled.
  Future<Order> createOrder({
    required String firebaseUid,
    required String branchName,
    required String branchId,
    required bool isDelivery,
    String? deliveryAddressId,
    required List<OrderItem> items,
    required double subtotal,
    required double discount,
    required double deliveryFee,
    required double total,
    required String paymentMethod,
  }) async {
    String orderId;
    try {
      final result = await _client.rpc('place_order', params: {
        'p_firebase_uid': firebaseUid,
        'p_branch_id': branchId,
        'p_branch_name': branchName,
        'p_is_delivery': isDelivery,
        'p_delivery_address_id': deliveryAddressId,
        'p_items': [
          for (final item in items)
            {
              'product_id': item.productId,
              'variant_id': item.variantId,
              'product_name': item.productName,
              'variant_label': item.variantLabel,
              'quantity': item.quantity,
              'unit_price': item.unitPrice,
            },
        ],
        'p_subtotal': subtotal,
        'p_discount': discount,
        'p_delivery_fee': deliveryFee,
        'p_total': total,
        'p_payment_method': paymentMethod,
      });
      orderId = result as String;
    } on PostgrestException catch (e) {
      // Re-throw with just the human-readable message the `place_order`
      // function raised (e.g. a stock/availability check failing) — the
      // Postgres error code/detail noise isn't useful to the customer.
      throw Exception(e.message);
    }

    final orderRow = await _client.from('orders').select().eq('id', orderId).single();
    final itemRows = await _client.from('order_items').select().eq('order_id', orderId);
    final events = await _fetchEvents(orderId);
    return Order.fromRow(
      orderRow,
      itemRows: List<Map<String, dynamic>>.from(itemRows),
      eventRows: events,
    );
  }

  Future<List<Order>> fetchOrders(String firebaseUid) async {
    final raw = await _client
        .from('orders')
        .select()
        .eq('firebase_uid', firebaseUid)
        .order('created_at', ascending: false);
    final orders = <Order>[];
    for (final row in List<Map<String, dynamic>>.from(raw)) {
      final id = row['id'] as String;
      final items = await _client.from('order_items').select().eq('order_id', id);
      final events = await _fetchEvents(id);
      orders.add(Order.fromRow(row, itemRows: List<Map<String, dynamic>>.from(items), eventRows: events));
    }
    return orders;
  }

  /// Re-fetches a single order (used by the tracking screen to pull the
  /// latest real status after a realtime change notification).
  Future<Order> refetch(String orderId) async {
    final row = await _client.from('orders').select().eq('id', orderId).single();
    final items = await _client.from('order_items').select().eq('order_id', orderId);
    final events = await _fetchEvents(orderId);
    return Order.fromRow(row, itemRows: List<Map<String, dynamic>>.from(items), eventRows: events);
  }

  /// Live updates for one order's row — reflects real status changes made
  /// by staff/delivery tooling as they happen, no polling required.
  Stream<List<Map<String, dynamic>>> watchOrder(String orderId) {
    return _client.from('orders').stream(primaryKey: ['id']).eq('id', orderId);
  }

  Future<List<Map<String, dynamic>>> _fetchEvents(String orderId) async {
    final raw = await _client
        .from('order_status_events')
        .select()
        .eq('order_id', orderId)
        .order('created_at');
    return List<Map<String, dynamic>>.from(raw);
  }
}
