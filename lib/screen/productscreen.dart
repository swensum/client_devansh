import 'package:devansh/data/catalog.dart';
import 'package:devansh/productwidgets/categories.dart';
import 'package:devansh/productwidgets/productsright.dart';
import 'package:devansh/productwidgets/productview.dart';
import 'package:flutter/material.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String _selectedCategoryId = kCategories.first.id;
  String? _selectedCompanyId; 
  ViewMode _viewMode = ViewMode.grid;
  SortOption _sortOption = SortOption.relevance;
  String? _selectedMaterialId; 

  void _selectCategory(String id) {
    if (id == _selectedCategoryId) return;
    setState(() {
      _selectedCategoryId = id;
      _selectedCompanyId = null; 
      _selectedMaterialId = null;
    });
  }

  void _selectCompany(String? id) {
    setState(() => _selectedCompanyId = id);
  }
void _selectMaterial(String? id) {
    setState(() => _selectedMaterialId = id);
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
      Catalog.filtered(
        categoryId: _selectedCategoryId,
        companyId: _selectedCompanyId,
        materialId: _selectedMaterialId,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      
      body: LayoutBuilder(
        builder: (context, constraints) {
          final r = ProductsPageResponsive.of(constraints.maxWidth);

          final sidebar = CategorySidebar(
            selectedCategoryId: _selectedCategoryId,
            selectedCompanyId: _selectedCompanyId,
            selectedMaterialId: _selectedMaterialId,
            onCategoryTap: _selectCategory,
            onCompanyTap: _selectCompany,
             onMaterialTap: _selectMaterial,  
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