library;

/// ---------------------------------------------------------------------
/// MODELS
/// Each model now has a `fromMap` factory so it can be built directly
/// from a Firestore document snapshot (id + data map).
/// ---------------------------------------------------------------------

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
    );
  }
}