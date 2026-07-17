import 'package:devansh/models/catalogmodels.dart';



class Catalog {
  /// Products in a given category.
  static List<Product> byCategory(List<Product> products, String categoryId) =>
      products.where((p) => p.categoryId == categoryId).toList();

  static List<Product> byCategoryAndCompany(
    List<Product> products,
    String categoryId,
    String? companyId,
  ) {
    final inCategory = byCategory(products, categoryId);
    if (companyId == null) return inCategory;
    return inCategory.where((p) => p.companyId == companyId).toList();
  }

  static List<Product> filtered(
    List<Product> products, {
    String? categoryId,
    String? companyId,
    String? materialId,
    String? typeId,
  }) {
    return products.where((p) {
      if (categoryId != null && p.categoryId != categoryId) return false;
      if (companyId != null && p.companyId != companyId) return false;
      if (materialId != null && p.materialId != materialId) return false;
      if (typeId != null && p.typeId != typeId) return false;
      return true;
    }).toList();
  }

  static List<ProductType> typesInCategory(
    List<Product> products,
    List<ProductType> allTypes,
    String categoryId,
  ) {
    final typeIds = byCategory(products, categoryId)
        .map((p) => p.typeId)
        .whereType<String>() // drops nulls
        .toSet();
    return allTypes.where((t) => typeIds.contains(t.id)).toList();
  }

  /// The company for a product, or null if it doesn't have one / isn't found.
  static Company? companyFor(Product product, List<Company> allCompanies) {
    if (product.companyId == null) return null;
    for (final c in allCompanies) {
      if (c.id == product.companyId) return c;
    }
    return null;
  }

  /// The material for a product.
  static MaterialType? materialFor(
    Product product,
    List<MaterialType> allMaterials,
  ) {
    for (final m in allMaterials) {
      if (m.id == product.materialId) return m;
    }
    return null;
  }

  static List<Product> topProducts(List<Product> products) =>
      products.where((p) => p.isTopProduct).toList();

  /// Banner image for a category: its own bannerAsset if set, otherwise
  /// the first product image in that category.
  static String? bannerFor(
    List<Product> products,
    List<Category> allCategories,
    String categoryId,
  ) {
    final category = allCategories.firstWhere((c) => c.id == categoryId);
    if (category.imageUrl != null) return category.imageUrl;
    final inCategory = byCategory(products, categoryId);
    return inCategory.isNotEmpty ? inCategory.first.imageUrl : null;
  }

  static List<Company> companiesInCategory(
    List<Product> products,
    List<Company> allCompanies,
    String categoryId,
  ) {
    final companyIds = byCategory(products, categoryId)
        .map((p) => p.companyId)
        .whereType<String>() // drops nulls
        .toSet();
    return allCompanies.where((c) => companyIds.contains(c.id)).toList();
  }

  static List<MaterialType> materialsInCategory(
    List<Product> products,
    List<MaterialType> allMaterials,
    String categoryId,
  ) {
    final materialIds =
        byCategory(products, categoryId).map((p) => p.materialId).toSet();
    return allMaterials.where((m) => materialIds.contains(m.id)).toList();
  }
}