import '../models/order.dart';

/// TEMPORARY PLACEHOLDER DATA — see dummy_products.dart for context.
/// Replace `kOrders` with real order data from a backend before shipping.

final List<Order> kOrders = [
  Order(
    id: 'ORD-1005',
    date: DateTime.now().subtract(const Duration(minutes: 40)),
    status: OrderStatus.outForDelivery,
    branch: 'Santa Cruz Main',
    isDelivery: true,
    items: const [
      OrderItem(productName: 'Garlic Peanuts', variantLabel: '250g Standup Pouch', quantity: 2, unitPrice: 140),
      OrderItem(productName: 'Classic Roasted Peanuts', variantLabel: '100g Retail Foil', quantity: 1, unitPrice: 55),
    ],
    deliveryFee: 49,
    paymentMethod: 'GCash E-Wallet',
    pointsEarned: 33,
    riderName: 'Juan Rider',
    etaLabel: '15-20 min',
    timeline: [
      OrderTimelineStep(label: 'Order Placed', description: 'We received your order.', time: '2:10 PM', done: true),
      OrderTimelineStep(label: 'Confirmed', description: 'Branch confirmed your order.', time: '2:12 PM', done: true),
      OrderTimelineStep(label: 'Preparing', description: 'Packing your items.', time: '2:20 PM', done: true),
      OrderTimelineStep(label: 'Out for Delivery', description: 'Juan is on the way.', time: '2:35 PM', done: true, current: true),
      const OrderTimelineStep(label: 'Delivered', description: 'Awaiting delivery confirmation.', time: ''),
    ],
  ),
  Order(
    id: 'ORD-1004',
    date: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    status: OrderStatus.completed,
    branch: 'Calamba Branch',
    isDelivery: false,
    items: const [
      OrderItem(productName: 'Honey Glazed Peanuts', variantLabel: '100g Retail Foil', quantity: 3, unitPrice: 70),
    ],
    deliveryFee: 0,
    paymentMethod: 'Cash on Pickup',
    pointsEarned: 21,
  ),
  Order(
    id: 'ORD-1003',
    date: DateTime.now().subtract(const Duration(days: 3)),
    status: OrderStatus.completed,
    branch: 'Los Baños Hub',
    isDelivery: true,
    items: const [
      OrderItem(productName: 'Chili Garlic Peanuts', variantLabel: '100g Retail Foil', quantity: 2, unitPrice: 68),
      OrderItem(productName: 'Classic Roasted Peanuts', variantLabel: '500g Family Pack', quantity: 1, unitPrice: 250),
    ],
    discount: 20,
    deliveryFee: 49,
    paymentMethod: 'Maya Wallet',
    pointsEarned: 38,
  ),
  Order(
    id: 'ORD-1002',
    date: DateTime.now().subtract(const Duration(days: 6)),
    status: OrderStatus.cancelled,
    branch: 'Santa Cruz Main',
    isDelivery: true,
    items: const [
      OrderItem(productName: 'Honey Cashews', variantLabel: '100g Retail Foil', quantity: 1, unitPrice: 120),
    ],
    deliveryFee: 49,
    paymentMethod: 'GCash E-Wallet',
    pointsEarned: 0,
  ),
];

/// The customer's current in-progress order, or null if none is active.
Order? get activeOrder {
  for (final order in kOrders) {
    if (order.status.isActive) return order;
  }
  return null;
}
