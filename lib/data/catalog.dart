/// Shared data models for the catalog, plus example/placeholder data.
///
/// This file is the one place that knows what a Category, Company, and
/// Product look like. When the Firebase-backed admin panel is wired up
/// later, only this file (or a repository built on top of it) needs to
/// change — the UI that reads from `kCategories` / `kCompanies` /
/// `kProducts` shouldn't need to change at all, as long as whatever
/// replaces them still returns `List<Category>`, `List<Company>`, and
/// `List<Product>`.
library;

/// A product category — the primary way people browse (Hinges, Aldrops,
/// Chimneys, Baskets, ...). Every product belongs to exactly one.
class Category {
  final String id;
  final String name;
  // Used as the small banner image at the top of the products page for
  // this category. Optional — falls back to the first matching
  // product's image if left null (see Catalog.bannerFor).
  final String? bannerAsset;

  const Category({required this.id, required this.name, this.bannerAsset});
}

/// A manufacturer/brand. Not every product has one — `Product.companyId`
/// is nullable — and a company is never restricted to a fixed set of
/// categories; whatever it happens to sell is whatever it sells.
class Company {
  final String id;
  final String name;
  final String? logoAsset;

  const Company({required this.id, required this.name, this.logoAsset});
}

class Product {
  final String id;
  final String name;
  final String imageAsset;
  final double price;
  final String categoryId;
  final String? companyId; // null = no associated company

  const Product({
    required this.id,
    required this.name,
    required this.imageAsset,
    required this.price,
    required this.categoryId,
    this.companyId,
  });
}

// ---------------------------------------------------------------------
// Example data. Replace this whole block with a Firestore-backed fetch
// later; everything below this comment is what you'll eventually delete.
// ---------------------------------------------------------------------

const List<Category> kCategories = [
  Category(id: 'handles', name: 'Cabinet Handles', bannerAsset: 'assets/port.jpg'),
  Category(id: 'hinges', name: 'Hinges', bannerAsset: 'assets/port3.png'),
  Category(id: 'aldrops', name: 'Aldrops', bannerAsset: 'assets/port2.png'),
  Category(id: 'locks', name: 'Locks', bannerAsset: 'assets/port.jpg'),
  Category(id: 'chimneys', name: 'Chimneys', bannerAsset: 'assets/port2.png'),
  Category(id: 'baskets', name: 'Baskets', bannerAsset: 'assets/port3.png'),
];

const List<Company> kCompanies = [
  Company(id: 'devansh', name: 'Devansh Hardware', logoAsset: 'assets/logo.png'),
  Company(id: 'nova', name: 'Nova Fittings'),
  Company(id: 'hearth_co', name: 'Hearth & Co.'),
  Company(id: 'basketry', name: 'Basketry Works'),
];
const List<Product> kProducts = [
  // Devansh — sells across several categories.
  Product(
    id: 'p1',
    name: 'Matte Black Cabinet Handle',
    imageAsset: 'assets/port.jpg',
    price: 12.99,
    categoryId: 'handles',
    companyId: 'devansh',
  ),
  Product(
    id: 'p2',
    name: 'Premium Soft-Close Hinge',
    imageAsset: 'assets/port3.png',
    price: 9.75,
    categoryId: 'hinges',
    companyId: 'devansh',
  ),
  Product(
    id: 'p3',
    name: 'Modern Aldrop Lock',
    imageAsset: 'assets/port.jpg',
    price: 24.00,
    categoryId: 'aldrops',
    companyId: 'devansh',
  ),

  // Nova — hinges + handles only.
  Product(
    id: 'p4',
    name: 'Concealed Door Hinge',
    imageAsset: 'assets/port3.png',
    price: 11.00,
    categoryId: 'hinges',
    companyId: 'nova',
  ),
  Product(
    id: 'p5',
    name: 'Brushed Steel Door Handle',
    imageAsset: 'assets/port2.png',
    price: 18.50,
    categoryId: 'handles',
    companyId: 'nova',
  ),

  // Hearth & Co. — chimneys only.
  Product(
    id: 'p6',
    name: 'Stainless Chimney Hood',
    imageAsset: 'assets/port2.png',
    price: 89.00,
    categoryId: 'chimneys',
    companyId: 'hearth_co',
  ),

  // Basketry Works — baskets only.
  Product(
    id: 'p7',
    name: 'Pull-Out Wire Basket',
    imageAsset: 'assets/port3.png',
    price: 22.50,
    categoryId: 'baskets',
    companyId: 'basketry',
  ),

  // Generic / unaffiliated items.
  Product(
    id: 'p8',
    name: 'Generic Tower Bolt',
    imageAsset: 'assets/port.jpg',
    price: 8.50,
    categoryId: 'locks',
    companyId: null,
  ),
  Product(
    id: 'p9',
    name: 'Basic Cabinet Knob',
    imageAsset: 'assets/port2.png',
    price: 6.25,
    categoryId: 'handles',
    companyId: null,
  ),

  // ---------- 15 NEW PRODUCTS (p10 – p24) ----------

  Product(
    id: 'p10',
    name: 'Brass Cabinet Pull',
    imageAsset: 'assets/port2.png',
    price: 14.25,
    categoryId: 'handles',
    companyId: 'devansh',
  ),
  Product(
    id: 'p11',
    name: 'Zinc Alloy Hinge',
    imageAsset: 'assets/port.jpg',
    price: 7.50,
    categoryId: 'hinges',
    companyId: 'nova',
  ),
  Product(
    id: 'p12',
    name: 'Heavy Duty Aldrop',
    imageAsset: 'assets/port3.png',
    price: 31.00,
    categoryId: 'aldrops',
    companyId: 'devansh',
  ),
  Product(
    id: 'p13',
    name: 'Round Wire Basket',
    imageAsset: 'assets/port.jpg',
    price: 18.75,
    categoryId: 'baskets',
    companyId: 'basketry',
  ),
  Product(
    id: 'p14',
    name: 'Keyless Door Lock',
    imageAsset: 'assets/port2.png',
    price: 15.00,
    categoryId: 'locks',
    companyId: null,
  ),
  Product(
    id: 'p15',
    name: 'Satin Nickel Handle',
    imageAsset: 'assets/port3.png',
    price: 21.50,
    categoryId: 'handles',
    companyId: 'nova',
  ),
  Product(
    id: 'p16',
    name: 'Telescopic Chimney Pipe',
    imageAsset: 'assets/port.jpg',
    price: 45.00,
    categoryId: 'chimneys',
    companyId: 'hearth_co',
  ),
  Product(
    id: 'p17',
    name: 'Flush Aldrop Lock',
    imageAsset: 'assets/port2.png',
    price: 19.99,
    categoryId: 'aldrops',
    companyId: null,
  ),
  Product(
    id: 'p18',
    name: 'Drawer Basket Slide',
    imageAsset: 'assets/port3.png',
    price: 12.00,
    categoryId: 'baskets',
    companyId: 'basketry',
  ),
  Product(
    id: 'p19',
    name: 'Curved Door Handle',
    imageAsset: 'assets/port.jpg',
    price: 16.40,
    categoryId: 'handles',
    companyId: 'devansh',
  ),
  Product(
    id: 'p20',
    name: 'Spring Loaded Hinge',
    imageAsset: 'assets/port2.png',
    price: 8.25,
    categoryId: 'hinges',
    companyId: 'nova',
  ),
  Product(
    id: 'p21',
    name: 'Steel Tower Bolt',
    imageAsset: 'assets/port3.png',
    price: 10.50,
    categoryId: 'locks',
    companyId: null,
  ),
  Product(
    id: 'p22',
    name: 'Chimney Cap Cover',
    imageAsset: 'assets/port.jpg',
    price: 67.00,
    categoryId: 'chimneys',
    companyId: 'hearth_co',
  ),
  Product(
    id: 'p23',
    name: 'Glass Cabinet Knob',
    imageAsset: 'assets/port2.png',
    price: 5.75,
    categoryId: 'handles',
    companyId: null,
  ),
  Product(
    id: 'p24',
    name: 'Pivot Hinge for Doors',
    imageAsset: 'assets/port3.png',
    price: 13.80,
    categoryId: 'hinges',
    companyId: 'devansh',
  ),
];

class Catalog {
  /// Products in a given category.
  static List<Product> byCategory(String categoryId) =>
      kProducts.where((p) => p.categoryId == categoryId).toList();

  /// Products in a given category, further filtered to one company.
  /// Pass `companyId: null` to mean "no filter", not "no company".
  static List<Product> byCategoryAndCompany(String categoryId, String? companyId) {
    final inCategory = byCategory(categoryId);
    if (companyId == null) return inCategory;
    return inCategory.where((p) => p.companyId == companyId).toList();
  }

  /// The company for a product, or null if it doesn't have one.
  static Company? companyFor(Product product) {
    if (product.companyId == null) return null;
    for (final c in kCompanies) {
      if (c.id == product.companyId) return c;
    }
    return null;
  }

  /// The banner image for a category — its own `bannerAsset` if set,
  /// otherwise the first product image found in that category, so the
  /// products page always has something to show even before banners are
  /// set up in the admin panel.
  static String? bannerFor(String categoryId) {
    final category = kCategories.firstWhere((c) => c.id == categoryId);
    if (category.bannerAsset != null) return category.bannerAsset;
    final products = byCategory(categoryId);
    return products.isNotEmpty ? products.first.imageAsset : null;
  }

  /// Companies that have at least one product in the given category —
  /// computed on the fly, never stored, so a company's category list is
  /// always exactly whatever it actually sells.
  static List<Company> companiesInCategory(String categoryId) {
    final companyIds = byCategory(categoryId)
        .map((p) => p.companyId)
        .whereType<String>() // drops nulls
        .toSet();
    return kCompanies.where((c) => companyIds.contains(c.id)).toList();
  }
}