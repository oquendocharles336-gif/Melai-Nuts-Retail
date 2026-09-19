import '../models/order.dart';
import '../models/refund.dart';
import 'dummy_orders.dart';

final List<RefundRequest> kRefundRequests = [
  RefundRequest(
    id: 'RFD-5521',
    orderId: kOrders[2].id,
    requestedDate: DateTime(2024, 10, 6, 9, 0),
    status: RefundStatus.completed,
    reason: kRefundReasons[0],
    notes: 'One box arrived with a torn seal.',
    items: kOrders[2].items,
    amount: kOrders[2].total,
    paymentMethod: kOrders[2].paymentMethod,
    timeline: const [
      OrderTimelineStep(label: 'Request Submitted', description: 'Refund request received', time: 'Oct 6, 9:00 AM', done: true),
      OrderTimelineStep(label: 'Under Review', description: 'Reviewed by branch staff', time: 'Oct 6, 3:20 PM', done: true),
      OrderTimelineStep(label: 'Approved', description: 'Refund approved by owner', time: 'Oct 7, 10:05 AM', done: true),
      OrderTimelineStep(label: 'Processing', description: 'Refund sent to GCash wallet', time: 'Oct 7, 10:10 AM', done: true),
      OrderTimelineStep(label: 'Refunded', description: '₱440 credited back', time: 'Oct 7, 10:32 AM', done: true),
    ],
  ),
  RefundRequest(
    id: 'RFD-6104',
    orderId: kOrders[3].id,
    requestedDate: DateTime(2024, 9, 23, 8, 15),
    status: RefundStatus.processing,
    reason: kRefundReasons[2],
    notes: 'Only received 2 of 3 pouches.',
    items: kOrders[3].items,
    amount: kOrders[3].total,
    paymentMethod: kOrders[3].paymentMethod,
    timeline: const [
      OrderTimelineStep(label: 'Request Submitted', description: 'Refund request received', time: 'Sep 23, 8:15 AM', done: true),
      OrderTimelineStep(label: 'Under Review', description: 'Reviewed by branch staff', time: 'Sep 23, 1:40 PM', done: true),
      OrderTimelineStep(label: 'Approved', description: 'Refund approved by owner', time: 'Sep 24, 9:00 AM', done: true),
      OrderTimelineStep(label: 'Processing', description: 'Refund being sent to payment method', time: 'Sep 24, 9:05 AM', current: true),
      OrderTimelineStep(label: 'Refunded', description: 'Awaiting completion', time: '—'),
    ],
  ),
  RefundRequest(
    id: 'RFD-6688',
    orderId: kOrders[1].id,
    requestedDate: DateTime(2024, 10, 19, 11, 0),
    status: RefundStatus.pending,
    reason: kRefundReasons[3],
    notes: 'Pickup was delayed past the promised time.',
    items: [kOrders[1].items.first],
    amount: kOrders[1].items.first.total,
    paymentMethod: kOrders[1].paymentMethod,
    timeline: const [
      OrderTimelineStep(label: 'Request Submitted', description: 'Refund request received', time: 'Oct 19, 11:00 AM', done: true, current: true),
      OrderTimelineStep(label: 'Under Review', description: 'Awaiting branch staff review', time: '—'),
      OrderTimelineStep(label: 'Approved', description: 'Pending', time: '—'),
      OrderTimelineStep(label: 'Processing', description: 'Pending', time: '—'),
      OrderTimelineStep(label: 'Refunded', description: 'Pending', time: '—'),
    ],
  ),
  RefundRequest(
    id: 'RFD-4310',
    orderId: kOrders[4].id,
    requestedDate: DateTime(2024, 9, 3, 10, 0),
    status: RefundStatus.rejected,
    reason: kRefundReasons[4],
    notes: 'Requested cancellation after dispatch.',
    items: kOrders[4].items,
    amount: kOrders[4].total,
    paymentMethod: kOrders[4].paymentMethod,
    timeline: const [
      OrderTimelineStep(label: 'Request Submitted', description: 'Refund request received', time: 'Sep 3, 10:00 AM', done: true),
      OrderTimelineStep(label: 'Under Review', description: 'Reviewed by branch staff', time: 'Sep 3, 4:30 PM', done: true),
      OrderTimelineStep(label: 'Rejected', description: 'Order was already out for delivery', time: 'Sep 4, 9:00 AM', done: true),
    ],
  ),
];

RefundRequest? findRefundByOrderId(String orderId) {
  for (final r in kRefundRequests) {
    if (r.orderId == orderId) return r;
  }
  return null;
}
