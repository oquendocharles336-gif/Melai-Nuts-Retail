import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/dummy_data/dummy_products.dart';
import '../../../data/dummy_data/dummy_orders.dart';
import '../../../data/models/order.dart';

/// Comprehensive Branch Staff Portal — Register (POS), Transactions,
/// and Inventory (FEFO) management in a single-file shell.
class StaffPortalScreen extends StatefulWidget {
  const StaffPortalScreen({super.key});

  @override
  State<StaffPortalScreen> createState() => _StaffPortalScreenState();
}

class _StaffPortalScreenState extends State<StaffPortalScreen> {
  int _currentIndex = 0;

  void _logout() {
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.roleStaff,
              child: Icon(Icons.badge_rounded, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Staff Portal', style: AppTextStyles.labelLg),
                Text('Calamba Highway Branch', style: AppTextStyles.bodySm),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _PosRegisterTab(),
          _TransactionsTab(),
          _InventoryTab(),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: AppColors.roleStaff.withValues(alpha: 0.15),
          surfaceTintColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTextStyles.labelMd.copyWith(color: AppColors.roleStaff);
            }
            return AppTextStyles.labelMd;
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.point_of_sale_outlined),
              selectedIcon: Icon(Icons.point_of_sale_rounded, color: AppColors.roleStaff),
              label: 'Register',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded, color: AppColors.roleStaff),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2_rounded, color: AppColors.roleStaff),
              label: 'Inventory',
            ),
          ],
        ),
      ),
    );
  }
}

class _PosRegisterTab extends StatefulWidget {
  const _PosRegisterTab();

  @override
  State<_PosRegisterTab> createState() => _PosRegisterTabState();
}

class _PosRegisterTabState extends State<_PosRegisterTab> {
  String _selectedCat = 'All';
  final Map<String, int> _cart = {};

  double get _total {
    double sum = 0;
    _cart.forEach((id, qty) {
      final p = findProductById(id);
      sum += p.price * qty;
    });
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final products = _selectedCat == 'All' ? kProducts : productsByCategory(_selectedCat.toLowerCase());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Scan barcode or search SKU...',
              prefixIcon: const Icon(Icons.qr_code_scanner_rounded),
              suffixIcon: IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            children: ['All', 'Garlic', 'Spicy', 'Sweet', 'Mixed'].map((c) {
              final sel = _selectedCat == c;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(c),
                  selected: sel,
                  onSelected: (_) => setState(() => _selectedCat = c),
                  selectedColor: AppColors.roleStaff.withValues(alpha: 0.2),
                  labelStyle: AppTextStyles.labelMd.copyWith(color: sel ? AppColors.roleStaff : null),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.4,
            ),
            itemCount: products.length,
            itemBuilder: (context, i) {
              final p = products[i];
              final qty = _cart[p.id] ?? 0;
              return InkWell(
                onTap: () => setState(() => _cart[p.id] = qty + 1),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: qty > 0 ? AppColors.roleStaff : AppColors.border, width: qty > 0 ? 1.6 : 1),
                    boxShadow: AppShadows.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(p.icon, size: 20, color: p.color),
                          if (qty > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.roleStaff, borderRadius: BorderRadius.circular(10)),
                              child: Text('$qty', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      const Spacer(),
                      Text(p.name, style: AppTextStyles.labelMd, maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('₱${p.price.toStringAsFixed(0)}', style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (_cart.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
            ),
            child: SafeArea(
              child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TRANSACTION TOTAL', style: AppTextStyles.bodySm),
                      Text('₱${_total.toStringAsFixed(0)}', style: AppTextStyles.headlineSm.copyWith(color: AppColors.roleStaff)),
                    ],
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: PrimaryButton(
                    label: 'Checkout',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transaction completed & receipt printed.')),
                      );
                      setState(() => _cart.clear());
                    },
                  ),
                ),
              ],
            ),
            ),
          ),
      ],
    );
  }
}

class _TransactionsTab extends StatelessWidget {
  const _TransactionsTab();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: kOrders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final o = kOrders[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.sm,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(o.id, style: AppTextStyles.labelLg),
                  _StatusChip(status: o.status),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text('Guest Customer', style: AppTextStyles.bodyMd),
                  const Spacer(),
                  Text('₱${o.total.toStringAsFixed(0)}', style: AppTextStyles.labelLg),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text('${o.date.hour}:${o.date.minute.toString().padLeft(2, '0')} • ${o.paymentMethod}', style: AppTextStyles.bodySm),
                  const Spacer(),
                  TextButton(onPressed: () {}, child: const Text('View Ticket')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InventoryTab extends StatelessWidget {
  const _InventoryTab();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: kProducts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final p = kProducts[i];
        final stock = 42 - (i * 8); // dummy stock
        final isLow = stock < 10;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isLow ? AppColors.error : AppColors.border),
            boxShadow: AppShadows.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: p.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(p.icon, color: p.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: AppTextStyles.labelLg, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('Batch #LN-2024-${i+100} • FEFO Tracking', style: AppTextStyles.bodySm),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$stock', style: AppTextStyles.headlineSm.copyWith(color: isLow ? AppColors.error : AppColors.success)),
                  Text('units left', style: AppTextStyles.labelSm),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: status.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(status.label, style: AppTextStyles.labelSm.copyWith(color: status.color)),
    );
  }
}
