import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../models/order.dart';

class OrdersRepository {
  OrdersRepository._();
  static final OrdersRepository instance = OrdersRepository._();

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Places the order via the `place_order` RPC. Stock validation, pricing,
  /// the order/order_items rows, the loyalty redemption, and now the
  /// payment record too are all created atomically inside that single
  /// database transaction — this method never writes to
  /// `orders`/`order_items`/`payments`/`branch_inventory` directly, so a
  /// dropped connection partway through can never leave a half-created
  /// order behind.
  ///
  /// [idempotencyKey], when given, must stay the same across every retry of
  /// one checkout attempt (the caller generates it once per attempt — see
  /// `CheckoutScreen`). If a previous call with the same key already
  /// committed an order (the request succeeded but the response never made
  /// it back — a dropped connection, a killed app, a flaky network — this
  /// is genuinely indistinguishable from "it failed" without one), this
  /// returns that same order instead of creating a second one. Safe to omit
  /// for calls that are known not to be a retry.
  Future<Order> createOrderFromCart({
    required String cartId,
    required bool isDelivery,
    String? deliveryAddressId,
    required String paymentMethod,
    String customerNotes = '',
    String? idempotencyKey,
  }) async {
    String orderId;
    try {
      final result = await _client.rpc('place_order', params: {
        'p_cart_id': cartId,
        'p_is_delivery': isDelivery,
        'p_delivery_address_id': deliveryAddressId,
        'p_payment_method': paymentMethod,
        'p_customer_notes': customerNotes,
        'p_idempotency_key': idempotencyKey,
      });
      orderId = result as String;
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
    return refetch(orderId);
  }

  /// Columns fetched with every order: the order row plus its line items,
  /// status history and payment, in ONE round trip (PostgREST embedded
  /// resources) instead of three extra queries per order.
  static const String _orderSelect =
      '*, order_items(*), order_status_events(*), payments(*)';

  Future<List<Order>> fetchOrders(String firebaseUid) async {
    final raw = await _client
        .from('orders')
        .select(_orderSelect)
        .eq('firebase_uid', firebaseUid)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(raw).map(_orderFromEmbeddedRow).toList();
  }

  Future<Order> refetch(String orderId) async {
    final row = await _client.from('orders').select(_orderSelect).eq('id', orderId).single();
    return _orderFromEmbeddedRow(row);
  }

  Stream<List<Map<String, dynamic>>> watchOrder(String orderId) {
    return _client.from('orders').stream(primaryKey: ['id']).eq('id', orderId);
  }

  Order _orderFromEmbeddedRow(Map<String, dynamic> row) {
    final events = _rows(row['order_status_events'])
      ..sort((a, b) => (a['created_at'] as String).compareTo(b['created_at'] as String));
    final payments = _rows(row['payments']);
    return Order.fromRow(
      row,
      itemRows: _rows(row['order_items']),
      eventRows: events,
      paymentRow: payments.isEmpty ? null : payments.first,
    );
  }

  /// An embedded resource comes back as a list for one-to-many and as a
  /// single object (or null) for one-to-one — normalise both to a list.
  List<Map<String, dynamic>> _rows(dynamic value) {
    if (value == null) return <Map<String, dynamic>>[];
    if (value is Map) return [Map<String, dynamic>.from(value)];
    return List<Map<String, dynamic>>.from(value as List);
  }
}
