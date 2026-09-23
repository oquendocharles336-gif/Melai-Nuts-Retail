import '../../core/constants/app_constants.dart';
import '../models/inventory_batch.dart';
import '../models/inventory_item.dart';

/// Fixed list of operating branches — app structure, not a data record.
const List<String> kInventoryBranches = AppConstants.branches;

/// Real inventory batches — starts empty until connected to a backend.
final List<InventoryBatch> kInventoryBatches = <InventoryBatch>[];

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
