import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:devansh/models/catalogmodels.dart';


/// ---------------------------------------------------------------------
/// SERVICE
/// Live Firestore streams — same collections your admin panel writes to:
/// categories, companies, materials, productTypes, products
/// ---------------------------------------------------------------------

class CatalogService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---- Categories ----
  Stream<List<Category>> watchCategories() {
    return _db.collection('categories').orderBy('name').snapshots().map(
          (snap) => snap.docs
              .map((d) => Category.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<Category?> getCategory(String id) async {
    final doc = await _db.collection('categories').doc(id).get();
    if (!doc.exists) return null;
    return Category.fromMap(doc.id, doc.data()!);
  }

  // ---- Companies ----
  Stream<List<Company>> watchCompanies() {
    return _db.collection('companies').orderBy('name').snapshots().map(
          (snap) =>
              snap.docs.map((d) => Company.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<Company?> getCompany(String id) async {
    final doc = await _db.collection('companies').doc(id).get();
    if (!doc.exists) return null;
    return Company.fromMap(doc.id, doc.data()!);
  }

  // ---- Materials ----
  Stream<List<MaterialType>> watchMaterials() {
    return _db.collection('materials').orderBy('name').snapshots().map(
          (snap) => snap.docs
              .map((d) => MaterialType.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<MaterialType?> getMaterial(String id) async {
    final doc = await _db.collection('materials').doc(id).get();
    if (!doc.exists) return null;
    return MaterialType.fromMap(doc.id, doc.data()!);
  }

  // ---- Product Types ----
  Stream<List<ProductType>> watchProductTypes() {
    return _db.collection('productTypes').orderBy('name').snapshots().map(
          (snap) => snap.docs
              .map((d) => ProductType.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<ProductType?> getProductType(String id) async {
    final doc = await _db.collection('productTypes').doc(id).get();
    if (!doc.exists) return null;
    return ProductType.fromMap(doc.id, doc.data()!);
  }

  // ---- Products ----

  /// All products, newest first.
  Stream<List<Product>> watchProducts() {
    return _db
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Product.fromMap(d.id, d.data())).toList());
  }

  /// Products in a single category — mirrors Catalog.byCategory from before.
  Stream<List<Product>> watchProductsByCategory(String categoryId) {
    return _db
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Product.fromMap(d.id, d.data())).toList());
  }

  /// Products flagged as top products (isTopProduct == true).
  Stream<List<Product>> watchTopProducts() {
    return _db
        .collection('products')
        .where('isTopProduct', isEqualTo: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Product.fromMap(d.id, d.data())).toList());
  }

  /// One-time fetch of a single product (e.g. product detail page).
  Future<Product?> getProduct(String id) async {
    final doc = await _db.collection('products').doc(id).get();
    if (!doc.exists) return null;
    return Product.fromMap(doc.id, doc.data()!);
  }
}