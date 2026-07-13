import 'package:devansh/components/footer.dart';
import 'package:devansh/components/header.dart';
import 'package:devansh/data/catalog.dart';
import 'package:devansh/productwidgets/categories.dart';
import 'package:devansh/productwidgets/productsright.dart';
import 'package:devansh/productwidgets/productview.dart';
import 'package:flutter/material.dart';

const double _kHeaderHeight = 100;
const double _kBannerHeight = 100;
const _kAmber = Color.fromRGBO(245, 171, 30, 1);

class ProductsPage extends StatefulWidget {
  final String? initialCategoryId;
  final String? initialCompanyId;
  final String? initialTypeId;
  const ProductsPage({
    super.key,
    this.initialCategoryId,
    this.initialCompanyId,
    this.initialTypeId,
  });

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String? _selectedCategoryId;
  String? _selectedCompanyId;
  ViewMode _viewMode = ViewMode.grid;
  SortOption _sortOption = SortOption.relevance;
  String? _selectedMaterialId;
  String? _selectedTypeId;

  bool _headerRevealed = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    _selectedCompanyId = widget.initialCompanyId;
    _selectedTypeId = widget.initialTypeId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) setState(() => _headerRevealed = true);
      });
    });
  }

  void _selectCategory(String? id) {
    if (id == _selectedCategoryId) return;
    setState(() {
      _selectedCategoryId = id;
      _selectedCompanyId = null;
      _selectedMaterialId = null;
      _selectedTypeId = null;
    });
  }

  void _selectCompany(String? id) {
    setState(() => _selectedCompanyId = id);
  }

  void _selectMaterial(String? id) {
    setState(() => _selectedMaterialId = id);
  }

  void _selectType(String? id) {
    setState(() => _selectedTypeId = id);
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
    final category = _selectedCategoryId == null
        ? null
        : kCategories.firstWhere((c) => c.id == _selectedCategoryId);
    final company = _selectedCompanyId == null
        ? null
        : kCompanies.firstWhere((c) => c.id == _selectedCompanyId);
    final type = _selectedTypeId == null
        ? null
        : kProductTypes.firstWhere((t) => t.id == _selectedTypeId);
    final material = _selectedMaterialId == null
        ? null
        : kMaterials.firstWhere((m) => m.id == _selectedMaterialId);
    final products = _applySort(
      Catalog.filtered(
        categoryId: _selectedCategoryId,
        companyId: _selectedCompanyId,
        materialId: _selectedMaterialId,
        typeId: _selectedTypeId,
      ),
    );

    // Built once — reused both inline (wide screens) and inside the filter
    // drawer (narrow screens), so selecting a filter behaves identically.
    final sidebar = CategorySidebar(
      selectedCategoryId: _selectedCategoryId,
      selectedCompanyId: _selectedCompanyId,
      selectedMaterialId: _selectedMaterialId,
      selectedTypeId: _selectedTypeId,
      onCategoryTap: _selectCategory,
      onCompanyTap: _selectCompany,
      onMaterialTap: _selectMaterial,
      onTypeTap: _selectType,
    );

    final activeFilterCount = [
      _selectedCategoryId,
      _selectedCompanyId,
      _selectedTypeId,
      _selectedMaterialId,
    ].where((id) => id != null).length;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      endDrawer: _FilterDrawer(sidebar: sidebar),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final r = ProductsPageResponsive.of(constraints.maxWidth);

              final panel = ProductsRightPanel(
                category: category,
                company: company,
                type: type,
                material: material,
                products: products,
                viewMode: _viewMode,
                sortOption: _sortOption,
                onViewModeChanged: (mode) => setState(() => _viewMode = mode),
                onSortChanged: (option) => setState(() => _sortOption = option),
                r: r,
                // Only show the "Filters" trigger when the sidebar isn't
                // already visible inline.
                onFilterTap: r.sidebarOnLeft
                    ? null
                    : () => _scaffoldKey.currentState?.openEndDrawer(),
                activeFilterCount: activeFilterCount,
              );

              if (r.sidebarOnLeft) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: _kHeaderHeight), // reserve space
                      const _ProductsBanner(),
                      Padding(
                        padding: EdgeInsets.all(r.hPadding),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: r.sidebarWidth, child: sidebar),
                            SizedBox(width: r.sectionGap),
                            Expanded(child: panel),
                          ],
                        ),
                      ),
                      const _Divider(),
                      const Footer(),
                    ],
                  ),
                );
              }

              // Narrow screens: no stacked sidebar — just the banner and the
              // right panel, with a Filters button opening the drawer above.
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: _kHeaderHeight), // reserve space
                    const _ProductsBanner(),
                    Padding(
                      padding: EdgeInsets.all(r.hPadding),
                      child: panel,
                    ),
                    const _Divider(),
                    const Footer(),
                  ],
                ),
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              offset: _headerRevealed ? Offset.zero : const Offset(0, -1),
              child: const Header(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Slide-in drawer (from the right) housing the same [CategorySidebar] used
/// inline on wide screens — shown on narrow screens via the panel's
/// "Filters" button.
class _FilterDrawer extends StatelessWidget {
  final Widget sidebar;

  const _FilterDrawer({required this.sidebar});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1A1A1A),
      width: 300,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            Container(
              height: 2,
              width: 30,
              margin: const EdgeInsets.only(left: 20, bottom: 10),
              color: _kAmber,
            ),
            const Divider(height: 1, color: Color(0xFF444444)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: sidebar,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductsBanner extends StatelessWidget {
  const _ProductsBanner();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: _kBannerHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/image1.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: Colors.grey.shade900),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 2,
      color: const Color.fromRGBO(245, 171, 30, 1),
    );
  }
}