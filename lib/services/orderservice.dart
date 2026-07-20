import 'package:flutter/foundation.dart';
import 'package:devansh/models/catalogmodels.dart';

class PendingOrderItem {
  final Product product;
  int quantity;

  PendingOrderItem({required this.product, required this.quantity});
}
class OrderCartService {
  OrderCartService._();
  static final OrderCartService instance = OrderCartService._();

  final ValueNotifier<List<PendingOrderItem>> items = ValueNotifier([]);

  /// Number of distinct order lines — this is what the header badge shows.
  int get count => items.value.length;

  void addItem(Product product, int quantity) {
    final existingIndex = items.value.indexWhere((i) => i.product.id == product.id);
    final updated = [...items.value];
    if (existingIndex != -1) {
      updated[existingIndex] = PendingOrderItem(
        product: updated[existingIndex].product,
        quantity: updated[existingIndex].quantity + quantity,
      );
    } else {
      updated.add(PendingOrderItem(product: product, quantity: quantity));
    }
    items.value = updated;
  }

  void updateQuantity(int index, int quantity) {
    if (quantity < 1) return;
    final updated = [...items.value];
    updated[index] = PendingOrderItem(product: updated[index].product, quantity: quantity);
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