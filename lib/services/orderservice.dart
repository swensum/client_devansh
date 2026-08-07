import 'package:flutter/foundation.dart';
import 'package:devansh/models/catalogmodels.dart';

class PendingOrderItem {
  final Product product;
  final ProductVariant? variant;
  int quantity;

  PendingOrderItem({
    required this.product,
    this.variant,
    required this.quantity,
  });

  /// Identity for a cart line: same product but a different model is a
  /// different line, so they don't get merged together.
  String get lineKey =>
      variant != null ? '${product.id}::${variant!.model}' : product.id;
}

class OrderCartService {
  OrderCartService._();
  static final OrderCartService instance = OrderCartService._();

  final ValueNotifier<List<PendingOrderItem>> items = ValueNotifier([]);

  /// Number of distinct order lines — this is what the header badge shows.
  int get count => items.value.length;

  void addItem(Product product, int quantity, {ProductVariant? variant}) {
    final key = variant != null
        ? '${product.id}::${variant.model}'
        : product.id;
    final existingIndex = items.value.indexWhere((i) => i.lineKey == key);
    final updated = [...items.value];
    if (existingIndex != -1) {
      updated[existingIndex] = PendingOrderItem(
        product: updated[existingIndex].product,
        variant: updated[existingIndex].variant,
        quantity: updated[existingIndex].quantity + quantity,
      );
    } else {
      updated.add(
        PendingOrderItem(
          product: product,
          variant: variant,
          quantity: quantity,
        ),
      );
    }
    items.value = updated;
  }

  void updateQuantity(int index, int quantity) {
    if (quantity < 1) return;
    final updated = [...items.value];
    updated[index] = PendingOrderItem(
      product: updated[index].product,
      variant: updated[index].variant,
      quantity: quantity,
    );
    items.value = updated;
  }

  void removeAt(int index) {
    final updated = [...items.value]..removeAt(index);
    items.value = updated;
  }

  void clear() {
    items.value = [];
  }
}
