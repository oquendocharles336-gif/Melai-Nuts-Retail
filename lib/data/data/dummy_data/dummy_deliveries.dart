import '../models/delivery.dart';

/// Real delivery records — starts empty until connected to a backend.
final List<Delivery> kDeliveries = <Delivery>[];

List<Delivery> get activeDeliveries =>
    kDeliveries.where((d) => d.status.isActive).toList();

List<Delivery> get pastDeliveries =>
    kDeliveries.where((d) => !d.status.isActive).toList();
