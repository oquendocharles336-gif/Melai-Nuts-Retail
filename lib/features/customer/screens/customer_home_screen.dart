import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/dummy_data/dummy_products.dart';
import '../cart_controller.dart';
import '../widgets/category_chip.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'product_catalog_screen.dart';
import 'product_categories_screen.dart';
import 'product_details_screen.dart';
import 'search_results_screen.dart';

/// "Store Home" — branch selector, search, featured promos, categories,
/// and popular products (matches the prototype's Customer Home screen).
class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MELAI NUTS LAGUNA', style: AppTextStyles.labelSm.copyWith(color: AppColors.primary)),
            Text('Mabuhay!', style: AppTextStyles.headlineSm),
          ],
        ),
        actions: [
          ListenableBuilder(
            listenable: CartController.instance,
            builder: (context, _) => Badge(
              label: Text(CartController.instance.itemCount.toString()),
              isLabelVisible: CartController.instance.itemCount > 0,
              child: IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.delayed(const Duration(milliseconds: 100)),
        builder: (context, snapshot) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Melai Nuts Branch', style: AppTextStyles.bodySm),
                      Text('Select a branch to see inventory', style: AppTextStyles.bodySm),
                    ],
                  ),
                  Text('Change', style: AppTextStyles.labelLg),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                onSubmitted: (q) => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SearchResultsScreen(query: q)),
                ),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Search for garlic, spicy, or sweet...',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Featured Promo Section
              Container(
                height: 160,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.secondaryBrown],
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  boxShadow: AppShadows.md,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'LIMITED TIME OFFER',
                          style: AppTextStyles.labelSm.copyWith(color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Buy 2 Get 1 Free\non Garlic Peanuts',
                        style: AppTextStyles.headlineMd.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Category Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Categories', style: AppTextStyles.titleMd),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProductCategoriesScreen()),
                    ),
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    CategoryChip(
                      label: 'All',
                      selected: _selectedCategory == 'All',
                      onTap: () => setState(() => _selectedCategory = 'All'),
                    ),
                    const SizedBox(width: 8),
                    CategoryChip(
                      label: 'Garlic Roasted',
                      selected: _selectedCategory == 'Garlic',
                      onTap: () => setState(() => _selectedCategory = 'Garlic'),
                    ),
                    const SizedBox(width: 8),
                    CategoryChip(
                      label: 'Spicy & Hot',
                      selected: _selectedCategory == 'Spicy',
                      onTap: () => setState(() => _selectedCategory = 'Spicy'),
                    ),
                    const SizedBox(width: 8),
                    CategoryChip(
                      label: 'Sweet Treats',
                      selected: _selectedCategory == 'Sweet',
                      onTap: () => setState(() => _selectedCategory = 'Sweet'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Popular Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Popular Near You', style: AppTextStyles.headlineSm),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProductCatalogScreen()),
                    ),
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 280,
                child: ListenableBuilder(
                  listenable: CartController.instance,
                  builder: (context, _) {
                    final cart = CartController.instance;
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: kProducts.length > 4 ? 4 : kProducts.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final product = kProducts[index];
                        final defaultVariant = product.variants.first;
                        return ProductCard(
                          product: product,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
                          ),
                          onAdd: () => cart.addProduct(product, defaultVariant),
                          quantityInCart: cart.quantityFor(product.id, defaultVariant.label),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // RFID Rewards Teaser
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  boxShadow: AppShadows.sm,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium_rounded, color: AppColors.primary, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Golden Kernel Rewards', style: AppTextStyles.labelLg),
                          Text('Earn points for every purchase!', style: AppTextStyles.bodySm),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.customerLoyaltyDashboard),
                      child: const Text('View'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
