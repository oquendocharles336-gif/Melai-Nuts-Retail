import '../models/inventory_batch.dart';
import '../models/inventory_item.dart';

/// Static, dummy multi-branch inventory used across the Inventory & FEFO
/// feature. No backend — quantities/dates here are for frontend preview
/// only.
final DateTime _now = DateTime.now();

final List<InventoryBatch> kInventoryBatches = [
  // --- Garlic Peanuts (p1) — the flagship worked example ---
  InventoryBatch(
    id: 'b1',
    productId: 'p1',
    batchCode: 'GP-001',
    branch: 'Santa Cruz Flagship',
    receivedDate: DateTime(2026, 6, 20),
    expirationDate: DateTime(2026, 9, 20),
    quantity: 25,
    restockThreshold: 30,
  ),
  InventoryBatch(
    id: 'b2',
    productId: 'p1',
    batchCode: 'GP-002',
    branch: 'Calamba Highway Branch',
    receivedDate: _now.subtract(const Duration(days: 10)),
    expirationDate: _now.add(const Duration(days: 60)),
    quantity: 48,
    restockThreshold: 30,
  ),
  InventoryBatch(
    id: 'b3',
    productId: 'p1',
    batchCode: 'GP-003',
    branch: 'Los Baños Hub',
    receivedDate: _now.subtract(const Duration(days: 40)),
    expirationDate: _now.add(const Duration(days: 8)),
    quantity: 12,
    restockThreshold: 25,
  ),

  // --- Spicy Skinless Peanuts (p2) ---
  InventoryBatch(
    id: 'b4',
    productId: 'p2',
    batchCode: 'SS-014',
    branch: 'Los Baños Hub',
    receivedDate: _now.subtract(const Duration(days: 5)),
    expirationDate: _now.add(const Duration(days: 30)),
    quantity: 18,
    restockThreshold: 20,
  ),
  InventoryBatch(
    id: 'b5',
    productId: 'p2',
    batchCode: 'SS-015',
    branch: 'Santa Cruz Flagship',
    receivedDate: _now.subtract(const Duration(days: 2)),
    expirationDate: _now.add(const Duration(days: 75)),
    quantity: 60,
    restockThreshold: 20,
  ),

  // --- Sweet Peanuts (p3) ---
  InventoryBatch(
    id: 'b6',
    productId: 'p3',
    batchCode: 'PT-008',
    branch: 'Calamba Highway Branch',
    receivedDate: _now.subtract(const Duration(days: 20)),
    expirationDate: _now.add(const Duration(days: 12)),
    quantity: 22,
    restockThreshold: 15,
  ),

  // --- Adobo Garlic Peanuts (p4) ---
  InventoryBatch(
    id: 'b7',
    productId: 'p4',
    batchCode: 'AG-021',
    branch: 'Santa Cruz Flagship',
    receivedDate: _now.subtract(const Duration(days: 1)),
    expirationDate: _now.add(const Duration(days: 90)),
    quantity: 54,
    restockThreshold: 20,
  ),
  InventoryBatch(
    id: 'b8',
    productId: 'p4',
    batchCode: 'AG-020',
    branch: 'Calamba Highway Branch',
    receivedDate: _now.subtract(const Duration(days: 25)),
    expirationDate: _now.add(const Duration(days: 5)),
    quantity: 6,
    restockThreshold: 20,
  ),

  // --- Native Panutsa Sweet Peanuts (p5) ---
  InventoryBatch(
    id: 'b9',
    productId: 'p5',
    batchCode: 'NP-011',
    branch: 'Los Baños Hub',
    receivedDate: _now.subtract(const Duration(days: 8)),
    expirationDate: _now.add(const Duration(days: 40)),
    quantity: 16,
    restockThreshold: 15,
  ),

  // --- Laguna Mixed Nuts Blend (p6) ---
  InventoryBatch(
    id: 'b10',
    productId: 'p6',
    batchCode: 'MX-006',
    branch: 'Santa Cruz Flagship',
    receivedDate: _now.subtract(const Duration(days: 15)),
    expirationDate: _now.add(const Duration(days: 55)),
    quantity: 33,
    restockThreshold: 20,
  ),

  // --- Family Pasalubong Box (p7) ---
  InventoryBatch(
    id: 'b11',
    productId: 'p7',
    batchCode: 'PB-004',
    branch: 'Calamba Highway Branch',
    receivedDate: _now.subtract(const Duration(days: 3)),
    expirationDate: _now.add(const Duration(days: 120)),
    quantity: 40,
    restockThreshold: 15,
  ),
  InventoryBatch(
    id: 'b12',
    productId: 'p7',
    batchCode: 'PB-003',
    branch: 'Los Baños Hub',
    receivedDate: _now.subtract(const Duration(days: 60)),
    expirationDate: _now.add(const Duration(days: 14)),
    quantity: 9,
    restockThreshold: 15,
  ),

  // --- Laguna Wild Honey Roasted Peanuts (p8) ---
  InventoryBatch(
    id: 'b13',
    productId: 'p8',
    batchCode: 'HR-009',
    branch: 'Santa Cruz Flagship',
    receivedDate: _now.subtract(const Duration(days: 12)),
    expirationDate: _now.add(const Duration(days: 25)),
    quantity: 14,
    restockThreshold: 15,
  ),
];

const List<String> kInventoryBranches = [
  'Santa Cruz Flagship',
  'Calamba Highway Branch',
  'Los Baños Hub',
];

List<InventoryBatch> batchesForProduct(String productId) =>
    kInventoryBatches.where((b) => b.productId == productId).toList();

List<InventoryBatch> batchesForBranch(String branch) =>
    kInventoryBatches.where((b) => b.branch == branch).toList();

List<InventoryBatch> get lowStockBatches =>
    kInventoryBatches.where((b) => b.isLowStock).toList();

List<InventoryBatch> batchesByPriority(FefoPriority priority) =>
    kInventoryBatches.where((b) => b.fefoPriority == priority).toList();

/// All batches sorted soonest-to-expire first (the core FEFO ordering).
List<InventoryBatch> get fefoSortedBatches {
  final list = List<InventoryBatch>.from(kInventoryBatches);
  list.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
  return list;
}

int totalStockFor(String productId) =>
    batchesForProduct(productId).fold(0, (sum, b) => sum + b.quantity);

/// Builds one [InventoryItem] per distinct product (aggregated across all
/// branches), for use on the Inventory List screen.
List<InventoryItem> get inventoryItemsByProduct {
  final productIds = kInventoryBatches.map((b) => b.productId).toSet();
  return [
    for (final id in productIds)
      InventoryItem(productId: id, batches: batchesForProduct(id)),
  ];
}

/// Builds one [InventoryItem] per distinct product at a single branch, for
/// use on the Branch Inventory screen.
List<InventoryItem> inventoryItemsForBranch(String branch) {
  final batches = batchesForBranch(branch);
  final productIds = batches.map((b) => b.productId).toSet();
  return [
    for (final id in productIds)
      InventoryItem(
        productId: id,
        branch: branch,
        batches: batches.where((b) => b.productId == id).toList(),
      ),
  ];
}
