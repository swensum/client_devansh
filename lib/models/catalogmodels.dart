library;

class Category {
  final String id;
  final String name;
  final String? imageUrl;

  const Category({required this.id, required this.name, this.imageUrl});

  factory Category.fromMap(String id, Map<String, dynamic> data) {
    return Category(
      id: id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'],
    );
  }
}

class Company {
  final String id;
  final String name;
  final String? imageUrl;

  const Company({required this.id, required this.name, this.imageUrl});

  factory Company.fromMap(String id, Map<String, dynamic> data) {
    return Company(
      id: id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'],
    );
  }
}

class MaterialType {
  final String id;
  final String name;

  const MaterialType({required this.id, required this.name});

  factory MaterialType.fromMap(String id, Map<String, dynamic> data) {
    return MaterialType(id: id, name: data['name'] ?? '');
  }
}

class ProductType {
  final String id;
  final String name;

  const ProductType({required this.id, required this.name});

  factory ProductType.fromMap(String id, Map<String, dynamic> data) {
    return ProductType(id: id, name: data['name'] ?? '');
  }
}

/// A single sellable model/variant of a product — e.g. one basket size,
/// identified by `model` code, with its own dimensions and stock status.
class ProductVariant {
  final String model;
  final String? width;
  final String? depth;
  final String? height;
  final String? availability;

  const ProductVariant({
    required this.model,
    this.width,
    this.depth,
    this.height,
    this.availability,
  });

  factory ProductVariant.fromMap(Map<String, dynamic> data) {
    return ProductVariant(
      model: data['model']?.toString() ?? '',
      width: data['width']?.toString(),
      depth: data['depth']?.toString(),
      height: data['height']?.toString(),
      availability: data['availability']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'model': model,
      'width': width,
      'depth': depth,
      'height': height,
      'availability': availability,
    };
  }
}

class Product {
  final String id;
  final String name;
  final String imageUrl; // Cloudinary URL (was imageAsset before)
  final double price;
  final String categoryId;
  final String? companyId;
  final String materialId;
  final String? typeId;
  final String? description;
  final String? thickness;
  final String? size;
  final String? quantity;
  final String? finish;
  final String? availability;
  final bool isTopProduct;

  /// Present only for products sold as multiple models (e.g. kitchen
  /// baskets). Empty for ordinary single-SKU products.
  final List<ProductVariant> variants;

  bool get hasVariants => variants.isNotEmpty;

  const Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.categoryId,
    this.companyId,
    required this.materialId,
    this.typeId,
    this.description,
    this.thickness,
    this.size,
    this.quantity,
    this.finish,
    this.availability,
    this.isTopProduct = false,
    this.variants = const [],
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      categoryId: data['categoryId'] ?? '',
      companyId: data['companyId'],
      materialId: data['materialId'] ?? '',
      typeId: data['typeId'],
      description: data['description'],
      thickness: data['thickness'],
      size: data['size'],
      quantity: data['quantity'],
      finish: data['finish'],
      availability: data['availability'],
      isTopProduct: data['isTopProduct'] ?? false,
      variants:
          (data['variants'] as List<dynamic>?)
              ?.map(
                (v) =>
                    ProductVariant.fromMap(Map<String, dynamic>.from(v as Map)),
              )
              .toList() ??
          const [],
    );
  }

  /// Mirrors `fromMap` — does NOT include `id` (same convention as
  /// Firestore documents, where the id is the doc id, not a field).
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'categoryId': categoryId,
      'companyId': companyId,
      'materialId': materialId,
      'typeId': typeId,
      'description': description,
      'thickness': thickness,
      'size': size,
      'quantity': quantity,
      'finish': finish,
      'availability': availability,
      'isTopProduct': isTopProduct,
      'variants': variants.map((v) => v.toMap()).toList(),
    };
  }
}
