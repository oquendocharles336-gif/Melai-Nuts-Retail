import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../models/order.dart';

class OrdersRepository {
  OrdersRepository._();
  static final OrdersRepository instance = OrdersRepository._();

  SupabaseClient get _client => SupabaseService.instance.client;

  Future<Order> createOrderFromCart({
    required String cartId,
    required bool isDelivery,
    String? deliveryAddressId,
    required String paymentMethod,
  }) async {
    String orderId;
    try {
      final result = await _client.rpc('place_order', params: {
        'p_cart_id': cartId,
        'p_is_delivery': isDelivery,
        'p_delivery_address_id': deliveryAddressId,
        'p_payment_method': paymentMethod,
      });
      orderId = result as String;
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }

    final row = await _client.from('orders').select().eq('id', orderId).single();
    final items = await _client.from('order_items').select().eq('order_id', orderId);
    final events = await _fetchEvents(orderId);
    return Order.fromRow(
      row,
      itemRows: List<Map<String, dynamic>>.from(items),
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
      orders.add(Order.fromRow(
        row,
        itemRows: List<Map<String, dynamic>>.from(items),
        eventRows: events,
      ));
    }
    return orders;
  }

  Future<Order> refetch(String orderId) async {
    final row = await _client.from('orders').select().eq('id', orderId).single();
    final items = await _client.from('order_items').select().eq('order_id', orderId);
    final events = await _fetchEvents(orderId);
    return Order.fromRow(
      row,
      itemRows: List<Map<String, dynamic>>.from(items),
      eventRows: events,
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
}
