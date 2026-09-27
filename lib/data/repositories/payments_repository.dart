import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../models/payment.dart';

/// Records real payment transactions in Supabase.
///
/// This app has no live payment-gateway integration (that requires a real
/// provider — e.g. PayMongo/Stripe/GCash for Business — and API keys/webhook
/// handling this project doesn't have yet). So rather than fake a "charging
/// card..." animation with a random success/failure roll, this repository
/// records exactly what actually happened: cash is recorded as pending
/// (collected in person), e-wallet/card payments are recorded pending until
/// a real gateway integration can confirm them. [markStatus] is the
/// integration point a future gateway webhook/SDK callback would call.
class PaymentsRepository {
  PaymentsRepository._();
  static final PaymentsRepository instance = PaymentsRepository._();

  SupabaseClient get _client => SupabaseService.instance.client;

  Future<PaymentTransaction> recordPayment({
    required String orderId,
    required String firebaseUid,
    required PaymentMethod method,
    required double amount,
    required String referenceNumber,
  }) async {
    final row = await _client
        .from('payments')
        .insert({
          'order_id': orderId,
          'firebase_uid': firebaseUid,
          'method': method.name,
          'status': 'pending',
          'amount': amount,
          'reference_number': referenceNumber,
        })
        .select()
        .single();
    return PaymentTransaction.fromRow(row);
  }

  /// Retries payment for an order that already has a payment record —
  /// `place_order` creates one atomically with every order, so by the time
  /// a customer reaches the "Pay Now" retry flow a row already exists.
  /// This UPDATEs that existing row (method, reference number, status back
  /// to pending) instead of inserting a second one, since `payments` has
  /// no unique constraint on `order_id` and a blind insert would silently
  /// leave two payment records for the same order. Falls back to
  /// [recordPayment] only for the edge case of an order with no payment
  /// row at all (e.g. one created before this table existed).
  Future<PaymentTransaction> retryPayment({
    required String orderId,
    required String firebaseUid,
    required PaymentMethod method,
    required double amount,
    required String referenceNumber,
  }) async {
    final row = await _client
        .from('payments')
        .update({
          'method': method.name,
          'reference_number': referenceNumber,
          'status': 'pending',
        })
        .eq('order_id', orderId)
        .select()
        .maybeSingle();
    if (row != null) return PaymentTransaction.fromRow(row);
    return recordPayment(
      orderId: orderId,
      firebaseUid: firebaseUid,
      method: method,
      amount: amount,
      referenceNumber: referenceNumber,
    );
  }

  Future<List<PaymentTransaction>> fetchAll(String firebaseUid) async {
    final raw = await _client
        .from('payments')
        .select()
        .eq('firebase_uid', firebaseUid)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(raw).map(PaymentTransaction.fromRow).toList();
  }

  Future<PaymentTransaction?> fetchForOrder(String orderId) async {
    final row = await _client.from('payments').select().eq('order_id', orderId).maybeSingle();
    return row == null ? null : PaymentTransaction.fromRow(row);
  }

  Future<PaymentTransaction> markStatus(String paymentId, PaymentStatus status) async {
    final row = await _client
        .from('payments')
        .update({'status': status.name})
        .eq('id', paymentId)
        .select()
        .single();
    return PaymentTransaction.fromRow(row);
  }
}
