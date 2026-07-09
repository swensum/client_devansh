import 'package:devansh/data/catalog.dart';
import 'package:flutter/material.dart';

const _kAmber = Color.fromRGBO(245, 171, 30, 1);

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

enum _ViewMode { grid, list }

enum _SortOption { relevance, priceLowHigh, priceHighLow, nameAZ }

extension on _SortOption {
  String get label {
    switch (this) {
      case _SortOption.relevance:
        return 'Relevance';
      case _SortOption.priceLowHigh:
        return 'Price: Low to High';
      case _SortOption.priceHighLow:
        return 'Price: High to Low';
      case _SortOption.nameAZ:
        return 'Name: A–Z';
    }
  }
}

class _ProductsPageState extends State<ProductsPage> {
  // Defaults to the first category so the grid never starts empty.
  String _selectedCategoryId = kCategories.first.id;
  String? _selectedCompanyId; // null = "All companies"
  _ViewMode _viewMode = _ViewMode.grid;
  _SortOption _sortOption = _SortOption.relevance;

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
      case _SortOption.relevance:
        break; // keep catalog order
      case _SortOption.priceLowHigh:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case _SortOption.priceHighLow:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case _SortOption.nameAZ:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final category = kCategories.firstWhere((c) => c.id == _selectedCategoryId);
    final company = _selectedCompanyId == null
        ? null
        : kCompanies.firstWhere((c) => c.id == _selectedCompanyId);
    final products = _applySort(
      Catalog.byCategoryAndCompany(_selectedCategoryId, _selectedCompanyId),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      // No AppBar here — this page is meant to sit under your site's own
      // navbar rather than have a second one stacked on top of it. If you
      // want a page-level bar too, wrap wherever you route to
      // ProductsPage in its own Scaffold(appBar: ...).
      body: LayoutBuilder(
        builder: (context, constraints) {
          final r = _ProductsPageResponsive.of(constraints.maxWidth);

          final sidebar = _CategorySidebar(
            selectedCategoryId: _selectedCategoryId,
            selectedCompanyId: _selectedCompanyId,
            onCategoryTap: _selectCategory,
            onCompanyTap: _selectCompany,
          );

          final grid = _ProductsRightPanel(
            category: category,
            company: company,
            products: products,
            viewMode: _viewMode,
            sortOption: _sortOption,
            onViewModeChanged: (mode) => setState(() => _viewMode = mode),
            onSortChanged: (option) => setState(() => _sortOption = option),
            r: r,
          );

          // Wide screens: sidebar fixed on the left, grid takes the rest.
          // Narrow screens: sidebar stacks on top of the grid instead —
          // a fixed-width side column would leave barely any room for
          // the grid on a phone.
          if (r.sidebarOnLeft) {
            return Padding(
              padding: EdgeInsets.all(r.hPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: r.sidebarWidth,
                    child: SingleChildScrollView(child: sidebar),
                  ),
                  SizedBox(width: r.sectionGap),
                  Expanded(child: SingleChildScrollView(child: grid)),
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
                grid,
              ],
            ),
          );
        },
      ),
    );
  }
}

/// "Categories" header, then each category as a row. Tapping a category
/// selects it (filters the grid) and, if it has more than one company
/// selling in it, expands a nested company list directly beneath that
/// one row — other categories' company lists stay collapsed.
class _CategorySidebar extends StatelessWidget {
  final String selectedCategoryId;
  final String? selectedCompanyId;
  final ValueChanged<String> onCategoryTap;
  final ValueChanged<String?> onCompanyTap;

  const _CategorySidebar({
    required this.selectedCategoryId,
    required this.selectedCompanyId,
    required this.onCategoryTap,
    required this.onCompanyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Categories',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        for (final category in kCategories)
          _CategoryEntry(
            category: category,
            isSelected: category.id == selectedCategoryId,
            selectedCompanyId: selectedCompanyId,
            onCategoryTap: () => onCategoryTap(category.id),
            onCompanyTap: onCompanyTap,
          ),
      ],
    );
  }
}

class _CategoryEntry extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final String? selectedCompanyId;
  final VoidCallback onCategoryTap;
  final ValueChanged<String?> onCompanyTap;

  const _CategoryEntry({
    required this.category,
    required this.isSelected,
    required this.selectedCompanyId,
    required this.onCategoryTap,
    required this.onCompanyTap,
  });

  @override
  Widget build(BuildContext context) {
    // Computed on the fly from the product list — a company never needs
    // to declare upfront which categories it sells in.
    final companies = Catalog.companiesInCategory(category.id);
    final showCompanies = isSelected && companies.length > 1;

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
                    child: Column(
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

/// Everything to the right of the sidebar: the "Category : Company"
/// breadcrumb, a short banner image for the current category, a toolbar
/// (grid/list toggle on the left, sort dropdown on the right) with a
/// divider under it, and finally the products themselves.
class _ProductsRightPanel extends StatelessWidget {
  final Category category;
  final Company? company;
  final List<Product> products;
  final _ViewMode viewMode;
  final _SortOption sortOption;
  final ValueChanged<_ViewMode> onViewModeChanged;
  final ValueChanged<_SortOption> onSortChanged;
  final _ProductsPageResponsive r;

  const _ProductsRightPanel({
    required this.category,
    required this.company,
    required this.products,
    required this.viewMode,
    required this.sortOption,
    required this.onViewModeChanged,
    required this.onSortChanged,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    final banner = Catalog.bannerFor(category.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Aldrops" or "Aldrops : Devansh Hardware"
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            children: [
              TextSpan(text: category.name),
              if (company != null) ...[
                const TextSpan(text: '  :  ', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w400)),
                TextSpan(text: company!.name, style: const TextStyle(color: _kAmber)),
              ],
            ],
          ),
        ),
        SizedBox(height: r.sectionGap * 0.6),

        if (banner != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              banner,
              width: double.infinity,
              // Deliberately short — this is a strip that identifies the
              // section, not a hero image, so it shouldn't compete with
              // the product grid below it for vertical space.
              height: r.bannerHeight,
              fit: BoxFit.cover,
              cacheWidth: 800,
            ),
          ),
          SizedBox(height: r.sectionGap * 0.6),
        ],

        _ProductsToolbar(
          viewMode: viewMode,
          sortOption: sortOption,
          onViewModeChanged: onViewModeChanged,
          onSortChanged: onSortChanged,
        ),
        const SizedBox(height: 10),
        Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
        SizedBox(height: r.sectionGap * 0.6),

        if (products.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Center(
              child: Text(
                'No products in this category yet.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              ),
            ),
          )
        else if (viewMode == _ViewMode.grid)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: r.crossAxisCount,
              crossAxisSpacing: r.gridSpacing,
              mainAxisSpacing: r.gridSpacing,
              childAspectRatio: r.childAspectRatio,
            ),
            itemBuilder: (context, index) => _ProductCard(product: products[index]),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            separatorBuilder: (_, __) => SizedBox(height: r.gridSpacing),
            itemBuilder: (context, index) => _ProductListTile(product: products[index]),
          ),
      ],
    );
  }
}

/// Grid/list toggle on the left, "Sort by" dropdown on the right.
class _ProductsToolbar extends StatelessWidget {
  final _ViewMode viewMode;
  final _SortOption sortOption;
  final ValueChanged<_ViewMode> onViewModeChanged;
  final ValueChanged<_SortOption> onSortChanged;

  const _ProductsToolbar({
    required this.viewMode,
    required this.sortOption,
    required this.onViewModeChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ViewToggleButton(
          icon: Icons.grid_view_rounded,
          isSelected: viewMode == _ViewMode.grid,
          onTap: () => onViewModeChanged(_ViewMode.grid),
        ),
        const SizedBox(width: 6),
        _ViewToggleButton(
          icon: Icons.view_list_rounded,
          isSelected: viewMode == _ViewMode.list,
          onTap: () => onViewModeChanged(_ViewMode.list),
        ),
        const Spacer(),
        Text('Sort by', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
        const SizedBox(width: 8),
        _SortDropdown(value: sortOption, onChanged: onSortChanged),
      ],
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewToggleButton({required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? _kAmber.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? _kAmber : Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, size: 18, color: isSelected ? _kAmber : Colors.white70),
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  final _SortOption value;
  final ValueChanged<_SortOption> onChanged;

  const _SortDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_SortOption>(
          value: value,
          isDense: true,
          dropdownColor: const Color(0xFF1A1A1A),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 18),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          onChanged: (option) {
            if (option != null) onChanged(option);
          },
          items: _SortOption.values
              .map((option) => DropdownMenuItem(value: option, child: Text(option.label)))
              .toList(),
        ),
      ),
    );
  }
}

/// Horizontal card used in list view: small thumbnail, details, price.
class _ProductListTile extends StatelessWidget {
  final Product product;

  const _ProductListTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final company = Catalog.companyFor(product);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                product.imageAsset,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                cacheWidth: 200,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  if (company != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      company.name,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 11.5),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(color: _kAmber, fontWeight: FontWeight.bold, fontSize: 14.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final company = Catalog.companyFor(product);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1.2),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.asset(
                product.imageAsset,
                width: double.infinity,
                fit: BoxFit.cover,
                cacheWidth: 400,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade800,
                  child: const Center(
                    child: Icon(Icons.image_not_supported_outlined, color: Colors.white38),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5),
                  ),
                  const SizedBox(height: 4),
                  // Only rendered when the product actually has a company —
                  // this is the one line of UI that depends on companyId
                  // being nullable, and it needs no special-casing beyond
                  // this null check.
                  if (company != null)
                    Text(
                      company.name,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 11),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: _kAmber, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final company = Catalog.companyFor(product);
    final category = kCategories.firstWhere((c) => c.id == product.categoryId);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(product.imageAsset, width: double.infinity, height: 260, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            Text(
              product.name,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(category.name, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
            const SizedBox(height: 16),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(color: _kAmber, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // This whole block simply doesn't render when there's no
            // company — no placeholder, no "Independent product" label,
            // it just isn't there.
            if (company != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: _kAmber,
                      child: Text(
                        company.name.isNotEmpty ? company.name[0] : '?',
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Sold by', style: TextStyle(color: Colors.white54, fontSize: 11)),
                          Text(
                            company.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _kAmber,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Add to Cart', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Breakpoint-driven sizing for this page, same pattern used across the
/// homepage sections. `sidebarOnLeft` is the key layout switch: below
/// 700px a fixed-width side column would eat too much of the screen, so
/// the sidebar stacks above the grid instead of sitting beside it.
class _ProductsPageResponsive {
  final bool sidebarOnLeft;
  final double sidebarWidth;
  final int crossAxisCount;
  final double childAspectRatio;
  final double gridSpacing;
  final double hPadding;
  final double vPadding;
  final double sectionGap;
  // Deliberately capped well below what a full hero banner would use —
  // this is an identifying strip above the toolbar, not the page's main
  // visual, so it needs to stay short at every width.
  final double bannerHeight;

  const _ProductsPageResponsive({
    required this.sidebarOnLeft,
    required this.sidebarWidth,
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.gridSpacing,
    required this.hPadding,
    required this.vPadding,
    required this.sectionGap,
    required this.bannerHeight,
  });

  factory _ProductsPageResponsive.of(double w) {
    if (w > 1100) {
      return const _ProductsPageResponsive(
        sidebarOnLeft: true,
        sidebarWidth: 240,
        crossAxisCount: 4,
        childAspectRatio: 0.72,
        gridSpacing: 20,
        hPadding: 30,
        vPadding: 24,
        sectionGap: 28,
        bannerHeight: 130,
      );
    }
    if (w > 900) {
      return const _ProductsPageResponsive(
        sidebarOnLeft: true,
        sidebarWidth: 220,
        crossAxisCount: 3,
        childAspectRatio: 0.72,
        gridSpacing: 18,
        hPadding: 24,
        vPadding: 22,
        sectionGap: 24,
        bannerHeight: 120,
      );
    }
    if (w > 700) {
      return const _ProductsPageResponsive(
        sidebarOnLeft: true,
        sidebarWidth: 200,
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        gridSpacing: 16,
        hPadding: 20,
        vPadding: 20,
        sectionGap: 20,
        bannerHeight: 110,
      );
    }
    if (w > 500) {
      return const _ProductsPageResponsive(
        sidebarOnLeft: false,
        sidebarWidth: 0,
        crossAxisCount: 3,
        childAspectRatio: 0.68,
        gridSpacing: 14,
        hPadding: 18,
        vPadding: 18,
        sectionGap: 18,
        bannerHeight: 100,
      );
    }
    if (w > 380) {
      return const _ProductsPageResponsive(
        sidebarOnLeft: false,
        sidebarWidth: 0,
        crossAxisCount: 2,
        childAspectRatio: 0.66,
        gridSpacing: 12,
        hPadding: 14,
        vPadding: 14,
        sectionGap: 16,
        bannerHeight: 90,
      );
    }
    return const _ProductsPageResponsive(
      sidebarOnLeft: false,
      sidebarWidth: 0,
      crossAxisCount: 1,
      childAspectRatio: 1.1,
      gridSpacing: 12,
      hPadding: 12,
      vPadding: 12,
      sectionGap: 14,
      bannerHeight: 80,
    );
  }
}