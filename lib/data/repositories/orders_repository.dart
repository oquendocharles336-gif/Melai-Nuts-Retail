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

  Future<Order> createOrder({
    required String firebaseUid,
    required String branchName,
    String? branchId,
    required bool isDelivery,
    String? deliveryAddressId,
    required List<OrderItem> items,
    required double subtotal,
    required double discount,
    required double deliveryFee,
    required double total,
    required String paymentMethod,
  }) async {
    final orderRow = await _client
        .from('orders')
        .insert({
          'firebase_uid': firebaseUid,
          'branch_id': branchId,
          'branch_name': branchName,
          'is_delivery': isDelivery,
          'delivery_address_id': deliveryAddressId,
          'status': 'pending',
          'subtotal': subtotal,
          'discount': discount,
          'delivery_fee': deliveryFee,
          'total': total,
          'payment_method': paymentMethod,
        })
        .select()
        .single();

    final orderId = orderRow['id'] as String;

    await _client.from('order_items').insert([
      for (final item in items)
        {
          'order_id': orderId,
          'product_name': item.productName,
          'variant_label': item.variantLabel,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
        },
    ]);

    final events = await _fetchEvents(orderId);
    return Order.fromRow(
      orderRow,
      itemRows: items.map((i) => {
            'product_name': i.productName,
            'variant_label': i.variantLabel,
            'quantity': i.quantity,
            'unit_price': i.unitPrice,
          }).toList(),
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
