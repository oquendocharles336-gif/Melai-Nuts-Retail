import 'package:flutter/foundation.dart';
import '../../data/models/product.dart';

/// One line in the shopping cart: a product + chosen variant + quantity.
class CartLine {
  final String id;
  final Product product;
  final ProductVariant variant;
  int quantity;

  CartLine({
    required this.id,
    required this.product,
    required this.variant,
    this.quantity = 1,
  });

  double get lineTotal => variant.price * quantity;
}

/// App-wide, in-memory shopping cart for the Customer portal.
///
/// This is a simple [ChangeNotifier] singleton — there is no backend, so
/// nothing here is persisted between app launches. It exists purely so
/// Cart/Catalog/Checkout screens can share state without prop-drilling.
class CartController extends ChangeNotifier {
  CartController._();
  static final CartController instance = CartController._();

  final List<CartLine> _lines = [];
  List<CartLine> get lines => List.unmodifiable(_lines);

  /// Optional loyalty points redemption toggle (used on the Cart screen).
  bool redeemPoints = false;

  /// Currently applied promo/voucher code, if any.
  String? appliedVoucherCode;

  String currentBranch = 'Calamba Branch';

  int get itemCount => _lines.fold(0, (sum, l) => sum + l.quantity);

  double get subtotal => _lines.fold(0, (sum, l) => sum + l.lineTotal);

  double get loyaltyDiscount => redeemPoints ? 5 : 0;

  double get voucherDiscount => appliedVoucherCode != null ? 15 : 0;

  double get deliveryFee => _lines.isEmpty ? 0 : 45;

  double get total =>
      (subtotal - loyaltyDiscount - voucherDiscount + deliveryFee).clamp(
        0,
        double.infinity,
      );

  void addProduct(Product product, ProductVariant variant, {int quantity = 1}) {
    final lineId = '${product.id}_${variant.label}';
    final existingIndex = _lines.indexWhere((l) => l.id == lineId);
    if (existingIndex != -1) {
      _lines[existingIndex].quantity += quantity;
    } else {
      _lines.add(
        CartLine(id: lineId, product: product, variant: variant, quantity: quantity),
      );
    }
    notifyListeners();
  }

  void updateQuantity(String lineId, int quantity) {
    final index = _lines.indexWhere((l) => l.id == lineId);
    if (index == -1) return;
    if (quantity <= 0) {
      _lines.removeAt(index);
    } else {
      _lines[index].quantity = quantity;
    }
    notifyListeners();
  }

  void removeLine(String lineId) {
    _lines.removeWhere((l) => l.id == lineId);
    notifyListeners();
  }

  void applyVoucher(String code) {
    appliedVoucherCode = code.trim().isEmpty ? null : code.trim().toUpperCase();
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    redeemPoints = false;
    appliedVoucherCode = null;
    notifyListeners();
  }

  /// Quantity currently in the cart for a given product+variant, or 0.
  int quantityFor(String productId, String variantLabel) {
    final line = _lines.where((l) => l.id == '${productId}_$variantLabel');
    return line.isEmpty ? 0 : line.first.quantity;
  }
}
