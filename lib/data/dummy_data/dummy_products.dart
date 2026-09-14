import 'package:flutter/material.dart';
import '../models/product.dart';

/// Static product categories shown across the customer storefront.
const List<ProductCategory> kProductCategories = [
  ProductCategory(
    id: 'garlic',
    name: 'Garlic Nuts',
    icon: Icons.eco_rounded,
    color: Color(0xFFA06235),
  ),
  ProductCategory(
    id: 'sweet',
    name: 'Sweet Peanuts',
    icon: Icons.bakery_dining_rounded,
    color: Color(0xFFD9822B),
  ),
  ProductCategory(
    id: 'spicy',
    name: 'Spicy Nuts',
    icon: Icons.local_fire_department_rounded,
    color: Color(0xFFC23E3E),
  ),
  ProductCategory(
    id: 'mixed',
    name: 'Mixed Nuts',
    icon: Icons.grain_rounded,
    color: Color(0xFF387B44),
  ),
  ProductCategory(
    id: 'bundle',
    name: 'Pasalubong Bundles',
    icon: Icons.card_giftcard_rounded,
    color: Color(0xFF7B563F),
  ),
];

/// Static, dummy product catalog. No backend — quantities, prices, and
/// availability here are for frontend preview only.
final List<Product> kProducts = [
  Product(
    id: 'p1',
    name: 'Garlic Peanuts (Artisanal Slow-Roasted)',
    variantLabel: '250g Standup Pouch',
    categoryId: 'garlic',
    price: 140,
    rating: 4.9,
    reviewCount: 310,
    badge: 'Best Seller',
    stockLabel: 'In Stock',
    description:
    'Handcrafted in Santa Cruz, Laguna using traditional copper vats. '
        'Generously tossed with crispy deep-fried native garlic slices and '
        'sea salt. Packaged in a triple-layer aroma-lock barrier pouch to '
        'preserve roastery freshness for up to 90 days.',
    branchAvailability: const ['Calamba Branch', 'Los Baños Hub', 'Santa Cruz Flagship'],
    variants: const [
      ProductVariant(label: '100g Retail Foil', price: 55, costPrice: 19.80, sku: 'MN-GP-100', stockOnHand: 420),
      ProductVariant(label: '250g Standup Pouch', price: 140, badge: 'Most Popular', costPrice: 50.40, sku: 'MN-GP-250', stockOnHand: 680),
      ProductVariant(label: '500g Roaster Tub', price: 260, badge: 'Best Value', costPrice: 93.60, sku: 'MN-GP-500', stockOnHand: 150),
    ],
    spiceLevels: const ['Original Garlic Mild', 'Spicy Garlic Crunch'],
    icon: Icons.eco_rounded,
    color: const Color(0xFFA06235),
    sku: 'MN-GP-CORE',
    costPrice: 50.40,
    tags: const ['Laguna Heritage', 'Bestseller', 'Roasted Garlic'],
    unitsSoldLast30Days: 1750,
  ),
  Product(
    id: 'p2',
    name: 'Spicy Skinless Peanuts',
    variantLabel: '250g Jar Pack',
    categoryId: 'spicy',
    price: 65,
    rating: 4.8,
    reviewCount: 210,
    badge: 'Spicy',
    stockLabel: 'Only 6 left at Los Baños',
    description:
    'Skinless peanuts tossed in a fiery labuyo chili glaze, air-cooled '
        'to lock in crunch. A favorite pulutan pick across all three Laguna '
        'branches.',
    branchAvailability: const ['Los Baños Hub', 'Santa Cruz Flagship'],
    variants: const [
      ProductVariant(label: '120g Pouch', price: 35, costPrice: 19.60, sku: 'MN-SS-120', stockOnHand: 90),
      ProductVariant(label: '250g Jar Pack', price: 65, costPrice: 36.40, sku: 'MN-SS-250', stockOnHand: 60),
    ],
    spiceLevels: const ['Red Hot Chili'],
    icon: Icons.local_fire_department_rounded,
    color: const Color(0xFFC23E3E),
    sku: 'MN-SS-CORE',
    costPrice: 36.40,
    tags: const ['Spicy Line', 'Labuyo Chili'],
    unitsSoldLast30Days: 380,
  ),
  Product(
    id: 'p3',
    name: 'Sweet Peanuts (Panutsa Glazed)',
    variantLabel: '120g Pouch',
    categoryId: 'sweet',
    price: 60,
    rating: 4.7,
    reviewCount: 89,
    stockLabel: 'In Stock',
    description:
    'Native panutsa (muscovado) glazed peanuts, slow caramelized in '
        'small batches for a crunchy-sweet native Filipino snack.',
    branchAvailability: const ['Calamba Branch', 'Santa Cruz Flagship'],
    variants: const [
      ProductVariant(label: '120g Pouch', price: 60, costPrice: 22.20, sku: 'MN-SP-120', stockOnHand: 210),
      ProductVariant(label: '300g Family Pack', price: 135, costPrice: 49.95, sku: 'MN-SP-300', stockOnHand: 95),
    ],
    icon: Icons.bakery_dining_rounded,
    color: const Color(0xFFD9822B),
    sku: 'MN-SP-CORE',
    costPrice: 22.20,
    tags: const ['Sweet & Glazed', 'Panutsa'],
    unitsSoldLast30Days: 620,
  ),
  Product(
    id: 'p4',
    name: 'Adobo Garlic Peanuts',
    variantLabel: '200g Pouch',
    categoryId: 'garlic',
    price: 65,
    rating: 4.9,
    reviewCount: 178,
    badge: 'Fresh Batch',
    stockLabel: 'In Stock',
    description:
    'House-specialty adobo-seasoned peanuts finished with garlic bits '
        'and cracked pepper — a Melai Nuts signature blend.',
    branchAvailability: const ['Calamba Branch', 'Los Baños Hub', 'Santa Cruz Flagship'],
    variants: const [
      ProductVariant(label: '200g Pouch', price: 65, costPrice: 23.40, sku: 'MN-AG-200', stockOnHand: 340),
    ],
    icon: Icons.eco_rounded,
    color: const Color(0xFFA06235),
    sku: 'MN-AG-CORE',
    costPrice: 23.40,
    tags: const ['Garlic Line', 'House Specialty'],
    unitsSoldLast30Days: 910,
  ),
  Product(
    id: 'p5',
    name: 'Native Panutsa Sweet Peanuts',
    variantLabel: '300g Family Pack',
    categoryId: 'sweet',
    price: 145,
    rating: 4.6,
    reviewCount: 54,
    stockLabel: 'In Stock',
    description:
    'A bigger family-size version of our classic panutsa glazed '
        'peanuts, perfect for sharing during merienda.',
    branchAvailability: const ['Los Baños Hub'],
    variants: const [
      ProductVariant(label: '300g Family Pack', price: 145, costPrice: 55.10, sku: 'MN-NP-300', stockOnHand: 70),
    ],
    icon: Icons.bakery_dining_rounded,
    color: const Color(0xFFD9822B),
    sku: 'MN-NP-CORE',
    costPrice: 55.10,
    tags: const ['Sweet & Glazed', 'Family Size'],
    unitsSoldLast30Days: 340,
  ),
  Product(
    id: 'p6',
    name: 'Laguna Mixed Nuts Blend',
    variantLabel: '200g Pouch',
    categoryId: 'mixed',
    price: 95,
    rating: 4.5,
    reviewCount: 63,
    stockLabel: 'In Stock',
    description:
    'A roasted blend of peanuts, cashews, and pili nuts lightly salted '
        'for a wholesome everyday snack.',
    branchAvailability: const ['Calamba Branch', 'Santa Cruz Flagship'],
    variants: const [
      ProductVariant(label: '200g Pouch', price: 95, costPrice: 36.10, sku: 'MN-MX-200', stockOnHand: 180),
      ProductVariant(label: '400g Tub', price: 175, costPrice: 66.50, sku: 'MN-MX-400', stockOnHand: 85),
    ],
    icon: Icons.grain_rounded,
    color: const Color(0xFF387B44),
    sku: 'MN-MX-CORE',
    costPrice: 36.10,
    tags: const ['Mixed Nuts', 'Everyday Snack'],
    unitsSoldLast30Days: 410,
  ),
  Product(
    id: 'p7',
    name: 'Family Pasalubong Box (4-Pack)',
    variantLabel: 'Gift Set Assorted',
    categoryId: 'bundle',
    price: 220,
    originalPrice: 250,
    rating: 5.0,
    reviewCount: 450,
    badge: 'Gift Set',
    stockLabel: 'Guaranteed Fresh Batch',
    description:
    'Garlic, Sweet Glazed, Spicy Skinless, and Salted Roast in an '
        'authentic gift box — our best-selling pasalubong bundle.',
    branchAvailability: const ['Calamba Branch', 'Los Baños Hub', 'Santa Cruz Flagship'],
    variants: const [
      ProductVariant(label: 'Gift Set Assorted', price: 220, costPrice: 92.40, sku: 'MN-PB-STD', stockOnHand: 130),
    ],
    icon: Icons.card_giftcard_rounded,
    color: const Color(0xFF7B563F),
    sku: 'MN-PB-CORE',
    costPrice: 92.40,
    tags: const ['Gift Set', 'Pasalubong Bundles'],
    unitsSoldLast30Days: 450,
  ),
  Product(
    id: 'p8',
    name: 'Laguna Wild Honey Roasted Peanuts',
    variantLabel: '180g Pouch',
    categoryId: 'sweet',
    price: 115,
    rating: 4.8,
    reviewCount: 132,
    stockLabel: 'In Stock',
    description:
    'Roasted peanuts glazed with wild Laguna honey for a naturally '
        'sweet, sticky-crunch finish.',
    branchAvailability: const ['Santa Cruz Flagship'],
    variants: const [
      ProductVariant(label: '180g Pouch', price: 115, costPrice: 42.55, sku: 'MN-HR-180', stockOnHand: 110),
    ],
    icon: Icons.bakery_dining_rounded,
    color: const Color(0xFFD9822B),
    sku: 'MN-HR-CORE',
    costPrice: 42.55,
    tags: const ['Sweet & Glazed', 'Wild Honey'],
    unitsSoldLast30Days: 260,
  ),
];

Product findProductById(String id) =>
    kProducts.firstWhere((p) => p.id == id, orElse: () => kProducts.first);

List<Product> productsByCategory(String categoryId) =>
    kProducts.where((p) => p.categoryId == categoryId).toList();

ProductCategory findCategoryById(String id) => kProductCategories.firstWhere(
      (c) => c.id == id,
  orElse: () => kProductCategories.first,
);
