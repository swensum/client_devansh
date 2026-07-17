library;

import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final String? bannerAsset; 

  const Category({required this.id, required this.name, this.bannerAsset});
}

class Company {
  final String id;
  final String name;
  final String? logoAsset; // now holds a Cloudinary URL, not an asset path

  const Company({required this.id, required this.name, this.logoAsset});
}

class MaterialType {
  final String id;
  final String name;

  const MaterialType({required this.id, required this.name});
}

class ProductType {
  final String id;
  final String name;

  const ProductType({required this.id, required this.name});
}

class Product {
  final String id;
  final String name;
  final String imageAsset; 
  final double price;
  final String categoryId;
  final String? companyId;
  final String? materialId; 
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
    required this.imageAsset,
    required this.price,
    required this.categoryId,
    this.companyId,
    this.materialId,
    this.typeId,
    this.description,
    this.thickness,
    this.size,
    this.quantity,
    this.finish,
    this.availability,
    this.isTopProduct = false,
  });
}

List<Category> kCategories = [];
List<Company> kCompanies = [];
List<MaterialType> kMaterials = [];
List<ProductType> kProductTypes = [];
List<Product> kProducts = [];

class CatalogRepository {
  CatalogRepository._();
  static final CatalogRepository instance = CatalogRepository._();

  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    final db = FirebaseFirestore.instance;

    final categoriesSnap = await db.collection('categories').get();
    kCategories = categoriesSnap.docs.map((d) {
      final data = d.data();
      return Category(
        id: d.id,
        name: data['name'] ?? '',
        bannerAsset: data['imageUrl'],
      );
    }).toList();

    final companiesSnap = await db.collection('companies').get();
    kCompanies = companiesSnap.docs.map((d) {
      final data = d.data();
      return Company(
        id: d.id,
        name: data['name'] ?? '',
        logoAsset: data['imageUrl'],
      );
    }).toList();

    final materialsSnap = await db.collection('materials').get();
    kMaterials = materialsSnap.docs
        .map((d) => MaterialType(id: d.id, name: d.data()['name'] ?? ''))
        .toList();

    final typesSnap = await db.collection('productTypes').get();
    kProductTypes = typesSnap.docs
        .map((d) => ProductType(id: d.id, name: d.data()['name'] ?? ''))
        .toList();

    final productsSnap = await db.collection('products').get();
    kProducts = productsSnap.docs.map((d) {
      final data = d.data();
      return Product(
        id: d.id,
        name: data['name'] ?? '',
        imageAsset: data['imageUrl'] ?? '',
        price: (data['price'] as num?)?.toDouble() ?? 0,
        categoryId: data['categoryId'] ?? '',
        companyId: data['companyId'],
        materialId: data['materialId'],
        typeId: data['typeId'],
        description: data['description'],
        thickness: data['thickness'],
        size: data['size'],
        quantity: data['quantity'],
        finish: data['finish'],
        availability: data['availability'],
        isTopProduct: data['isTopProduct'] ?? false,
      );
    }).toList();

    _loaded = true;
  }

  /// Call this if you ever need to force a re-fetch (e.g. pull-to-refresh).
  Future<void> reload() {
    _loaded = false;
    return load();
  }
}

class Catalog {
  /// Products in a given category.
  static List<Product> byCategory(String categoryId) =>
      kProducts.where((p) => p.categoryId == categoryId).toList();

  static List<Product> byCategoryAndCompany(String categoryId, String? companyId) {
    final inCategory = byCategory(categoryId);
    if (companyId == null) return inCategory;
    return inCategory.where((p) => p.companyId == companyId).toList();
  }

  static List<Product> filtered({
    String? categoryId,
    String? companyId,
    String? materialId,
    String? typeId,
  }) {
    return kProducts.where((p) {
      if (categoryId != null && p.categoryId != categoryId) return false;
      if (companyId != null && p.companyId != companyId) return false;
      if (materialId != null && p.materialId != materialId) return false;
      if (typeId != null && p.typeId != typeId) return false;
      return true;
    }).toList();
  }

  static List<ProductType> typesInCategory(String categoryId) {
    final typeIds = byCategory(categoryId)
        .map((p) => p.typeId)
        .whereType<String>() // drops nulls
        .toSet();
    return kProductTypes.where((t) => typeIds.contains(t.id)).toList();
  }

  /// The company for a product, or null if it doesn't have one.
  static Company? companyFor(Product product) {
    if (product.companyId == null) return null;
    for (final c in kCompanies) {
      if (c.id == product.companyId) return c;
    }
    return null;
  }

  /// The material for a product, or null if it doesn't have one.
  static MaterialType? materialFor(Product product) {
    if (product.materialId == null) return null;
    for (final m in kMaterials) {
      if (m.id == product.materialId) return m;
    }
    return null;
  }

  static List<Product> get topProducts => kProducts.where((p) => p.isTopProduct).toList();

  static String? bannerFor(String categoryId) {
    final matches = kCategories.where((c) => c.id == categoryId);
    if (matches.isEmpty) return null;
    final category = matches.first;
    if (category.bannerAsset != null) return category.bannerAsset;
    final products = byCategory(categoryId);
    return products.isNotEmpty ? products.first.imageAsset : null;
  }

  static List<Company> companiesInCategory(String categoryId) {
    final companyIds = byCategory(categoryId)
        .map((p) => p.companyId)
        .whereType<String>() // drops nulls
        .toSet();
    return kCompanies.where((c) => companyIds.contains(c.id)).toList();
  }

  static List<MaterialType> materialsInCategory(String categoryId) {
    final materialIds = byCategory(categoryId)
        .map((p) => p.materialId)
        .whereType<String>() // drops nulls
        .toSet();
    return kMaterials.where((m) => materialIds.contains(m.id)).toList();
  }
}