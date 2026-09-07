import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/dummy_data/dummy_products.dart';
import '../../../data/models/product.dart';
import '../cart_controller.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'product_details_screen.dart';

/// Search + filter results (matches the prototype's Search Results &
/// Filters screen, including the "Filter & Refine" bottom sheet).
class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({super.key, this.query = ''});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late final TextEditingController _controller = TextEditingController(text: widget.query);
  final Set<String> _selectedCategories = {};
  RangeValues _priceRange = const RangeValues(50, 300);

  List<Product> get _results {
    var list = kProducts.where((p) {
      final query = _controller.text.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.categoryId.toLowerCase().contains(query);
      final matchesCategory = _selectedCategories.isEmpty || _selectedCategories.contains(p.categoryId);
      final matchesPrice = p.price >= _priceRange.start && p.price <= _priceRange.end;
      return matchesQuery && matchesCategory && matchesPrice;
    }).toList();
    return list;
  }

  Future<void> _openFilters() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: DraggableScrollableSheet(
                initialChildSize: 0.75,
                minChildSize: 0.5,
                maxChildSize: 0.95,
                expand: false,
                builder: (context, scrollController) {
                  return ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Filter & Refine', style: AppTextStyles.headlineSm),
                          TextButton(
                            onPressed: () => setSheetState(() {
                              _selectedCategories.clear();
                              _priceRange = const RangeValues(50, 300);
                            }),
                            child: const Text('Reset All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Product Category', style: AppTextStyles.titleMd),
                      const SizedBox(height: 8),
                      for (final cat in kProductCategories)
                        CheckboxListTile(
                          value: _selectedCategories.contains(cat.id),
                          title: Text(cat.name),
                          secondary: Text('(${productsByCategory(cat.id).length})'),
                          activeColor: AppColors.primary,
                          onChanged: (v) => setSheetState(() {
                            if (v == true) {
                              _selectedCategories.add(cat.id);
                            } else {
                              _selectedCategories.remove(cat.id);
                            }
                          }),
                        ),
                      const SizedBox(height: 10),
                      Text('Price Range', style: AppTextStyles.titleMd),
                      RangeSlider(
                        values: _priceRange,
                        min: 30,
                        max: 300,
                        activeColor: AppColors.primary,
                        labels: RangeLabels(
                          '₱${_priceRange.start.toStringAsFixed(0)}',
                          '₱${_priceRange.end.toStringAsFixed(0)}',
                        ),
                        onChanged: (v) => setSheetState(() => _priceRange = v),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'Apply Filters (${_results.length} Results Found)',
                        onPressed: () {
                          setState(() {});
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;
    final results = _results;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: widget.query.isEmpty,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Search Melai Nuts products...',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: cart,
          builder: (context, _) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${results.length} results found', style: AppTextStyles.bodyMd),
                      OutlinedButton.icon(
                        onPressed: _openFilters,
                        icon: const Icon(Icons.tune_rounded, size: 16),
                        label: Text(
                          _selectedCategories.isEmpty ? 'Filters' : 'Filters (${_selectedCategories.length})',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: results.isEmpty
                      ? const Center(
                    child: Text('No products match your search.'),
                  )
                      : GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: results.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    itemBuilder: (context, i) {
                      final product = results[i];
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
                  ),
                ),
                ListenableBuilder(
                  listenable: cart,
                  builder: (context, _) {
                    if (cart.itemCount == 0) return const SizedBox.shrink();
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: PrimaryButton(
                            label: 'View Cart (${cart.itemCount})',
                            icon: Icons.shopping_bag_outlined,
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const CartScreen()),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
