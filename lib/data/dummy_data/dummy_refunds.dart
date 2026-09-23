import '../models/order.dart';
import '../models/refund.dart';

/// TEMPORARY PLACEHOLDER DATA — see dummy_products.dart for context.
/// Replace with real refund data from a backend before shipping.

final DateTime _now = DateTime.now();

final List<RefundRequest> kRefundRequests = [
  RefundRequest(
    id: 'REF-3002',
    orderId: 'ORD-1002',
    requestedDate: _now.subtract(const Duration(days: 5)),
    status: RefundStatus.completed,
    reason: 'Order Arrived Too Late',
    notes: 'Rider got stuck in traffic, customer no longer wanted the order.',
    items: const [
      OrderItem(productName: 'Honey Cashews', variantLabel: '100g Retail Foil', quantity: 1, unitPrice: 120),
    ],
    amount: 169,
    paymentMethod: 'GCash E-Wallet',
    timeline: [
      OrderTimelineStep(label: 'Requested', description: 'Refund request submitted.', time: 'Sep 18, 2:10 PM', done: true),
      OrderTimelineStep(label: 'Approved', description: 'Approved by branch staff.', time: 'Sep 18, 3:00 PM', done: true),
      OrderTimelineStep(label: 'Processing', description: 'Refund sent to payment provider.', time: 'Sep 19, 9:00 AM', done: true),
      OrderTimelineStep(label: 'Refunded', description: 'Funds returned to customer.', time: 'Sep 19, 4:00 PM', done: true),
    ],
  ),
  RefundRequest(
    id: 'REF-3001',
    orderId: 'ORD-0980',
    requestedDate: _now.subtract(const Duration(days: 12)),
    status: RefundStatus.rejected,
    reason: 'Changed My Mind',
    notes: 'Outside the 24-hour refund window.',
    items: const [
      OrderItem(productName: 'Classic Roasted Peanuts', variantLabel: '500g Family Pack', quantity: 1, unitPrice: 250),
    ],
    amount: 250,
    paymentMethod: 'Cash on Pickup',
    timeline: [
      OrderTimelineStep(label: 'Requested', description: 'Refund request submitted.', time: 'Sep 11, 10:00 AM', done: true),
      OrderTimelineStep(label: 'Rejected', description: 'Request fell outside policy window.', time: 'Sep 11, 4:00 PM', done: true, current: true),
    ],
  ),
];
