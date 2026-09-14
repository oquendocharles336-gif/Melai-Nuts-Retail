import 'package:flutter/material.dart';

/// A single purchasable size/packaging option for a [Product]
/// (e.g. "100g Retail Foil" vs "250g Standup Pouch").
class ProductVariant {
  final String label;
  final double price;
  final String? badge; // e.g. "Most Popular", "Best Value"

  /// Cost of goods (COGS) for this specific variant/pack size, used by the
  /// Product Management "Pricing" screens to compute per-variant margin.
  /// Optional since customer-facing screens don't need it.
  final double? costPrice;

  /// Optional dedicated SKU/barcode for this variant (e.g. "MN-GP-100").
  final String? sku;

  /// Current stock across all branches for this variant, shown on the
  /// Variants management screen. Optional/cosmetic for this frontend-only
  /// build.
  final int? stockOnHand;

  const ProductVariant({
    required this.label,
    required this.price,
    this.badge,
    this.costPrice,
    this.sku,
    this.stockOnHand,
  });

  /// Gross margin percentage (0-100) for this variant. Falls back to 0 if
  /// no cost price was supplied.
  double get marginPercent =>
      costPrice == null || price == 0 ? 0 : ((price - costPrice!) / price) * 100;

  double get netProfit => costPrice == null ? 0 : price - costPrice!;
}

/// A product category (e.g. Garlic Nuts, Sweet Peanuts).
class ProductCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// Dummy/static product used throughout the customer storefront.
///
/// There are no bundled product photos in this frontend-only build, so
/// [icon] + [color] are used to render a consistent, on-brand placeholder
/// image wherever a photo would normally go (see [ProductCard]).
class Product {
  final String id;
  final String name;
  final String variantLabel;
  final String categoryId;
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviewCount;
  final String? badge; // "Best Seller", "Spicy", "Fresh Batch"...
  final String stockLabel;
  final String description;
  final List<String> branchAvailability;
  final List<ProductVariant> variants;
  final List<String> spiceLevels;
  final IconData icon;
  final Color color;

  // --- Product Management / Pricing Hub fields (Owner & Staff) ---------
  // All optional with sensible defaults so existing customer-facing code
  // (Batch 2) keeps working unchanged.

  /// Master SKU code shown in Product Management screens, e.g. "MN-GP-CORE".
  final String sku;

  /// Cost of goods sold (COGS) for the product's default/base variant, used
  /// to compute gross margin on the Pricing Hub and Add/Edit Product forms.
  final double costPrice;

  /// Whether this product is currently published/active in the catalog and
  /// POS registers. Inactive products are hidden from the storefront.
  final bool isActive;

  /// Free-form highlight tags (e.g. "Laguna Heritage", "Bestseller").
  final List<String> tags;

  /// Units sold across all branches in the trailing 30 days — drives the
  /// Product Performance ranking screen.
  final int unitsSoldLast30Days;

  const Product({
    required this.id,
    required this.name,
    required this.variantLabel,
    required this.categoryId,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviewCount,
    this.badge,
    required this.stockLabel,
    required this.description,
    required this.branchAvailability,
    required this.variants,
    this.spiceLevels = const [],
    required this.icon,
    required this.color,
    this.sku = '',
    this.costPrice = 0,
    this.isActive = true,
    this.tags = const [],
    this.unitsSoldLast30Days = 0,
  });

  /// Gross margin percentage (0-100) on the base price vs [costPrice].
  double get marginPercent =>
      costPrice <= 0 || price == 0 ? 0 : ((price - costPrice) / price) * 100;

  double get netProfitPerUnit => price - costPrice;

  double get monthlyRevenue => price * unitsSoldLast30Days;
}
