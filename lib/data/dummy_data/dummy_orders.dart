import '../models/order.dart';

/// Static, dummy order history for the signed-in demo customer.
final List<Order> kOrders = [
  Order(
    id: '#MLN-ORD-9284',
    date: DateTime(2024, 10, 26, 13, 25),
    status: OrderStatus.outForDelivery,
    branch: 'Los Baños Hub',
    isDelivery: true,
    riderName: 'Rider Kuya Mark',
    etaLabel: '15–20 mins',
    items: const [
      OrderItem(
        productName: 'Garlic Peanuts',
        variantLabel: '250g Standup Pouch',
        quantity: 2,
        unitPrice: 140,
      ),
      OrderItem(
        productName: 'Spicy Skinless Peanuts',
        variantLabel: '250g Jar Pack',
        quantity: 1,
        unitPrice: 65,
      ),
      OrderItem(
        productName: 'Family Pasalubong Box',
        variantLabel: 'Gift Set Assorted',
        quantity: 1,
        unitPrice: 205,
      ),
    ],
    discount: 5,
    deliveryFee: 45,
    paymentMethod: 'GCash',
    pointsEarned: 54,
    timeline: const [
      OrderTimelineStep(
        label: 'Pending',
        description: 'Order received at central desk',
        time: '12:45 PM',
        done: true,
      ),
      OrderTimelineStep(
        label: 'Confirmed',
        description: 'Payment settled via GCash POS',
        time: '12:48 PM',
        done: true,
      ),
      OrderTimelineStep(
        label: 'Preparing & Packed',
        description: 'Freshly vacuum sealed & packed',
        time: '1:05 PM',
        done: true,
      ),
      OrderTimelineStep(
        label: 'Out for Delivery',
        description: 'Dispatched in temperature-controlled bin',
        time: '1:25 PM',
        current: true,
      ),
      OrderTimelineStep(
        label: 'Completed',
        description: 'Handover & digital signature',
        time: 'Est. 1:45 PM',
      ),
    ],
  ),
  Order(
    id: '#MLN-ORD-8841',
    date: DateTime(2024, 10, 18, 10, 42),
    status: OrderStatus.completed,
    branch: 'Calamba Highway Branch',
    isDelivery: false,
    items: const [
      OrderItem(
        productName: 'Garlic Peanuts',
        variantLabel: '250g Standup Pouch',
        quantity: 2,
        unitPrice: 140,
      ),
      OrderItem(
        productName: 'Spicy Skinless Peanuts',
        variantLabel: '250g Jar Pack',
        quantity: 1,
        unitPrice: 65,
      ),
    ],
    deliveryFee: 0,
    paymentMethod: 'Cash Counter',
    pointsEarned: 34,
  ),
  Order(
    id: '#MLN-ORD-8210',
    date: DateTime(2024, 10, 4, 15, 10),
    status: OrderStatus.completed,
    branch: 'Santa Cruz Flagship',
    isDelivery: true,
    items: const [
      OrderItem(
        productName: 'Family Pasalubong Box',
        variantLabel: 'Gift Set Assorted',
        quantity: 2,
        unitPrice: 220,
      ),
    ],
    deliveryFee: 0,
    paymentMethod: 'GCash',
    pointsEarned: 44,
  ),
  Order(
    id: '#MLN-ORD-7692',
    date: DateTime(2024, 9, 22, 9, 5),
    status: OrderStatus.completed,
    branch: 'Los Baños Hub',
    isDelivery: false,
    items: const [
      OrderItem(
        productName: 'Native Panutsa Sweet Peanuts',
        variantLabel: '120g Pouch',
        quantity: 3,
        unitPrice: 60,
      ),
    ],
    deliveryFee: 0,
    paymentMethod: 'Cash Counter',
    pointsEarned: 18,
  ),
  Order(
    id: '#MLN-ORD-7310',
    date: DateTime(2024, 9, 2, 11, 30),
    status: OrderStatus.cancelled,
    branch: 'Calamba Highway Branch',
    isDelivery: true,
    items: const [
      OrderItem(
        productName: 'Sweet Peanuts (Panutsa Glazed)',
        variantLabel: '120g Pouch',
        quantity: 1,
        unitPrice: 60,
      ),
    ],
    deliveryFee: 45,
    paymentMethod: 'GCash',
    pointsEarned: 0,
  ),
];

Order findOrderById(String id) =>
    kOrders.firstWhere((o) => o.id == id, orElse: () => kOrders.first);

Order? get activeOrder {
  for (final o in kOrders) {
    if (o.status.isActive) return o;
  }
  return null;
}
