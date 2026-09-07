import 'package:flutter/material.dart';

/// A single purchasable size/packaging option for a [Product]
/// (e.g. "100g Retail Foil" vs "250g Standup Pouch").
class ProductVariant {
  final String label;
  final double price;
  final String? badge; // e.g. "Most Popular", "Best Value"

  const ProductVariant({required this.label, required this.price, this.badge});
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
  });
}
