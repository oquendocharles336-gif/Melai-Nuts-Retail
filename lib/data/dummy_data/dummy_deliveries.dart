import '../models/delivery.dart';

/// Static, dummy delivery dispatches. No backend, no real routing/courier
/// API — [DeliveryStop.distanceFromPreviousKm] / travel times / ETAs are
/// simulated values only.
final DateTime _now = DateTime.now();

final List<Delivery> kDeliveries = [
  // The primary worked example: Branch → Customer A → Customer C →
  // Customer B. Originally requested in input order A, B, C; the
  // simulated optimizer reorders to A → C → B for a shorter simulated
  // route (see CreateDeliveryScreen for how this reorder is produced).
  Delivery(
    id: 'DEL-2026-0091',
    branch: 'Calamba Highway Branch',
    vehicle: 'Laguna Van #04',
    riderName: 'Juan Rider',
    createdAt: _now.subtract(const Duration(hours: 1)),
    status: DeliveryStatus.inTransit,
    stops: [
      DeliveryStop(
        id: 'stop-a',
        customerName: 'Customer A — Elena Dimaculangan',
        address: 'Unit 4B, Lakeside Residences, Calamba, Laguna',
        orderId: '#MLN-ORD-9284',
        items: const ['2x Garlic Peanuts 250g', '1x Spicy Skinless 250g'],
        sequenceIndex: 0,
        distanceFromPreviousKm: 3.2,
        travelMinutesFromPrevious: 9,
        eta: '1:15 PM',
        status: StopStatus.delivered,
      ),
      DeliveryStop(
        id: 'stop-c',
        customerName: 'Customer C — Ramon Cruz',
        address: 'Blk 12 Lot 4, Greenfields Subd., Calamba, Laguna',
        orderId: '#MLN-ORD-9301',
        items: const ['1x Family Pasalubong Box'],
        sequenceIndex: 1,
        distanceFromPreviousKm: 2.1,
        travelMinutesFromPrevious: 7,
        eta: '1:32 PM',
        status: StopStatus.enRoute,
      ),
      DeliveryStop(
        id: 'stop-b',
        customerName: 'Customer B — Ana Bautista',
        address: '88 Rizal St., Poblacion, Calamba, Laguna',
        orderId: '#MLN-ORD-9312',
        items: const ['3x Native Panutsa Sweet Peanuts'],
        sequenceIndex: 2,
        distanceFromPreviousKm: 4.6,
        travelMinutesFromPrevious: 13,
        eta: '1:55 PM',
        status: StopStatus.pending,
      ),
    ],
  ),
  Delivery(
    id: 'DEL-2026-0088',
    branch: 'Los Baños Hub',
    vehicle: 'Laguna Van #02',
    riderName: 'Mica Santos',
    createdAt: _now.subtract(const Duration(days: 1, hours: 2)),
    status: DeliveryStatus.completed,
    stops: [
      DeliveryStop(
        id: 'stop-d',
        customerName: 'UPLB Faculty Co-op',
        address: 'UPLB Campus, Los Baños, Laguna',
        orderId: '#MLN-ORD-9260',
        items: const ['5x Spicy Skinless Peanuts 250g'],
        sequenceIndex: 0,
        distanceFromPreviousKm: 1.8,
        travelMinutesFromPrevious: 6,
        eta: 'Yesterday, 3:10 PM',
        status: StopStatus.delivered,
      ),
      DeliveryStop(
        id: 'stop-e',
        customerName: 'Grace Manalo',
        address: 'Bayog, Los Baños, Laguna',
        orderId: '#MLN-ORD-9261',
        items: const ['2x Native Panutsa Sweet Peanuts'],
        sequenceIndex: 1,
        distanceFromPreviousKm: 3.5,
        travelMinutesFromPrevious: 10,
        eta: 'Yesterday, 3:32 PM',
        status: StopStatus.delivered,
      ),
    ],
  ),
  Delivery(
    id: 'DEL-2026-0075',
    branch: 'Santa Cruz Flagship',
    vehicle: 'Laguna Van #01',
    riderName: 'Mario Santos',
    createdAt: _now.subtract(const Duration(days: 3)),
    status: DeliveryStatus.cancelled,
    stops: [
      DeliveryStop(
        id: 'stop-f',
        customerName: 'Golden Kernel Wholesale Buyer',
        address: 'Poblacion Main Roaster, Santa Cruz, Laguna',
        orderId: '#MLN-ORD-9199',
        items: const ['10x Family Pasalubong Box'],
        sequenceIndex: 0,
        distanceFromPreviousKm: 0.9,
        travelMinutesFromPrevious: 4,
        eta: '3 days ago',
        status: StopStatus.skipped,
      ),
    ],
  ),
];

Delivery findDeliveryById(String id) =>
    kDeliveries.firstWhere((d) => d.id == id, orElse: () => kDeliveries.first);

List<Delivery> get activeDeliveries => kDeliveries.where((d) => d.status.isActive).toList();

List<Delivery> get pastDeliveries => kDeliveries.where((d) => !d.status.isActive).toList();
