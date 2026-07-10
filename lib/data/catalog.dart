library;

class Category {
  final String id;
  final String name;
 
  final String? bannerAsset;

  const Category({required this.id, required this.name, this.bannerAsset});
}

class Company {
  final String id;
  final String name;
  final String? logoAsset;

  const Company({required this.id, required this.name, this.logoAsset});
}

class MaterialType {
  final String id;
  final String name;

  const MaterialType({required this.id, required this.name});
}

class Product {
  final String id;
  final String name;
  final String imageAsset;
  final double price;
  final String categoryId;
  final String? companyId; // null = no associated company
  final String materialId; // e.g. 'aluminium', 'silver', 'metal', 'ss'
final String? description;
  final String? thickness;
  final String? size;
  final String? quantity;
  final String? finish;
  final String? availability;

  const Product({
    required this.id,
    required this.name,
    required this.imageAsset,
    required this.price,
    required this.categoryId,
    this.companyId,
    required this.materialId,
    this.description,
    this.thickness,
    this.size,
    this.quantity,
    this.finish,
    this.availability,
  });
}


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
  Company(id: 'unknown', name: 'Unknown'),
  Company(id: 'others', name: 'others'),
];

const List<MaterialType> kMaterials = [
  MaterialType(id: 'aluminium', name: 'Aluminium'),
  MaterialType(id: 'silver', name: 'Silver'),
  MaterialType(id: 'metal', name: 'Metal'),
  MaterialType(id: 'ss', name: 'Stainless Steel'),
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
  materialId: 'aluminium',
  description: 'A sleek, minimal handle designed for modern cabinetry A sleek, minimal handle designed for modern cabinetry A sleek, minimal handle designed for modern cabinetry A sleek, minimal handle designed for modern cabinetry.',
  thickness: '3mm',
  size: '128mm center-to-center',
  quantity: 'Pack of 2',
  finish: 'Matte Black',
  availability: 'In Stock',
),
  Product(
  id: 'p6',
  name: 'Stainless Chimney Hood',
  imageAsset: 'assets/port2.png',
  price: 89.00,
  categoryId: 'chimneys',
  companyId: 'hearth_co',
  materialId: 'ss',
  description: 'High-suction chimney hood built for daily kitchen use.',
  // no thickness/size/quantity/finish set — those rows just won't appear
  availability: 'Made to Order',
),
  Product(
    id: 'p3',
    name: 'Modern Aldrop Lock',
    imageAsset: 'assets/port.jpg',
    price: 24.00,
    categoryId: 'aldrops',
    companyId: 'devansh',
    materialId: 'metal',
  ),

  // Nova — hinges + handles only.
  Product(
    id: 'p4',
    name: 'Concealed Door Hinge',
    imageAsset: 'assets/port3.png',
    price: 11.00,
    categoryId: 'hinges',
    companyId: 'nova',
    materialId: 'metal',
  ),
  Product(
    id: 'p5',
    name: 'Brushed Steel Door Handle',
    imageAsset: 'assets/port2.png',
    price: 18.50,
    categoryId: 'handles',
    companyId: 'nova',
    materialId: 'ss',
  ),

  // Hearth & Co. — chimneys only.
  Product(
    id: 'p6',
    name: 'Stainless Chimney Hood',
    imageAsset: 'assets/port2.png',
    price: 89.00,
    categoryId: 'chimneys',
    companyId: 'hearth_co',
    materialId: 'ss',
  ),

  // Basketry Works — baskets only.
  Product(
    id: 'p7',
    name: 'Pull-Out Wire Basket',
    imageAsset: 'assets/port3.png',
    price: 22.50,
    categoryId: 'baskets',
    companyId: 'basketry',
    materialId: 'metal',
  ),

  // Generic / unaffiliated items.
  Product(
    id: 'p8',
    name: 'Generic Tower Bolt',
    imageAsset: 'assets/port.jpg',
    price: 8.50,
    categoryId: 'handles',
    companyId: 'others',
    materialId: 'metal',
  ),
  Product(
    id: 'p9',
    name: 'Basic Cabinet Knob',
    imageAsset: 'assets/port2.png',
    price: 6.25,
    categoryId: 'handles',
    companyId: 'unknown',
    materialId: 'aluminium',
  ),

  // ---------- 15 NEW PRODUCTS (p10 – p24) ----------

  Product(
    id: 'p10',
    name: 'Brass Cabinet Pull',
    imageAsset: 'assets/port2.png',
    price: 14.25,
    categoryId: 'handles',
    companyId: 'devansh',
    materialId: 'metal',
  ),
  Product(
    id: 'p11',
    name: 'Zinc Alloy Hinge',
    imageAsset: 'assets/port.jpg',
    price: 7.50,
    categoryId: 'hinges',
    companyId: 'nova',
    materialId: 'aluminium',
  ),
  Product(
    id: 'p12',
    name: 'Heavy Duty Aldrop',
    imageAsset: 'assets/port3.png',
    price: 31.00,
    categoryId: 'aldrops',
    companyId: 'devansh',
    materialId: 'ss',
  ),
  Product(
    id: 'p13',
    name: 'Round Wire Basket',
    imageAsset: 'assets/port.jpg',
    price: 18.75,
    categoryId: 'baskets',
    companyId: 'basketry',
    materialId: 'ss',
  ),
  Product(
    id: 'p14',
    name: 'Keyless Door Lock',
    imageAsset: 'assets/port2.png',
    price: 15.00,
    categoryId: 'locks',
    companyId: null,
    materialId: 'metal',
  ),
  Product(
    id: 'p15',
    name: 'Satin Nickel Handle',
    imageAsset: 'assets/port3.png',
    price: 21.50,
    categoryId: 'handles',
    companyId: 'nova',
    materialId: 'silver',
  ),
];

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
    required String categoryId,
    String? companyId,
    String? materialId,
  }) {
    var result = byCategory(categoryId);
    if (companyId != null) {
      result = result.where((p) => p.companyId == companyId).toList();
    }
    if (materialId != null) {
      result = result.where((p) => p.materialId == materialId).toList();
    }
    return result;
  }

  /// The company for a product, or null if it doesn't have one.
  static Company? companyFor(Product product) {
    if (product.companyId == null) return null;
    for (final c in kCompanies) {
      if (c.id == product.companyId) return c;
    }
    return null;
  }

  /// The material for a product.
  static MaterialType? materialFor(Product product) {
    for (final m in kMaterials) {
      if (m.id == product.materialId) return m;
    }
    return null;
  }

  static String? bannerFor(String categoryId) {
    final category = kCategories.firstWhere((c) => c.id == categoryId);
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
  final materialIds = byCategory(categoryId).map((p) => p.materialId).toSet();
  return kMaterials.where((m) => materialIds.contains(m.id)).toList();
}
}