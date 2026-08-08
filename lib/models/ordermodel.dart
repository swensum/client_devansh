import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devansh/services/orderservice.dart';


/// One line of a submitted order. Stores a full snapshot of the product
/// (and variant, if any) at the time of order — not just IDs — so that
/// later edits or deletions in the catalog never change what a past
/// order looked like.
class OrderItemRecord {
  final Map<String, dynamic> product; // Product.toMap() + 'id'
  final Map<String, dynamic>? variant; // ProductVariant.toMap()
  final String categoryName;
  final int quantity;

  const OrderItemRecord({
    required this.product,
    this.variant,
    required this.categoryName,
    required this.quantity,
  });

  factory OrderItemRecord.fromPendingItem(
    PendingOrderItem item,
    String categoryName,
  ) {
    return OrderItemRecord(
      product: {'id': item.product.id, ...item.product.toMap()},
      variant: item.variant?.toMap(),
      categoryName: categoryName,
      quantity: item.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product': product,
      'variant': variant,
      'categoryName': categoryName,
      'quantity': quantity,
    };
  }

  factory OrderItemRecord.fromMap(Map<String, dynamic> data) {
    return OrderItemRecord(
      product: Map<String, dynamic>.from(data['product'] as Map),
      variant: data['variant'] != null
          ? Map<String, dynamic>.from(data['variant'] as Map)
          : null,
      categoryName: data['categoryName']?.toString() ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
    );
  }

  String get productName => product['name']?.toString() ?? '';
  String get productImageUrl => product['imageUrl']?.toString() ?? '';
  String? get variantModel => variant?['model']?.toString();
}

class OrderRecord {
  final String? id;

  final String? userId;

  final String shopName;
  final String ownerName;
  final String phone;
  final String? email;
  final String address;
  final String? city;
  final String? taxId;
  final String? note;
  final List<OrderItemRecord> items;
  final int totalUnits;
  final String status; // 'pending' | 'confirmed' | 'cancelled' | ...
  final DateTime? createdAt;

  const OrderRecord({
    this.id,
    this.userId,
    required this.shopName,
    required this.ownerName,
    required this.phone,
    this.email,
    required this.address,
    this.city,
    this.taxId,
    this.note,
    required this.items,
    required this.totalUnits,
    this.status = 'pending',
    this.createdAt,
  });
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'shopName': shopName,
      'ownerName': ownerName,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'taxId': taxId,
      'note': note,
      'items': items.map((i) => i.toMap()).toList(),
      'totalUnits': totalUnits,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory OrderRecord.fromMap(String id, Map<String, dynamic> data) {
    return OrderRecord(
      id: id,
      userId: data['userId'] as String?,
      shopName: data['shopName']?.toString() ?? '',
      ownerName: data['ownerName']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      email: data['email'] as String?,
      address: data['address']?.toString() ?? '',
      city: data['city'] as String?,
      taxId: data['taxId'] as String?,
      note: data['note'] as String?,
      items: ((data['items'] as List<dynamic>?) ?? [])
          .map(
            (e) => OrderItemRecord.fromMap(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      totalUnits: (data['totalUnits'] as num?)?.toInt() ?? 0,
      status: data['status']?.toString() ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}