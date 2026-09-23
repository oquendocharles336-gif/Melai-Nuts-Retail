import '../models/delivery.dart';

/// TEMPORARY PLACEHOLDER DATA — see dummy_products.dart for context.
/// Replace with real delivery data from a backend before shipping.

final DateTime _now = DateTime.now();

final List<Delivery> kDeliveries = [
  Delivery(
    id: 'DEL-2041',
    branch: 'Santa Cruz Main',
    vehicle: 'Motorcycle - SCM-01',
    riderName: 'Juan Rider',
    createdAt: _now.subtract(const Duration(hours: 1)),
    status: DeliveryStatus.inTransit,
    stops: [
      DeliveryStop(
        id: 'stop-1',
        customerName: 'Ana Reyes',
        address: 'Purok 3, Brgy. Poblacion, Santa Cruz',
        orderId: 'ORD-1005',
        items: const ['Garlic Peanuts x2', 'Classic Roasted Peanuts x1'],
        sequenceIndex: 0,
        distanceFromPreviousKm: 1.8,
        travelMinutesFromPrevious: 7,
        eta: '2:50 PM',
        status: StopStatus.enRoute,
      ),
      DeliveryStop(
        id: 'stop-2',
        customerName: 'Marco Dela Cruz',
        address: 'Brgy. San Jose, Santa Cruz',
        orderId: 'ORD-0998',
        items: const ['Honey Glazed Peanuts x1'],
        sequenceIndex: 1,
        distanceFromPreviousKm: 2.4,
        travelMinutesFromPrevious: 9,
        eta: '3:05 PM',
        status: StopStatus.pending,
      ),
    ],
  ),
  Delivery(
    id: 'DEL-2038',
    branch: 'Calamba Branch',
    vehicle: 'Motorcycle - CAL-02',
    riderName: 'Pia Santos',
    createdAt: _now.subtract(const Duration(hours: 3)),
    status: DeliveryStatus.dispatched,
    stops: [
      DeliveryStop(
        id: 'stop-3',
        customerName: 'Liza Fernandez',
        address: 'Brgy. Real, Calamba',
        orderId: 'ORD-0991',
        items: const ['Honey Cashews x1'],
        sequenceIndex: 0,
        distanceFromPreviousKm: 3.1,
        travelMinutesFromPrevious: 11,
        eta: '4:10 PM',
        status: StopStatus.pending,
      ),
    ],
  ),
  Delivery(
    id: 'DEL-2020',
    branch: 'Santa Cruz Main',
    vehicle: 'Motorcycle - SCM-01',
    riderName: 'Juan Rider',
    createdAt: _now.subtract(const Duration(days: 1)),
    status: DeliveryStatus.completed,
    stops: [
      DeliveryStop(
        id: 'stop-4',
        customerName: 'Carlo Villanueva',
        address: 'Brgy. Bubukal, Santa Cruz',
        orderId: 'ORD-1004',
        items: const ['Honey Glazed Peanuts x3'],
        sequenceIndex: 0,
        distanceFromPreviousKm: 2.0,
        travelMinutesFromPrevious: 8,
        eta: '11:20 AM',
        status: StopStatus.delivered,
      ),
    ],
  ),
  Delivery(
    id: 'DEL-2015',
    branch: 'Los Baños Hub',
    vehicle: 'Motorcycle - LB-01',
    riderName: 'Ella Ramos',
    createdAt: _now.subtract(const Duration(days: 3)),
    status: DeliveryStatus.completed,
    stops: [
      DeliveryStop(
        id: 'stop-5',
        customerName: 'Noel Aquino',
        address: 'Brgy. Batong Malake, Los Baños',
        orderId: 'ORD-1003',
        items: const ['Chili Garlic Peanuts x2', 'Classic Roasted Peanuts x1'],
        sequenceIndex: 0,
        distanceFromPreviousKm: 1.5,
        travelMinutesFromPrevious: 6,
        eta: '1:05 PM',
        status: StopStatus.delivered,
      ),
    ],
  ),
];

List<Delivery> get activeDeliveries =>
    kDeliveries.where((d) => d.status.isActive).toList();

List<Delivery> get pastDeliveries =>
    kDeliveries.where((d) => !d.status.isActive).toList();
