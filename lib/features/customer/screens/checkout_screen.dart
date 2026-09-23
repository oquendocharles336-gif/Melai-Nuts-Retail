import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../core/widgets/melai_app_bar.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/dummy_data/dummy_orders.dart';
import '../../../data/models/order.dart';
import '../cart_controller.dart';
import 'order_confirmation_screen.dart';

enum _FulfillmentMethod { pickup, delivery }

enum _PaymentMethod { gcash, card, cash }

/// Checkout — fulfillment method, branch/pickup details, payment method,
/// and order summary, then simulates placing the order (matches the
/// prototype's Checkout / Branch Fulfillment screen).
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  _FulfillmentMethod _fulfillment = _FulfillmentMethod.pickup;
  _PaymentMethod _payment = _PaymentMethod.gcash;
  final _notesController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  bool _placingOrder = false;

  @override
  void dispose() {
    _notesController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final cart = CartController.instance;
    if (cart.lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty.')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _placingOrder = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _placingOrder = false);

    final deliveryFee = _fulfillment == _FulfillmentMethod.pickup ? 0.0 : cart.deliveryFee;
    final total = (cart.subtotal - cart.loyaltyDiscount - cart.voucherDiscount + deliveryFee)
        .clamp(0, double.infinity);
    final paymentLabel = switch (_payment) {
      _PaymentMethod.gcash => 'GCash E-Wallet',
      _PaymentMethod.card => 'Maya / Credit Card',
      _PaymentMethod.cash => 'Cash on Counter Pickup',
    };

    final order = Order(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      status: OrderStatus.confirmed,
      branch: cart.currentBranch,
      isDelivery: _fulfillment == _FulfillmentMethod.delivery,
      items: [
        for (final line in cart.lines)
          OrderItem(
            productName: line.product.name,
            variantLabel: line.variant.label,
            quantity: line.quantity,
            unitPrice: line.variant.price,
          ),
      ],
      discount: cart.loyaltyDiscount + cart.voucherDiscount,
      deliveryFee: deliveryFee,
      paymentMethod: paymentLabel,
      pointsEarned: (cart.subtotal / 10).floor(),
    );
    kOrders.insert(0, order);
    final itemCount = cart.itemCount;
    cart.clear();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OrderConfirmationScreen(order: order, itemCount: itemCount, total: total.toDouble()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartController.instance;
    final deliveryFee = _fulfillment == _FulfillmentMethod.pickup ? 0.0 : cart.deliveryFee;
    final total = (cart.subtotal - cart.loyaltyDiscount - cart.voucherDiscount + deliveryFee)
        .clamp(0, double.infinity);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const MelaiAppBar(title: 'Checkout', showBack: true),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Step 1 of 2 • Fulfillment & Payment', style: AppTextStyles.labelSm),
                Text('50% Done', style: AppTextStyles.labelSm),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: const LinearProgressIndicator(
                value: 0.5,
                minHeight: 6,
                backgroundColor: AppColors.border,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.sm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.badge_outlined, color: AppColors.darkBrown),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Customer Account', style: AppTextStyles.titleMd),
                        Text('No phone linked', style: AppTextStyles.bodySm),
                        Text('No email linked', style: AppTextStyles.bodySm),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Verified Patron', style: AppTextStyles.labelSm.copyWith(color: AppColors.success)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Fulfillment Method', style: AppTextStyles.titleMd),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _OptionCard(
                    icon: Icons.storefront_outlined,
                    title: 'Store Pickup',
                    subtitle: 'Ready in 30 mins',
                    trailingLabel: 'FREE',
                    selected: _fulfillment == _FulfillmentMethod.pickup,
                    onTap: () => setState(() => _fulfillment = _FulfillmentMethod.pickup),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _OptionCard(
                    icon: Icons.delivery_dining_rounded,
                    title: 'Melai Van',
                    subtitle: 'Same Day Laguna',
                    trailingLabel: '₱${cart.deliveryFee.toStringAsFixed(0)}',
                    selected: _fulfillment == _FulfillmentMethod.delivery,
                    onTap: () => setState(() => _fulfillment = _FulfillmentMethod.delivery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.primary, width: 1.4),
                boxShadow: AppShadows.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('PICKUP DEPOT DETAILS', style: AppTextStyles.labelSm),
                      Text('Branch ID: CAL-01', style: AppTextStyles.bodySm),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Calamba Highway Branch', style: AppTextStyles.titleMd),
                  Text(
                    'Poblacion Terminal, National Hwy, Calamba City, Laguna',
                    style: AppTextStyles.bodySm,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        _fulfillment == _FulfillmentMethod.pickup
                            ? 'Estimated pickup: Today by 2:00 PM'
                            : 'Estimated delivery: Today by 2:45 PM',
                        style: AppTextStyles.bodySm,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_fulfillment == _FulfillmentMethod.delivery) ...[
              const SizedBox(height: AppSpacing.md),
              Text('Delivery Details', style: AppTextStyles.titleMd),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(hintText: 'House/unit no., street, barangay, city'),
                maxLines: 2,
                validator: (v) => ValidationUtils.validateAddress(v),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: '09XXXXXXXXX'),
                validator: (v) => ValidationUtils.validatePhone(v),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text('Payment Method', style: AppTextStyles.titleMd),
            const SizedBox(height: AppSpacing.sm),
            _PaymentTile(
              icon: Icons.account_balance_wallet_rounded,
              title: 'GCash E-Wallet',
              subtitle: 'Instant QR scan / mobile pay',
              badge: 'Fast',
              selected: _payment == _PaymentMethod.gcash,
              onTap: () => setState(() => _payment = _PaymentMethod.gcash),
            ),
            const SizedBox(height: 8),
            _PaymentTile(
              icon: Icons.credit_card_rounded,
              title: 'Maya / Credit Card',
              subtitle: 'Visa, Mastercard, Maya QR',
              selected: _payment == _PaymentMethod.card,
              onTap: () => setState(() => _payment = _PaymentMethod.card),
            ),
            const SizedBox(height: 8),
            _PaymentTile(
              icon: Icons.storefront_rounded,
              title: 'Cash on Counter Pickup',
              subtitle: 'Pay when picking up order',
              selected: _payment == _PaymentMethod.cash,
              onTap: () => setState(() => _payment = _PaymentMethod.cash),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Special Instructions (Pasalubong / Packing)', style: AppTextStyles.titleMd),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Optional note: add extra paper bag for pasalubong gift...',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Summary (${cart.itemCount} items)', style: AppTextStyles.titleMd),
                  const SizedBox(height: 10),
                  for (final line in cart.lines)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${line.quantity}x ${line.product.name}',
                              style: AppTextStyles.bodyMd,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text('₱${line.lineTotal.toStringAsFixed(0)}', style: AppTextStyles.bodyMd),
                        ],
                      ),
                    ),
                  const Divider(height: 20),
                  _SummaryLine('Subtotal', '₱${cart.subtotal.toStringAsFixed(0)}'),
                  if (cart.voucherDiscount + cart.loyaltyDiscount > 0)
                    _SummaryLine(
                      'Discounts applied',
                      '-₱${(cart.voucherDiscount + cart.loyaltyDiscount).toStringAsFixed(0)}',
                      color: AppColors.success,
                    ),
                  _SummaryLine(
                    'Fulfillment Fee',
                    deliveryFee == 0 ? '₱0.00 (Store Pickup)' : '₱${deliveryFee.toStringAsFixed(0)}',
                    color: AppColors.success,
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Payable', style: AppTextStyles.headlineSm),
                      Text(
                        '₱${total.toStringAsFixed(0)}',
                        style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
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
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOTAL PAYABLE', style: AppTextStyles.bodySm),
                      Text(
                        '₱${total.toStringAsFixed(0)}',
                        style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PrimaryButton(
                    label: 'Place Order & Pay',
                    icon: Icons.arrow_forward_rounded,
                    loading: _placingOrder,
                    onPressed: cart.lines.isEmpty ? null : _placeOrder,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _SummaryLine(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMd),
          Text(value, style: AppTextStyles.bodyMd.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String trailingLabel;
  final bool selected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailingLabel,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryContainer.withValues(alpha: 0.3) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.6 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.darkBrown),
                const Spacer(),
                Text(
                  trailingLabel,
                  style: AppTextStyles.labelMd.copyWith(
                    color: trailingLabel == 'FREE' ? AppColors.success : AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(title, style: AppTextStyles.labelLg),
            Text(subtitle, style: AppTextStyles.bodySm),
          ],
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.6 : 1),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Icon(icon, color: AppColors.darkBrown),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.labelLg),
                  Text(subtitle, style: AppTextStyles.bodySm),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(badge!, style: AppTextStyles.labelSm.copyWith(color: AppColors.warning)),
              ),
          ],
        ),
      ),
    );
  }
}
