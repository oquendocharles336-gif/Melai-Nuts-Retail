import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../data/dummy_data/dummy_products.dart';
import '../../../app/routes.dart';

/// POS Cart Screen — Shows added items and a simulated RFID loyalty tap.
class PosCartScreen extends StatefulWidget {
  final Map<String, int> initialCart;

  const PosCartScreen({super.key, required this.initialCart});

  @override
  State<PosCartScreen> createState() => _PosCartScreenState();
}

class _PosCartScreenState extends State<PosCartScreen> {
  late Map<String, int> _cart;
  bool _rfidDetected = false;
  String _customerName = '';

  @override
  void initState() {
    super.initState();
    _cart = Map.from(widget.initialCart);
  }

  double get _subtotal {
    double sum = 0;
    _cart.forEach((id, qty) {
      final p = findProductById(id);
      sum += p.price * qty;
    });
    return sum;
  }

  void _simulateRfid() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text('Searching for RFID card...', style: AppTextStyles.labelLg),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.of(context).pop();

    setState(() {
      _rfidDetected = true;
      _customerName = 'Verified Customer';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Loyalty Card Detected: Verified Customer')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('POS Checkout')),
      body: Column(
        children: [
          if (_rfidDetected)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.successBg,
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: AppColors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CUSTOMER: $_customerName', style: AppTextStyles.labelLg.copyWith(color: AppColors.success)),
                        Text('Loyalty points will be added after checkout.', style: AppTextStyles.bodySm),
                      ],
                    ),
                  ),
                  TextButton(onPressed: () => setState(() => _rfidDetected = false), child: const Text('Remove')),
                ],
              ),
            )
          else
            InkWell(
              onTap: _simulateRfid,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                color: AppColors.primaryContainer.withValues(alpha: 0.3),
                child: Row(
                  children: [
                    const Icon(Icons.contactless_rounded, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Tap Customer Loyalty Card', style: AppTextStyles.labelLg.copyWith(color: AppColors.primaryDark))),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text('Order Summary', style: AppTextStyles.titleMd),
                const SizedBox(height: 10),
                ..._cart.entries.map((e) {
                  final p = findProductById(e.key);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(p.name, style: AppTextStyles.labelLg),
                    subtitle: Text('₱${p.price.toStringAsFixed(0)} x ${e.value}'),
                    trailing: Text('₱${(p.price * e.value).toStringAsFixed(0)}', style: AppTextStyles.labelLg),
                  );
                }),
                const Divider(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal', style: AppTextStyles.bodyMd),
                    Text('₱${_subtotal.toStringAsFixed(0)}', style: AppTextStyles.bodyMd),
                  ],
                ),
                if (_rfidDetected)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Loyalty Discount (Demo)', style: AppTextStyles.bodyMd.copyWith(color: AppColors.success)),
                      Text('-₱50.00', style: AppTextStyles.bodyMd.copyWith(color: AppColors.success)),
                    ],
                  ),
              ],
            ),
          ),
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
                        Text('TOTAL PAYABLE', style: AppTextStyles.bodySm),
                        Text('₱${(_subtotal - (_rfidDetected ? 50 : 0)).toStringAsFixed(0)}', style: AppTextStyles.headlineSm.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: PrimaryButton(
                      label: 'Next: Payment',
                      onPressed: () => Navigator.of(context).pushNamed(
                        AppRoutes.staffPosPayment,
                        arguments: {
                          'amount': _subtotal - (_rfidDetected ? 50 : 0),
                          'cart': _cart,
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Payment selection screen for Staff.
class PosPaymentScreen extends StatelessWidget {
  final double amount;
  final Map<String, int> cart;
  const PosPaymentScreen({super.key, required this.amount, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('Select Payment Method')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text('Total Amount to Collect', style: AppTextStyles.bodyMd),
          Text('₱${amount.toStringAsFixed(2)}', style: AppTextStyles.headlineLg.copyWith(color: AppColors.primary)),
          const SizedBox(height: AppSpacing.lg),
          _PaymentOption(
            icon: Icons.money_rounded,
            title: 'Cash',
            subtitle: 'Collect physical cash from customer',
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.staffPosCashInput,
              arguments: {'amount': amount, 'cart': cart},
            ),
          ),
          const SizedBox(height: 12),
          _PaymentOption(
            icon: Icons.account_balance_wallet_rounded,
            title: 'GCash',
            subtitle: 'Scan customer QR or confirm via terminal',
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.staffPosProcessing,
              arguments: {'method': 'GCash', 'amount': amount, 'cart': cart},
            ),
          ),
          const SizedBox(height: 12),
          _PaymentOption(
            icon: Icons.credit_card_rounded,
            title: 'Card (Visa/Mastercard)',
            subtitle: 'Use connected card terminal',
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.staffPosProcessing,
              arguments: {'method': 'Card', 'amount': amount, 'cart': cart},
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PaymentOption({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.surfaceContainerLow, shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.labelLg),
                  Text(subtitle, style: AppTextStyles.bodySm),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// Cash input screen for Staff.
class PosCashInputScreen extends StatefulWidget {
  final double amount;
  final Map<String, int> cart;

  const PosCashInputScreen({super.key, required this.amount, required this.cart});

  @override
  State<PosCashInputScreen> createState() => _PosCashInputScreenState();
}

class _PosCashInputScreenState extends State<PosCashInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  double _received = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _received = double.tryParse(_controller.text) ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double change = _received > widget.amount ? _received - widget.amount : 0;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('Cash Payment')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Total to Pay', style: AppTextStyles.bodyMd),
              Text('₱${widget.amount.toStringAsFixed(2)}', style: AppTextStyles.headlineLg.copyWith(color: AppColors.primary)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppTextStyles.headlineMd,
                autofocus: true,
                validator: (v) {
                  final requiredError = ValidationUtils.validateRequired(v, 'Amount Received');
                  if (requiredError != null) return requiredError;
                  final val = double.tryParse(v!) ?? 0;
                  if (val < widget.amount) {
                    return 'Amount must be at least ₱${widget.amount.toStringAsFixed(2)}';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Amount Received',
                  prefixText: '₱ ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Change Due', style: AppTextStyles.labelLg),
                    Text('₱${change.toStringAsFixed(2)}', style: AppTextStyles.headlineSm.copyWith(color: AppColors.success)),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Complete Payment',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).pushReplacementNamed(
                      AppRoutes.staffPosReceipt,
                      arguments: {
                        'method': 'Cash',
                        'amount': widget.amount,
                        'cart': widget.cart,
                        'cashReceived': _received,
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simulated processing screen.
class PosProcessingScreen extends StatefulWidget {
  final String method;
  final double amount;
  final Map<String, int> cart;
  const PosProcessingScreen({super.key, required this.method, required this.amount, required this.cart});

  @override
  State<PosProcessingScreen> createState() => _PosProcessingScreenState();
}

class _PosProcessingScreenState extends State<PosProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _process();
  }

  void _process() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    // Simulate random failure 1 in 5 times
    final success = DateTime.now().millisecond % 5 != 0;
    if (success) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.staffPosReceipt,
        arguments: {
          'method': widget.method,
          'amount': widget.amount,
          'cart': widget.cart,
        },
      );
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.staffPosFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text('Processing ${widget.method} Payment...', style: AppTextStyles.headlineSm),
            const SizedBox(height: 8),
            Text('Please wait, communicating with terminal...', style: AppTextStyles.bodyMd),
          ],
        ),
      ),
    );
  }
}

/// Receipt Screen (Success)
class PosReceiptScreen extends StatelessWidget {
  final String method;
  final double amount;
  final Map<String, int>? cart;
  final double? cashReceived;

  const PosReceiptScreen({
    super.key,
    this.method = 'GCash',
    this.amount = 245,
    this.cart,
    this.cashReceived,
  });

  @override
  Widget build(BuildContext context) {
    final double change = (cashReceived != null && cashReceived! > amount) ? cashReceived! - amount : 0;

    return Scaffold(
      backgroundColor: AppColors.successBg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 60),
            const SizedBox(height: 12),
            Text('Sale Completed!', style: AppTextStyles.headlineMd.copyWith(color: AppColors.success)),
            Text('Transaction #TXN-774218-MN', style: AppTextStyles.bodySm),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Text('MELAI\'S NUTS & DELICACIES', textAlign: TextAlign.center, style: AppTextStyles.labelLg),
                    Text('Official Receipt', textAlign: TextAlign.center, style: AppTextStyles.bodySm),
                    const Divider(height: 32),
                    if (cart != null) ...[
                      ...cart!.entries.map((e) {
                        final p = findProductById(e.key);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text('${p.name} x${e.value}', style: AppTextStyles.bodyMd)),
                              Text('₱${(p.price * e.value).toStringAsFixed(2)}', style: AppTextStyles.bodyMd),
                            ],
                          ),
                        );
                      }),
                      const Divider(height: 32),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TOTAL', style: AppTextStyles.labelLg),
                        Text('₱${amount.toStringAsFixed(2)}', style: AppTextStyles.labelLg.copyWith(color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Payment Method', style: AppTextStyles.bodySm),
                        Text(method, style: AppTextStyles.bodySm),
                      ],
                    ),
                    if (method == 'Cash' && cashReceived != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Cash Received', style: AppTextStyles.bodySm),
                          Text('₱${cashReceived!.toStringAsFixed(2)}', style: AppTextStyles.bodySm),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Change', style: AppTextStyles.labelLg),
                          Text('₱${change.toStringAsFixed(2)}', style: AppTextStyles.labelLg.copyWith(color: AppColors.success)),
                        ],
                      ),
                    ],
                    const Divider(height: 40),
                    const Center(child: Icon(Icons.qr_code_2_rounded, size: 100)),
                    const SizedBox(height: 8),
                    Text('Scan to download digital copy', textAlign: TextAlign.center, style: AppTextStyles.bodySm),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: PrimaryButton(
                label: 'New Transaction',
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.staffHome, (route) => false),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Payment Failed Screen
class PosFailedScreen extends StatelessWidget {
  const PosFailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.errorBg,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 80),
              const SizedBox(height: 24),
              Text('Payment Failed', style: AppTextStyles.headlineMd.copyWith(color: AppColors.error)),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text('Terminal reported a connection timeout. Please try again or use a different method.', textAlign: TextAlign.center),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                child: PrimaryButton(
                  label: 'Try Again',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 200,
                child: SecondaryButton(
                  label: 'Cancel Sale',
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.staffHome, (route) => false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
