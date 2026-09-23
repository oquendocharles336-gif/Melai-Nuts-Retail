import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../models/product.dart';

/// TEMPORARY PLACEHOLDER DATA.
///
/// This file exists only so the app compiles while real product data (from
/// Firestore or another backend) is wired up. Nothing here should be
/// treated as real inventory/pricing — replace `kProducts` /
/// `kProductCategories` with a real data source before shipping.

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

final List<Product> kProducts = [
  Product(
    id: 'p-garlic-100',
    name: 'Garlic Peanuts',
    variantLabel: '100g Retail Foil',
    categoryId: 'garlic',
    price: 65,
    originalPrice: 75,
    rating: 4.8,
    reviewCount: 132,
    badge: 'Best Seller',
    stockLabel: 'In Stock',
    description:
        'Crunchy peanuts slow-roasted with real Laguna garlic for a savory, '
        'aromatic bite.',
    branchAvailability: const ['Santa Cruz Main', 'Calamba Branch', 'Los Baños Hub'],
    variants: const [
      ProductVariant(label: '100g Retail Foil', price: 65, costPrice: 32, sku: 'MN-GP-100'),
      ProductVariant(label: '250g Standup Pouch', price: 140, costPrice: 70, sku: 'MN-GP-250', badge: 'Best Value'),
    ],
    spiceLevels: const ['Regular'],
    icon: Icons.eco_rounded,
    color: AppColors.success,
    sku: 'MN-GP-CORE',
    costPrice: 32,
    tags: const ['Laguna Heritage', 'Bestseller'],
    unitsSoldLast30Days: 812,
  ),
  Product(
    id: 'p-sweet-100',
    name: 'Honey Glazed Peanuts',
    variantLabel: '100g Retail Foil',
    categoryId: 'sweet',
    price: 70,
    rating: 4.7,
    reviewCount: 98,
    badge: 'Fresh Batch',
    stockLabel: 'In Stock',
    description: 'Peanuts coated in a light honey glaze, roasted until golden.',
    branchAvailability: const ['Santa Cruz Main', 'Calamba Branch'],
    variants: const [
      ProductVariant(label: '100g Retail Foil', price: 70, costPrice: 34, sku: 'MN-HG-100'),
      ProductVariant(label: '250g Standup Pouch', price: 150, costPrice: 74, sku: 'MN-HG-250'),
    ],
    icon: Icons.cookie_rounded,
    color: AppColors.warning,
    sku: 'MN-HG-CORE',
    costPrice: 34,
    tags: const ['Kids Favorite'],
    unitsSoldLast30Days: 540,
  ),
  Product(
    id: 'p-spicy-100',
    name: 'Chili Garlic Peanuts',
    variantLabel: '100g Retail Foil',
    categoryId: 'spicy',
    price: 68,
    rating: 4.6,
    reviewCount: 76,
    badge: 'Spicy',
    stockLabel: 'Low Stock',
    description: 'A fiery twist on the classic garlic peanut, finished with chili flakes.',
    branchAvailability: const ['Santa Cruz Main', 'Los Baños Hub'],
    variants: const [
      ProductVariant(label: '100g Retail Foil', price: 68, costPrice: 33, sku: 'MN-CG-100'),
    ],
    spiceLevels: const ['Mild', 'Hot'],
    icon: Icons.local_fire_department_rounded,
    color: AppColors.error,
    sku: 'MN-CG-CORE',
    costPrice: 33,
    tags: const ['Limited Batch'],
    unitsSoldLast30Days: 301,
  ),
  Product(
    id: 'p-classic-100',
    name: 'Classic Roasted Peanuts',
    variantLabel: '100g Retail Foil',
    categoryId: 'classic',
    price: 55,
    rating: 4.9,
    reviewCount: 210,
    badge: 'Fresh Batch',
    stockLabel: 'In Stock',
    description: 'Simple, salted, and roasted the traditional Laguna way.',
    branchAvailability: const ['Santa Cruz Main', 'Calamba Branch', 'Los Baños Hub'],
    variants: const [
      ProductVariant(label: '100g Retail Foil', price: 55, costPrice: 26, sku: 'MN-CR-100'),
      ProductVariant(label: '500g Family Pack', price: 250, costPrice: 130, sku: 'MN-CR-500', badge: 'Most Popular'),
    ],
    icon: Icons.grain_rounded,
    color: AppColors.primary,
    sku: 'MN-CR-CORE',
    costPrice: 26,
    tags: const ['Everyday Favorite'],
    unitsSoldLast30Days: 960,
  ),
  Product(
    id: 'p-sweet-cashew',
    name: 'Honey Cashews',
    variantLabel: '100g Retail Foil',
    categoryId: 'sweet',
    price: 120,
    rating: 4.7,
    reviewCount: 54,
    stockLabel: 'In Stock',
    description: 'Premium cashews finished with a delicate honey glaze.',
    branchAvailability: const ['Calamba Branch'],
    variants: const [
      ProductVariant(label: '100g Retail Foil', price: 120, costPrice: 68, sku: 'MN-HC-100'),
    ],
    icon: Icons.cookie_rounded,
    color: AppColors.warning,
    sku: 'MN-HC-CORE',
    costPrice: 68,
    unitsSoldLast30Days: 145,
  ),
  Product(
    id: 'p-garlic-cashew',
    name: 'Garlic Cashews',
    variantLabel: '100g Retail Foil',
    categoryId: 'garlic',
    price: 125,
    rating: 4.5,
    reviewCount: 41,
    stockLabel: 'In Stock',
    description: 'Cashews roasted with garlic for a savory upgrade on the classic.',
    branchAvailability: const ['Santa Cruz Main'],
    variants: const [
      ProductVariant(label: '100g Retail Foil', price: 125, costPrice: 70, sku: 'MN-GC-100'),
    ],
    icon: Icons.eco_rounded,
    color: AppColors.success,
    sku: 'MN-GC-CORE',
    costPrice: 70,
    unitsSoldLast30Days: 88,
  ),
];

/// Returns the product with [id], falling back to the first product in the
/// catalog if not found (placeholder-data safety net — replace with a real
/// lookup once products come from a backend).
Product findProductById(String id) {
  return kProducts.firstWhere((p) => p.id == id, orElse: () => kProducts.first);
}

/// Returns the category with [id], falling back to the first category if
/// not found.
ProductCategory findCategoryById(String id) {
  return kProductCategories.firstWhere(
    (c) => c.id == id,
    orElse: () => kProductCategories.first,
  );
}

List<Product> productsByCategory(String categoryId) {
  return kProducts.where((p) => p.categoryId == categoryId).toList();
}
