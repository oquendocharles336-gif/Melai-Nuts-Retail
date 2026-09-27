import 'package:flutter/foundation.dart';
import '../../core/services/branch_controller.dart';
import 'package:melai_nuts/data/catalog_store.dart';
import '../../data/models/product.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/products_repository.dart';

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

/// App-wide shopping cart for the Customer portal.
///
/// The public API here is unchanged from the original in-memory version —
/// every mutation still applies to [_lines] synchronously so the UI updates
/// instantly — but each mutation now also persists to the customer's real
/// cart in Supabase (`carts` / `cart_items`) in the background via
/// [CartRepository], and [hydrate] loads that persisted cart back in on
/// sign-in. This is the standard "optimistic UI" pattern: the customer never
/// waits on a network round trip to see their own cart update, but the cart
/// is genuinely saved server-side and survives app restarts / device
/// switches for that account.
class CartController extends ChangeNotifier {
  CartController._();
  static final CartController instance = CartController._();

  final List<CartLine> _lines = [];
  List<CartLine> get lines => List.unmodifiable(_lines);

  /// Optional loyalty points redemption toggle (used on the Cart screen).
  bool redeemPoints = false;

  /// Currently applied promo/voucher code, if any.
  String? appliedVoucherCode;

  /// The customer's actually-selected branch (see [BranchController]), or a
  /// neutral placeholder before any branch has been picked. This used to be
  /// a hardcoded 'Calamba Branch' regardless of what the customer chose.
  String get currentBranch => BranchController.instance.selectedBranch?.name ?? 'Select a branch';

  String? _firebaseUid;
  String? _cartId;

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

  /// Loads this customer's persisted cart from Supabase. Call once after
  /// sign-in (see AuthService). Safe to call again to re-sync.
  Future<void> hydrate(String firebaseUid) async {
    _firebaseUid = firebaseUid;
    try {
      if (kProducts.isEmpty) {
        await ProductsRepository.instance.loadCatalog();
      }
      _cartId = await CartRepository.instance.getOrCreateOpenCartId(firebaseUid);
      final rows = await CartRepository.instance.fetchItems(_cartId!);
      _lines.clear();
      for (final row in rows) {
        final product = findProductById(row['product_id'] as String);
        final variantLabel = row['variant_label'] as String;
        final variant = product.variants.where((v) => v.label == variantLabel);
        if (variant.isEmpty) continue; // catalog changed under us; skip stale line
        _lines.add(
          CartLine(
            id: '${product.id}_$variantLabel',
            product: product,
            variant: variant.first,
            quantity: row['quantity'] as int,
          ),
        );
      }
      notifyListeners();
    } catch (_) {
      // Offline — keep whatever was already in memory for this session.
    }
  }

  Future<void> _ensureCartId() async {
    if (_cartId != null || _firebaseUid == null) return;
    try {
      _cartId = await CartRepository.instance.getOrCreateOpenCartId(_firebaseUid!);
    } catch (_) {
      // Will retry on the next mutation.
    }
  }

  void _syncUpsert(CartLine line) {
    if (_firebaseUid == null) return;
    () async {
      await _ensureCartId();
      final cartId = _cartId;
      if (cartId == null) return;
      try {
        await CartRepository.instance.upsertLine(
          cartId: cartId,
          productId: line.product.id,
          variantLabel: line.variant.label,
          quantity: line.quantity,
          unitPrice: line.variant.price,
        );
      } catch (_) {
        // Best-effort background sync; the in-memory cart is still correct
        // for this session and the next hydrate() will reconcile.
      }
    }();
  }

  void _syncRemove(String productId, String variantLabel) {
    final cartId = _cartId;
    if (cartId == null) return;
    CartRepository.instance
        .removeLine(cartId: cartId, productId: productId, variantLabel: variantLabel)
        .catchError((_) {});
  }

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

    CartLine line;
    if (existingIndex != -1) {
      _lines[existingIndex].quantity += addable;
      line = _lines[existingIndex];
    } else {
      line = CartLine(id: lineId, product: product, variant: variant, quantity: addable);
      _lines.add(line);
    }
    notifyListeners();
    _syncUpsert(line);
    return addable;
  }

  /// Sets the quantity for an existing cart line, capped at available
  /// stock (if known) and never allowed below 0 (0 removes the line).
  void updateQuantity(String lineId, int quantity) {
    final index = _lines.indexWhere((l) => l.id == lineId);
    if (index == -1) return;
    if (quantity <= 0) {
      final line = _lines.removeAt(index);
      notifyListeners();
      _syncRemove(line.product.id, line.variant.label);
      return;
    }
    final stock = _lines[index].variant.stockOnHand;
    _lines[index].quantity = stock != null && quantity > stock ? stock : quantity;
    notifyListeners();
    _syncUpsert(_lines[index]);
  }

  void removeLine(String lineId) {
    final index = _lines.indexWhere((l) => l.id == lineId);
    if (index == -1) return;
    final line = _lines.removeAt(index);
    notifyListeners();
    _syncRemove(line.product.id, line.variant.label);
  }

  void applyVoucher(String code) {
    appliedVoucherCode = code.trim().isEmpty ? null : code.trim().toUpperCase();
    notifyListeners();
  }

  /// Empties the cart lines shown in the UI. Used both for a plain "clear
  /// cart" action and right after checkout — in the checkout case, call
  /// [completeCheckout] instead so the server-side cart is closed out too.
  void clear() {
    _lines.clear();
    redeemPoints = false;
    appliedVoucherCode = null;
    notifyListeners();
  }

  /// Call after an order has been placed from this cart: closes the
  /// server-side cart (so the next add-to-cart opens a fresh one) and
  /// clears the local lines.
  Future<void> completeCheckout() async {
    final cartId = _cartId;
    _cartId = null;
    clear();
    if (cartId != null) {
      try {
        await CartRepository.instance.clearCart(cartId);
        await CartRepository.instance.markCheckedOut(cartId);
      } catch (_) {
        // Local cart is already cleared; server cleanup can lag safely.
      }
    }
  }

  /// Ends the cart session on sign-out: clears local lines and forgets
  /// which customer/cart they belonged to (the data itself stays safe in
  /// Supabase and reloads via [hydrate] next time this account signs in).
  void endSession() {
    _firebaseUid = null;
    _cartId = null;
    clear();
  }

  /// Quantity currently in the cart for a given product+variant, or 0.
  int quantityFor(String productId, String variantLabel) {
    final line = _lines.where((l) => l.id == '${productId}_$variantLabel');
    return line.isEmpty ? 0 : line.first.quantity;
  }
}
