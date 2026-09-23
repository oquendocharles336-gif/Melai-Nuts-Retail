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

  /// Adds [quantity] of [product]/[variant] to the cart. If the variant has
  /// known stock information, the resulting cart quantity is capped at
  /// what's actually available — it never silently adds more than exists.
  /// Returns the quantity that was actually added (may be less than
  /// requested, or 0 if the variant is already at its stock limit).
  int addProduct(Product product, ProductVariant variant, {int quantity = 1}) {
    if (quantity <= 0) return 0;

    final lineId = '${product.id}_${variant.label}';
    final existingIndex = _lines.indexWhere((l) => l.id == lineId);
    final currentQty = existingIndex == -1 ? 0 : _lines[existingIndex].quantity;

    var addable = quantity;
    final stock = variant.stockOnHand;
    if (stock != null) {
      final remaining = stock - currentQty;
      addable = remaining < quantity ? (remaining < 0 ? 0 : remaining) : quantity;
    }
    if (addable <= 0) {
      notifyListeners();
      return 0;
    }

    if (existingIndex != -1) {
      _lines[existingIndex].quantity += addable;
    } else {
      _lines.add(
        CartLine(id: lineId, product: product, variant: variant, quantity: addable),
      );
    }
    notifyListeners();
    return addable;
  }

  /// Sets the quantity for an existing cart line, capped at available
  /// stock (if known) and never allowed below 0 (0 removes the line).
  void updateQuantity(String lineId, int quantity) {
    final index = _lines.indexWhere((l) => l.id == lineId);
    if (index == -1) return;
    if (quantity <= 0) {
      _lines.removeAt(index);
    } else {
      final stock = _lines[index].variant.stockOnHand;
      _lines[index].quantity = stock != null && quantity > stock ? stock : quantity;
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
