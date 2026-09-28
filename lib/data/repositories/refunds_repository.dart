import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../models/order.dart';
import '../models/refund.dart';

/// Creates and reads real refund requests in Supabase (`refund_requests` /
/// `refund_items` / `refund_status_events`). Customers can submit a request
/// (via the server-side `request_refund` function) and watch its status; only
/// staff/owner tooling can move it forward — customers have read-only access
/// to these tables.
class RefundsRepository {
  RefundsRepository._();
  static final RefundsRepository instance = RefundsRepository._();

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Submits a refund through the `request_refund` database function.
  ///
  /// The client only says WHICH order, WHICH lines/quantities and WHY. The
  /// server verifies the order belongs to the signed-in customer and is
  /// completed, prices every line from the order itself, computes the refund
  /// amount and payment method, and always starts the request as `pending`.
  /// Nothing the app sends can influence the amount or the status, so a
  /// modified client cannot ask for more than was paid or approve its own
  /// request. The returned [RefundRequest] carries the server's real values.
  Future<RefundRequest> submitRequest({
    required String orderId,
    required String reason,
    required String notes,
    required List<OrderItem> items,
  }) async {
    final String refundId;
    try {
      final result = await _client.rpc('request_refund', params: {
        'p_order_id': orderId,
        'p_reason': reason,
        'p_notes': notes,
        'p_items': [
          for (final item in items)
            {
              'product_name': item.productName,
              'variant_label': item.variantLabel,
              'quantity': item.quantity,
            },
        ],
      });
      refundId = result as String;
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
    return refetch(refundId);
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
