import '../models/payment.dart';
import 'dummy_orders.dart';

final List<PaymentTransaction> kPaymentTransactions = [
  PaymentTransaction(
    id: 'PAY-91284',
    orderId: kOrders[0].id,
    date: DateTime(2024, 10, 26, 12, 48),
    method: PaymentMethod.gcash,
    status: PaymentStatus.success,
    amount: kOrders[0].total,
    referenceNumber: 'GC-88213321',
  ),
  PaymentTransaction(
    id: 'PAY-88841',
    orderId: kOrders[1].id,
    date: DateTime(2024, 10, 18, 10, 43),
    method: PaymentMethod.cash,
    status: PaymentStatus.success,
    amount: kOrders[1].total,
    referenceNumber: 'CASH-COUNTER',
  ),
  PaymentTransaction(
    id: 'PAY-88210',
    orderId: kOrders[2].id,
    date: DateTime(2024, 10, 4, 15, 11),
    method: PaymentMethod.gcash,
    status: PaymentStatus.refunded,
    amount: kOrders[2].total,
    referenceNumber: 'GC-77104432',
  ),
  PaymentTransaction(
    id: 'PAY-87310',
    orderId: kOrders[4].id,
    date: DateTime(2024, 9, 2, 11, 31),
    method: PaymentMethod.gcash,
    status: PaymentStatus.failed,
    amount: kOrders[4].total,
    referenceNumber: 'GC-70099123',
  ),
];

PaymentTransaction? findPaymentByOrderId(String orderId) {
  for (final p in kPaymentTransactions) {
    if (p.orderId == orderId) return p;
  }
  return null;
}
