import 'inventory_batch.dart';

/// A per-product inventory summary — aggregates every [InventoryBatch] for
/// one product (optionally scoped to a single branch) into the totals used
/// by list-style inventory screens, so screens don't need to re-derive
/// totals/priority from raw batches themselves.
class InventoryItem {
  final String productId;
  final String? branch; // null = aggregated across all branches
  final List<InventoryBatch> batches;

  InventoryItem({
    required this.productId,
    required this.batches,
    this.branch,
  });

  int get totalStock => batches.fold(0, (sum, b) => sum + b.quantity);

  int get batchCount => batches.length;

  bool get isLowStock => batches.any((b) => b.isLowStock);

  int get recommendedRestockQty =>
      batches.fold(0, (sum, b) => sum + b.recommendedRestockQty);

  /// The most urgent FEFO tier among this item's batches (HIGH beats
  /// MEDIUM beats LOW), used to badge the item in list screens.
  FefoPriority get worstFefoPriority {
    if (batches.isEmpty) return FefoPriority.low;
    return batches.map((b) => b.fefoPriority).reduce(
          (a, b) => a.index < b.index ? a : b,
        );
  }

  /// Batches sorted soonest-to-expire first — the batch at index 0 is the
  /// one that should be sold next under FEFO.
  List<InventoryBatch> get batchesFefoSorted {
    final list = List<InventoryBatch>.from(batches);
    list.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
    return list;
  }

  InventoryBatch? get nextToSellBatch =>
      batchesFefoSorted.isEmpty ? null : batchesFefoSorted.first;
}
