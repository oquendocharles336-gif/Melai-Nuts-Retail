import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../models/order.dart';
import '../models/refund.dart';

/// Creates and reads real refund requests in Supabase (`refund_requests` /
/// `refund_items` / `refund_status_events`). Customers can submit a request
/// and watch its status; only staff/owner tooling (out of scope here) can
/// move it forward — there is no "advance my own refund" button.
class RefundsRepository {
  RefundsRepository._();
  static final RefundsRepository instance = RefundsRepository._();

  SupabaseClient get _client => SupabaseService.instance.client;

  Future<RefundRequest> submitRequest({
    required String orderId,
    required String firebaseUid,
    required String reason,
    required String notes,
    required List<OrderItem> items,
    required double amount,
    required String paymentMethod,
  }) async {
    final row = await _client
        .from('refund_requests')
        .insert({
          'order_id': orderId,
          'firebase_uid': firebaseUid,
          'reason': reason,
          'notes': notes,
          'amount': amount,
          'payment_method': paymentMethod,
        })
        .select()
        .single();

    final refundId = row['id'] as String;
    await _client.from('refund_items').insert([
      for (final item in items)
        {
          'refund_request_id': refundId,
          'product_name': item.productName,
          'variant_label': item.variantLabel,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
        },
    ]);

    final events = await _fetchEvents(refundId);
    return RefundRequest.fromRow(
      row,
      itemRows: items
          .map((i) => {
                'product_name': i.productName,
                'variant_label': i.variantLabel,
                'quantity': i.quantity,
                'unit_price': i.unitPrice,
              })
          .toList(),
      eventRows: events,
    );
  }

  Future<List<RefundRequest>> fetchAll(String firebaseUid) async {
    final raw = await _client
        .from('refund_requests')
        .select()
        .eq('firebase_uid', firebaseUid)
        .order('created_at', ascending: false);
    final requests = <RefundRequest>[];
    for (final row in List<Map<String, dynamic>>.from(raw)) {
      final id = row['id'] as String;
      final items = await _client.from('refund_items').select().eq('refund_request_id', id);
      final events = await _fetchEvents(id);
      requests.add(RefundRequest.fromRow(
        row,
        itemRows: List<Map<String, dynamic>>.from(items),
        eventRows: events,
      ));
    }
    return requests;
  }

  Stream<List<Map<String, dynamic>>> watchRequest(String refundId) {
    return _client.from('refund_requests').stream(primaryKey: ['id']).eq('id', refundId);
  }

  Future<RefundRequest> refetch(String refundId) async {
    final row = await _client.from('refund_requests').select().eq('id', refundId).single();
    final items = await _client.from('refund_items').select().eq('refund_request_id', refundId);
    final events = await _fetchEvents(refundId);
    return RefundRequest.fromRow(row, itemRows: List<Map<String, dynamic>>.from(items), eventRows: events);
  }

  Future<List<Map<String, dynamic>>> _fetchEvents(String refundId) async {
    final raw = await _client
        .from('refund_status_events')
        .select()
        .eq('refund_request_id', refundId)
        .order('created_at');
    return List<Map<String, dynamic>>.from(raw);
  }
}
