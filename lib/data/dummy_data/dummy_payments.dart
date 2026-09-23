import '../models/payment.dart';

/// TEMPORARY PLACEHOLDER DATA — see dummy_products.dart for context.
/// Replace with real payment data from a backend before shipping.

final DateTime _now = DateTime.now();

final List<PaymentTransaction> kPayments = [
  PaymentTransaction(
    id: 'PAY-5005',
    orderId: 'ORD-1005',
    date: _now.subtract(const Duration(minutes: 42)),
    method: PaymentMethod.gcash,
    status: PaymentStatus.success,
    amount: 329,
    referenceNumber: 'GC-88213456',
  ),
  PaymentTransaction(
    id: 'PAY-5004',
    orderId: 'ORD-1004',
    date: _now.subtract(const Duration(days: 1, hours: 3)),
    method: PaymentMethod.cash,
    status: PaymentStatus.success,
    amount: 210,
    referenceNumber: 'CASH-POS-4021',
  ),
  PaymentTransaction(
    id: 'PAY-5003',
    orderId: 'ORD-1003',
    date: _now.subtract(const Duration(days: 3)),
    method: PaymentMethod.maya,
    status: PaymentStatus.success,
    amount: 435,
    referenceNumber: 'MY-77102938',
  ),
  PaymentTransaction(
    id: 'PAY-5002',
    orderId: 'ORD-1002',
    date: _now.subtract(const Duration(days: 6)),
    method: PaymentMethod.gcash,
    status: PaymentStatus.failed,
    amount: 169,
    referenceNumber: 'GC-88198221',
  ),
];

/// Returns the payment transaction for [orderId], or null if none exists
/// (matches how a real backend lookup would behave).
PaymentTransaction? findPaymentByOrderId(String orderId) {
  for (final p in kPayments) {
    if (p.orderId == orderId) return p;
  }
  return null;
}
