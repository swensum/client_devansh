
import 'package:devansh/data/catalog.dart';
import 'package:devansh/models/catalogmodels.dart';
import 'package:devansh/services/catalogservice.dart';
import 'package:flutter/material.dart' hide MaterialType;

const _kAmber = Color.fromRGBO(245, 171, 30, 1);

/// ---------------------------------------------------------------------
/// Loader: combines the 5 live Firestore streams this sidebar needs
/// (categories, products, companies, materials, productTypes) so the
/// actual sidebar UI below can stay focused on layout, not data-fetching.
/// ---------------------------------------------------------------------
typedef _SidebarDataBuilder = Widget Function(
  BuildContext context,
  List<Category> categories,
  List<Product> products,
  List<Company> companies,
  List<MaterialType> materials,
  List<ProductType> types,
);

class _CategorySidebarData extends StatelessWidget {
  final _SidebarDataBuilder builder;

  const _CategorySidebarData({required this.builder});

  @override
  Widget build(BuildContext context) {
    final catalogService = CatalogService();

    return StreamBuilder<List<Category>>(
      stream: catalogService.watchCategories(),
      builder: (context, categorySnap) {
        final categories = categorySnap.data ?? [];
        return StreamBuilder<List<Product>>(
          stream: catalogService.watchProducts(),
          builder: (context, productSnap) {
            final products = productSnap.data ?? [];
            return StreamBuilder<List<Company>>(
              stream: catalogService.watchCompanies(),
              builder: (context, companySnap) {
                final companies = companySnap.data ?? [];
                return StreamBuilder<List<MaterialType>>(
                  stream: catalogService.watchMaterials(),
                  builder: (context, materialSnap) {
                    final materials = materialSnap.data ?? [];
                    return StreamBuilder<List<ProductType>>(
                      stream: catalogService.watchProductTypes(),
                      builder: (context, typeSnap) {
                        final types = typeSnap.data ?? [];

                        final stillLoading =
                            categorySnap.connectionState ==
                                    ConnectionState.waiting &&
                                categories.isEmpty;

                        if (stillLoading) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _kAmber,
                                ),
                              ),
                            ),
                          );
                        }

                        return builder(
                          context,
                          categories,
                          products,
                          companies,
                          materials,
                          types,
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class CategorySidebar extends StatelessWidget {
  final String? selectedCategoryId; // now nullable
  final String? selectedCompanyId;
  final String? selectedMaterialId;
  final String? selectedTypeId;
  final ValueChanged<String?> onCategoryTap;
  final ValueChanged<String?> onCompanyTap;
  final ValueChanged<String?> onMaterialTap;
  final ValueChanged<String?> onTypeTap;

  const CategorySidebar({
    super.key,
    required this.selectedCategoryId,
    required this.selectedCompanyId,
    required this.selectedMaterialId,
    required this.selectedTypeId,
    required this.onCategoryTap,
    required this.onCompanyTap,
    required this.onMaterialTap,
    required this.onTypeTap,
  });

  @override
  Widget build(BuildContext context) {
    return _CategorySidebarData(
      builder: (context, categories, products, companies, allMaterials, allTypes) {
        final materials = selectedCategoryId == null
            ? <MaterialType>[]
            : Catalog.materialsInCategory(products, allMaterials, selectedCategoryId!);
        final showMaterials = materials.isNotEmpty;

        final types = selectedCategoryId == null
            ? <ProductType>[]
            : Catalog.typesInCategory(products, allTypes, selectedCategoryId!);
        final showTypes = types.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Categories',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            _AllCategoriesEntry(
              isSelected: selectedCategoryId == null,
              onTap: () => onCategoryTap(null),
            ),
            for (final category in categories)
              _CategoryEntry(
                category: category,
                products: products,
                companies: companies,
                isSelected: category.id == selectedCategoryId,
                selectedCompanyId: selectedCompanyId,
                onCategoryTap: () => onCategoryTap(category.id),
                onCompanyTap: onCompanyTap,
              ),
            if (showTypes) ...[
              const SizedBox(height: 16),
              Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
              const SizedBox(height: 16),
              const Text(
                'Type',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _CompanyRow(
                label: 'All',
                isSelected: selectedTypeId == null,
                onTap: () => onTypeTap(null),
              ),
              for (final type in types)
                _CompanyRow(
                  label: type.name,
                  isSelected: selectedTypeId == type.id,
                  onTap: () => onTypeTap(type.id),
                ),
            ],
            if (showMaterials) ...[
              const SizedBox(height: 16),
              Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
              const SizedBox(height: 16),
              const Text(
                'Materials',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _CompanyRow(
                label: 'All',
                isSelected: selectedMaterialId == null,
                onTap: () => onMaterialTap(null),
              ),
              for (final material in materials)
                _CompanyRow(
                  label: material.name,
                  isSelected: selectedMaterialId == material.id,
                  onTap: () => onMaterialTap(material.id),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _AllCategoriesEntry extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _AllCategoriesEntry({required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? _kAmber.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(
                color: isSelected ? _kAmber : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            'All Products',
            style: TextStyle(
              color: isSelected ? _kAmber : Colors.white,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryEntry extends StatefulWidget {
  final Category category;
  final List<Product> products;
  final List<Company> companies;
  final bool isSelected;
  final String? selectedCompanyId;
  final VoidCallback onCategoryTap;
  final ValueChanged<String?> onCompanyTap;

  const _CategoryEntry({
    required this.category,
    required this.products,
    required this.companies,
    required this.isSelected,
    required this.selectedCompanyId,
    required this.onCategoryTap,
    required this.onCompanyTap,
  });

  @override
  State<_CategoryEntry> createState() => _CategoryEntryState();
}

class _CategoryEntryState extends State<_CategoryEntry> {
  // Max companies visible before the list becomes scrollable.
  static const int _maxVisibleCompanies = 3;
  // Approx height of a single _CompanyRow (12 vertical padding + ~16 content height).
  static const double _companyRowHeight = 28;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final isSelected = widget.isSelected;
    final selectedCompanyId = widget.selectedCompanyId;
    final onCategoryTap = widget.onCategoryTap;
    final onCompanyTap = widget.onCompanyTap;

    final companies = Catalog.companiesInCategory(
      widget.products,
      widget.companies,
      category.id,
    );
    final showCompanies = isSelected && companies.length > 1;

    // "All" row + one row per company.
    final totalRows = companies.length + 1;
    final needsScroll = totalRows > _maxVisibleCompanies;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onCategoryTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? _kAmber.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(
                    color: isSelected ? _kAmber : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      category.name,
                      style: TextStyle(
                        color: isSelected ? _kAmber : Colors.white,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                  if (companies.length > 1)
                    Icon(
                      showCompanies ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 18,
                      color: isSelected ? _kAmber : Colors.white54,
                    ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: showCompanies
                ? Padding(
                    padding: const EdgeInsets.only(left: 14, top: 4, bottom: 6),
                    child: needsScroll
                        ? SizedBox(
                            height: _companyRowHeight * _maxVisibleCompanies,
                            child: RawScrollbar(
                              controller: _scrollController,
                              thumbVisibility: true,
                              trackVisibility: true,
                              thickness: 5,
                              radius: const Radius.circular(4),
                              thumbColor: _kAmber.withValues(alpha: 0.6),
                              trackColor: Colors.white.withValues(alpha: 0.08),
                              trackBorderColor: Colors.transparent,
                              child: Padding(
                                // Extra right padding so text doesn't sit under the thumb.
                                padding: const EdgeInsets.only(right: 10),
                                child: ListView(
                                  controller: _scrollController,
                                  padding: EdgeInsets.zero,
                                  children: [
                                    _CompanyRow(
                                      label: 'All',
                                      isSelected: selectedCompanyId == null,
                                      onTap: () => onCompanyTap(null),
                                    ),
                                    for (final company in companies)
                                      _CompanyRow(
                                        label: company.name,
                                        isSelected: selectedCompanyId == company.id,
                                        onTap: () => onCompanyTap(company.id),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _CompanyRow(
                                label: 'All',
                                isSelected: selectedCompanyId == null,
                                onTap: () => onCompanyTap(null),
                              ),
                              for (final company in companies)
                                _CompanyRow(
                                  label: company.name,
                                  isSelected: selectedCompanyId == company.id,
                                  onTap: () => onCompanyTap(company.id),
                                ),
                            ],
                          ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _CompanyRow extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CompanyRow({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 14,
              color: isSelected ? _kAmber : Colors.white38,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? _kAmber : Colors.white.withValues(alpha: 0.75),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}