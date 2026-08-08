import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:devansh/models/catalogmodels.dart';
import 'package:web/web.dart' as web;

class PendingOrderItem {
  final Product product;
  final ProductVariant? variant;
  int quantity;

  PendingOrderItem({
    required this.product,
    this.variant,
    required this.quantity,
  });
  String get lineKey =>
      variant != null ? '${product.id}::${variant!.model}' : product.id;

  Map<String, dynamic> toJson() {
    return {
      'productId': product.id,
      'product': product.toMap(),
      'variant': variant?.toMap(),
      'quantity': quantity,
    };
  }

  static PendingOrderItem? fromJson(Map<String, dynamic> json) {
    try {
      final productId = json['productId'] as String;
      final productMap = Map<String, dynamic>.from(json['product'] as Map);
      final product = Product.fromMap(productId, productMap);

      final variantJson = json['variant'];
      final variant = variantJson != null
          ? ProductVariant.fromMap(
              Map<String, dynamic>.from(variantJson as Map),
            )
          : null;

      final quantity = (json['quantity'] as num?)?.toInt() ?? 0;
      if (quantity <= 0) return null;

      return PendingOrderItem(
        product: product,
        variant: variant,
        quantity: quantity,
      );
    } catch (e) {
      debugPrint('PendingOrderItem: skipping unreadable cart line: $e');
      return null;
    }
  }
}

class OrderCartService {
  OrderCartService._() {
    _loadFromStorage();
  }
  static final OrderCartService instance = OrderCartService._();

  static const _storageKey = 'devansh_pending_order_items_v1';

  final ValueNotifier<List<PendingOrderItem>> items = ValueNotifier([]);

  /// Number of distinct order lines — this is what the header badge shows.
  int get count => items.value.length;

  void _loadFromStorage() {
    try {
      final raw = web.window.localStorage.getItem(_storageKey);
      if (raw == null || raw.isEmpty) return;

      final decoded = jsonDecode(raw) as List<dynamic>;
      final restored = decoded
          .map(
            (e) =>
                PendingOrderItem.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .whereType<PendingOrderItem>()
          .toList();

      items.value = restored;
    } catch (e) {
      debugPrint('OrderCartService: failed to load persisted cart: $e');
      _clearStorage();
    }
  }

  void _saveToStorage() {
    try {
      final encoded = jsonEncode(items.value.map((i) => i.toJson()).toList());
      web.window.localStorage.setItem(_storageKey, encoded);
    } catch (e) {
      debugPrint('OrderCartService: failed to persist cart: $e');
    }
  }

  void _clearStorage() {
    try {
      web.window.localStorage.removeItem(_storageKey);
    } catch (_) {}
  }

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
    _saveToStorage();
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
    _saveToStorage();
  }

  void removeAt(int index) {
    final updated = [...items.value]..removeAt(index);
    items.value = updated;
    _saveToStorage();
  }

  void clear() {
    items.value = [];
    _clearStorage();
  }
}
