import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../data/dummy_data/dummy_products.dart';
import '../cart_controller.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';

/// Flat product listing for a single category (reached from the Categories
/// grid or a Home category chip). Defaults to the first category if none is
/// supplied so this screen also works from a parameterless named route.
class ProductListScreen extends StatelessWidget {
  final String categoryId;

  const ProductListScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final category = findCategoryById(categoryId);
    final products = productsByCategory(categoryId);
    final cart = CartController.instance;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: MelaiAppBar(title: category.name, showBack: true),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: cart,
          builder: (context, _) {
            if (products.isEmpty) {
              return const Center(child: Text('No products in this category yet.'));
            }
            return GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (context, i) {
                final product = products[i];
                final defaultVariant = product.variants.first;
                return ProductCard(
                  product: product,
                  quantityInCart: cart.quantityFor(product.id, defaultVariant.label),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsScreen(product: product),
                    ),
                  ),
                  onAdd: () => cart.addProduct(product, defaultVariant),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
