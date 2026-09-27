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
  Future<Order> createOrderFromCart({
    required String cartId,
    required bool isDelivery,
    String? deliveryAddressId,
    required String paymentMethod,
    String customerNotes = '',
  }) async {
    String orderId;
    try {
      final result = await _client.rpc('place_order', params: {
        'p_cart_id': cartId,
        'p_is_delivery': isDelivery,
        'p_delivery_address_id': deliveryAddressId,
        'p_payment_method': paymentMethod,
        'p_customer_notes': customerNotes,
      });
      orderId = result as String;
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
    return refetch(orderId);
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
      final payment = await _fetchPayment(id);
      orders.add(Order.fromRow(
        row,
        itemRows: List<Map<String, dynamic>>.from(items),
        eventRows: events,
        paymentRow: payment,
      ));
    }
    return orders;
  }

  Future<Order> refetch(String orderId) async {
    final row = await _client.from('orders').select().eq('id', orderId).single();
    final items = await _client.from('order_items').select().eq('order_id', orderId);
    final events = await _fetchEvents(orderId);
    final payment = await _fetchPayment(orderId);
    return Order.fromRow(
      row,
      itemRows: List<Map<String, dynamic>>.from(items),
      eventRows: events,
      paymentRow: payment,
    );
  }

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

  Future<Map<String, dynamic>?> _fetchPayment(String orderId) async {
    return _client.from('payments').select().eq('order_id', orderId).maybeSingle();
  }
}
