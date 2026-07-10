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

  const Product({
    required this.id,
    required this.name,
    required this.imageAsset,
    required this.price,
    required this.categoryId,
    this.companyId,
    required this.materialId,
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
  ),
  Product(
    id: 'p2',
    name: 'Premium Soft-Close Hinge',
    imageAsset: 'assets/port3.png',
    price: 9.75,
    categoryId: 'hinges',
    companyId: 'devansh',
    materialId: 'ss',
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
    materialId: 'ss',
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
    materialId: 'metal',
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
  Product(
    id: 'p16',
    name: 'Telescopic Chimney Pipe',
    imageAsset: 'assets/port.jpg',
    price: 45.00,
    categoryId: 'chimneys',
    companyId: 'hearth_co',
    materialId: 'aluminium',
  ),
  Product(
    id: 'p17',
    name: 'Flush Aldrop Lock',
    imageAsset: 'assets/port2.png',
    price: 19.99,
    categoryId: 'aldrops',
    companyId: null,
    materialId: 'ss',
  ),
  Product(
    id: 'p18',
    name: 'Drawer Basket Slide',
    imageAsset: 'assets/port3.png',
    price: 12.00,
    categoryId: 'baskets',
    companyId: 'basketry',
    materialId: 'metal',
  ),
  Product(
    id: 'p19',
    name: 'Curved Door Handle',
    imageAsset: 'assets/port.jpg',
    price: 16.40,
    categoryId: 'handles',
    companyId: 'devansh',
    materialId: 'aluminium',
  ),
  Product(
    id: 'p20',
    name: 'Spring Loaded Hinge',
    imageAsset: 'assets/port2.png',
    price: 8.25,
    categoryId: 'hinges',
    companyId: 'nova',
    materialId: 'metal',
  ),
  Product(
    id: 'p21',
    name: 'Steel Tower Bolt',
    imageAsset: 'assets/port3.png',
    price: 10.50,
    categoryId: 'locks',
    companyId: null,
    materialId: 'ss',
  ),
  Product(
    id: 'p22',
    name: 'Chimney Cap Cover',
    imageAsset: 'assets/port.jpg',
    price: 67.00,
    categoryId: 'chimneys',
    companyId: 'hearth_co',
    materialId: 'aluminium',
  ),
  Product(
    id: 'p23',
    name: 'Glass Cabinet Knob',
    imageAsset: 'assets/port2.png',
    price: 5.75,
    categoryId: 'handles',
    companyId: 'unknown',
    materialId: 'silver',
  ),
  Product(
    id: 'p24',
    name: 'Pivot Hinge for Doors',
    imageAsset: 'assets/port3.png',
    price: 13.80,
    categoryId: 'hinges',
    companyId: 'devansh',
    materialId: 'ss',
  ),

  Product(
    id: 'p25',
    name: 'Polished Chrome Handle',
    imageAsset: 'assets/port.jpg',
    price: 17.25,
    categoryId: 'handles',
    companyId: 'nova',
    materialId: 'silver',
  ),
  Product(
    id: 'p26',
    name: 'Self-Closing Hinge',
    imageAsset: 'assets/port2.png',
    price: 6.99,
    categoryId: 'hinges',
    companyId: 'devansh',
    materialId: 'metal',
  ),
  Product(
    id: 'p27',
    name: 'Decorative Aldrop',
    imageAsset: 'assets/port3.png',
    price: 28.50,
    categoryId: 'handles',
    companyId: 'nova',
    materialId: 'ss',
  ),
  Product(
    id: 'p28',
    name: 'Wall Mount Chimney Hood',
    imageAsset: 'assets/port.jpg',
    price: 120.00,
    categoryId: 'chimneys',
    companyId: 'hearth_co',
    materialId: 'ss',
  ),
  Product(
    id: 'p29',
    name: 'Under-Sink Wire Basket',
    imageAsset: 'assets/port2.png',
    price: 15.30,
    categoryId: 'baskets',
    companyId: 'basketry',
    materialId: 'aluminium',
  ),
  Product(
    id: 'p30',
    name: 'Digital Door Lock',
    imageAsset: 'assets/port3.png',
    price: 45.00,
    categoryId: 'handles',
    companyId: 'nova',
    materialId: 'metal',
  ),
  Product(
    id: 'p31',
    name: 'Antique Brass Knob',
    imageAsset: 'assets/port.jpg',
    price: 8.00,
    categoryId: 'handles',
    companyId: 'devansh',
    materialId: 'metal',
  ),
  Product(
    id: 'p32',
    name: 'Stainless Steel Hinge',
    imageAsset: 'assets/port2.png',
    price: 10.20,
    categoryId: 'hinges',
    companyId: 'nova',
    materialId: 'ss',
  ),
  Product(
    id: 'p33',
    name: 'Surface Aldrop Lock',
    imageAsset: 'assets/port3.png',
    price: 22.75,
    categoryId: 'aldrops',
    companyId: 'devansh',
    materialId: 'ss',
  ),
  Product(
    id: 'p34',
    name: 'Chimney Dampener',
    imageAsset: 'assets/port.jpg',
    price: 55.50,
    categoryId: 'chimneys',
    companyId: 'hearth_co',
    materialId: 'metal',
  ),
  Product(
    id: 'p35',
    name: 'Stackable Wire Basket',
    imageAsset: 'assets/port2.png',
    price: 19.90,
    categoryId: 'baskets',
    companyId: 'basketry',
    materialId: 'aluminium',
  ),
  Product(
    id: 'p36',
    name: 'Mortise Lock Set',
    imageAsset: 'assets/port3.png',
    price: 32.00,
    categoryId: 'handles',
    companyId: 'nova',
    materialId: 'ss',
  ),
  Product(
    id: 'p37',
    name: 'Bar Cabinet Pull',
    imageAsset: 'assets/port.jpg',
    price: 11.60,
    categoryId: 'handles',
    companyId: 'nova',
    materialId: 'aluminium',
  ),
  Product(
    id: 'p38',
    name: 'Soft‑Close Cabinet Hinge',
    imageAsset: 'assets/port2.png',
    price: 14.40,
    categoryId: 'hinges',
    companyId: 'devansh',
    materialId: 'metal',
  ),
  Product(
    id: 'p39',
    name: 'Chimney Flue Cover',
    imageAsset: 'assets/port3.png',
    price: 78.00,
    categoryId: 'handles',
    companyId: 'nova',
    materialId: 'ss',
  ),
  Product(
    id: 'p40',
    name: 'Retractable Basket Tray',
    imageAsset: 'assets/port.jpg',
    price: 26.80,
    categoryId: 'baskets',
    companyId: 'basketry',
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
}