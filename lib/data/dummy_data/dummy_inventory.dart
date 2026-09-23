import '../../core/constants/app_constants.dart';
import '../models/inventory_batch.dart';
import '../models/inventory_item.dart';

/// TEMPORARY PLACEHOLDER DATA — see dummy_products.dart for context.
/// Replace with real inventory data from a backend before shipping.

const List<String> kInventoryBranches = AppConstants.branches;

final DateTime _now = DateTime.now();

final List<InventoryBatch> kInventoryBatches = [
  // Garlic Peanuts (p-garlic-100)
  InventoryBatch(
    id: 'b-001',
    productId: 'p-garlic-100',
    batchCode: 'GP-0921A',
    branch: 'Santa Cruz Main',
    receivedDate: _now.subtract(const Duration(days: 20)),
    expirationDate: _now.add(const Duration(days: 10)),
    quantity: 18,
    restockThreshold: 20,
  ),
  InventoryBatch(
    id: 'b-002',
    productId: 'p-garlic-100',
    batchCode: 'GP-0925B',
    branch: 'Calamba Branch',
    receivedDate: _now.subtract(const Duration(days: 5)),
    expirationDate: _now.add(const Duration(days: 60)),
    quantity: 85,
    restockThreshold: 20,
  ),
  InventoryBatch(
    id: 'b-003',
    productId: 'p-garlic-100',
    batchCode: 'GP-0910C',
    branch: 'Los Baños Hub',
    receivedDate: _now.subtract(const Duration(days: 30)),
    expirationDate: _now.add(const Duration(days: 40)),
    quantity: 40,
    restockThreshold: 20,
  ),

  // Honey Glazed Peanuts (p-sweet-100)
  InventoryBatch(
    id: 'b-004',
    productId: 'p-sweet-100',
    batchCode: 'HG-0918A',
    branch: 'Santa Cruz Main',
    receivedDate: _now.subtract(const Duration(days: 12)),
    expirationDate: _now.add(const Duration(days: 50)),
    quantity: 60,
    restockThreshold: 20,
  ),
  InventoryBatch(
    id: 'b-005',
    productId: 'p-sweet-100',
    batchCode: 'HG-0905B',
    branch: 'Calamba Branch',
    receivedDate: _now.subtract(const Duration(days: 25)),
    expirationDate: _now.add(const Duration(days: 5)),
    quantity: 12,
    restockThreshold: 20,
  ),

  // Chili Garlic Peanuts (p-spicy-100)
  InventoryBatch(
    id: 'b-006',
    productId: 'p-spicy-100',
    batchCode: 'CG-0920A',
    branch: 'Santa Cruz Main',
    receivedDate: _now.subtract(const Duration(days: 8)),
    expirationDate: _now.add(const Duration(days: 70)),
    quantity: 30,
    restockThreshold: 20,
  ),
  InventoryBatch(
    id: 'b-007',
    productId: 'p-spicy-100',
    batchCode: 'CG-0901C',
    branch: 'Los Baños Hub',
    receivedDate: _now.subtract(const Duration(days: 35)),
    expirationDate: _now.add(const Duration(days: 3)),
    quantity: 9,
    restockThreshold: 20,
  ),

  // Classic Roasted Peanuts (p-classic-100)
  InventoryBatch(
    id: 'b-008',
    productId: 'p-classic-100',
    batchCode: 'CR-0922A',
    branch: 'Santa Cruz Main',
    receivedDate: _now.subtract(const Duration(days: 3)),
    expirationDate: _now.add(const Duration(days: 90)),
    quantity: 120,
    restockThreshold: 30,
  ),
  InventoryBatch(
    id: 'b-009',
    productId: 'p-classic-100',
    batchCode: 'CR-0910B',
    branch: 'Calamba Branch',
    receivedDate: _now.subtract(const Duration(days: 18)),
    expirationDate: _now.add(const Duration(days: 55)),
    quantity: 75,
    restockThreshold: 30,
  ),
  InventoryBatch(
    id: 'b-010',
    productId: 'p-classic-100',
    batchCode: 'CR-0828C',
    branch: 'Los Baños Hub',
    receivedDate: _now.subtract(const Duration(days: 40)),
    expirationDate: _now.add(const Duration(days: 12)),
    quantity: 22,
    restockThreshold: 30,
  ),

  // Honey Cashews (p-sweet-cashew)
  InventoryBatch(
    id: 'b-011',
    productId: 'p-sweet-cashew',
    batchCode: 'HC-0915A',
    branch: 'Calamba Branch',
    receivedDate: _now.subtract(const Duration(days: 15)),
    expirationDate: _now.add(const Duration(days: 25)),
    quantity: 15,
    restockThreshold: 15,
  ),

  // Garlic Cashews (p-garlic-cashew)
  InventoryBatch(
    id: 'b-012',
    productId: 'p-garlic-cashew',
    batchCode: 'GC-0912A',
    branch: 'Santa Cruz Main',
    receivedDate: _now.subtract(const Duration(days: 22)),
    expirationDate: _now.add(const Duration(days: 8)),
    quantity: 10,
    restockThreshold: 15,
  ),
];

List<InventoryBatch> get lowStockBatches =>
    kInventoryBatches.where((b) => b.isLowStock).toList();

List<InventoryBatch> batchesByPriority(FefoPriority priority) =>
    kInventoryBatches.where((b) => b.fefoPriority == priority).toList();

List<InventoryBatch> batchesForBranch(String branch) =>
    kInventoryBatches.where((b) => b.branch == branch).toList();

List<InventoryBatch> batchesForProduct(String productId) =>
    kInventoryBatches.where((b) => b.productId == productId).toList();

/// Per-product inventory summary for a single [branch].
List<InventoryItem> inventoryItemsForBranch(String branch) {
  final batches = batchesForBranch(branch);
  final byProduct = <String, List<InventoryBatch>>{};
  for (final b in batches) {
    byProduct.putIfAbsent(b.productId, () => []).add(b);
  }
  return byProduct.entries
      .map((e) => InventoryItem(productId: e.key, batches: e.value, branch: branch))
      .toList();
}

/// Per-product inventory summary aggregated across every branch.
List<InventoryItem> get inventoryItemsByProduct {
  final byProduct = <String, List<InventoryBatch>>{};
  for (final b in kInventoryBatches) {
    byProduct.putIfAbsent(b.productId, () => []).add(b);
  }
  return byProduct.entries
      .map((e) => InventoryItem(productId: e.key, batches: e.value))
      .toList();
}

int totalStockFor(String productId) =>
    batchesForProduct(productId).fold(0, (sum, b) => sum + b.quantity);
