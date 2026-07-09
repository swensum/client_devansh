import 'package:devansh/data/catalog.dart';
import 'package:devansh/productwidgets/categories.dart';
import 'package:devansh/productwidgets/productsright.dart';
import 'package:devansh/productwidgets/productview.dart';
import 'package:flutter/material.dart';


/// This page only holds state and selection/sort logic. All the actual
/// UI design lives in the two widgets it composes:
///   - CategorySidebar        (category list + nested company filter)
///   - ProductsRightPanel     (breadcrumb, banner, toolbar, product grid/list)
/// See products_view_types.dart for the shared enums/sizing config, and
/// product_detail_page.dart for the page a product card navigates to.
class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  // Defaults to the first category so the grid never starts empty.
  String _selectedCategoryId = kCategories.first.id;
  String? _selectedCompanyId; // null = "All companies"
  ViewMode _viewMode = ViewMode.grid;
  SortOption _sortOption = SortOption.relevance;

  void _selectCategory(String id) {
    if (id == _selectedCategoryId) return;
    setState(() {
      _selectedCategoryId = id;
      _selectedCompanyId = null; // company filter doesn't carry across categories
    });
  }

  void _selectCompany(String? id) {
    setState(() => _selectedCompanyId = id);
  }

  List<Product> _applySort(List<Product> input) {
    final sorted = [...input];
    switch (_sortOption) {
      case SortOption.relevance:
        break; // keep catalog order
      case SortOption.priceLowHigh:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighLow:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.nameAZ:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final category = kCategories.firstWhere((c) => c.id == _selectedCategoryId);
    final company =
        _selectedCompanyId == null ? null : kCompanies.firstWhere((c) => c.id == _selectedCompanyId);
    final products = _applySort(
      Catalog.byCategoryAndCompany(_selectedCategoryId, _selectedCompanyId),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      // No AppBar here — this page is meant to sit under your site's own
      // navbar rather than have a second one stacked on top of it.
      body: LayoutBuilder(
        builder: (context, constraints) {
          final r = ProductsPageResponsive.of(constraints.maxWidth);

          final sidebar = CategorySidebar(
            selectedCategoryId: _selectedCategoryId,
            selectedCompanyId: _selectedCompanyId,
            onCategoryTap: _selectCategory,
            onCompanyTap: _selectCompany,
          );

          final panel = ProductsRightPanel(
            category: category,
            company: company,
            products: products,
            viewMode: _viewMode,
            sortOption: _sortOption,
            onViewModeChanged: (mode) => setState(() => _viewMode = mode),
            onSortChanged: (option) => setState(() => _sortOption = option),
            r: r,
          );
          if (r.sidebarOnLeft) {
            return Padding(
              padding: EdgeInsets.all(r.hPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: r.sidebarWidth, child: SingleChildScrollView(child: sidebar)),
                  SizedBox(width: r.sectionGap),
                  Expanded(child: SingleChildScrollView(child: panel)),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(r.hPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sidebar,
                SizedBox(height: r.sectionGap),
                panel,
              ],
            ),
          );
        },
      ),
    );
  }
}