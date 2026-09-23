import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../models/product.dart';

/// Fixed category structure for the storefront/catalog. Not a data record —
/// kept as static app structure per the product catalog's design.
const List<ProductCategory> kProductCategories = [
  ProductCategory(
    id: 'garlic',
    name: 'Garlic Nuts',
    icon: Icons.eco_rounded,
    color: AppColors.success,
  ),
  ProductCategory(
    id: 'sweet',
    name: 'Sweet Peanuts',
    icon: Icons.cookie_rounded,
    color: AppColors.warning,
  ),
  ProductCategory(
    id: 'spicy',
    name: 'Spicy Nuts',
    icon: Icons.local_fire_department_rounded,
    color: AppColors.error,
  ),
  ProductCategory(
    id: 'classic',
    name: 'Classic Roasted',
    icon: Icons.grain_rounded,
    color: AppColors.primary,
  ),
];

/// Real product catalog — starts empty until connected to a backend.
final List<Product> kProducts = <Product>[];

/// Placeholder shown when a product id can't be found (e.g. it was
/// removed, or no product data has been loaded yet). Never treated as a
/// real record — every field signals "unavailable".
Product _unknownProduct(String id) => Product(
      id: id,
      name: 'Product unavailable',
      variantLabel: '',
      categoryId: '',
      price: 0,
      rating: 0,
      reviewCount: 0,
      stockLabel: 'Unavailable',
      description: 'This product could not be found.',
      branchAvailability: const [],
      variants: const [],
      icon: Icons.help_outline_rounded,
      color: AppColors.textMuted,
    );

/// Returns the product with [id], or a clearly-labeled placeholder if no
/// matching product exists (e.g. catalog not loaded yet).
Product findProductById(String id) {
  return kProducts.firstWhere((p) => p.id == id, orElse: () => _unknownProduct(id));
}

/// Returns the category with [id], falling back to the first fixed
/// category if not found.
ProductCategory findCategoryById(String id) {
  return kProductCategories.firstWhere(
    (c) => c.id == id,
    orElse: () => kProductCategories.first,
  );
}

List<Product> productsByCategory(String categoryId) {
  return kProducts.where((p) => p.categoryId == categoryId).toList();
}
