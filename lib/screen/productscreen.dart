import 'package:devansh/data/catalog.dart';
import 'package:flutter/material.dart';


const _kAmber = Color.fromRGBO(245, 171, 30, 1);

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  // Defaults to the first category so the grid never starts empty.
  String _selectedCategoryId = kCategories.first.id;
  String? _selectedCompanyId; // null = "All companies"

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

  @override
  Widget build(BuildContext context) {
    final companiesHere = Catalog.companiesInCategory(_selectedCategoryId);
    final products = Catalog.byCategoryAndCompany(_selectedCategoryId, _selectedCompanyId);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Products', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final r = _ProductsPageResponsive.of(constraints.maxWidth);

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: r.hPadding, vertical: r.vPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CategoryTabs(
                  selectedId: _selectedCategoryId,
                  onSelected: _selectCategory,
                ),
                // Only shown when the current category actually has more
                // than one company selling in it — no point filtering
                // when there's nothing to filter between.
                if (companiesHere.length > 1) ...[
                  SizedBox(height: r.sectionGap),
                  _CompanyChips(
                    companies: companiesHere,
                    selectedId: _selectedCompanyId,
                    onSelected: _selectCompany,
                  ),
                ],
                SizedBox(height: r.sectionGap),
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
                else
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
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  final String selectedId;
  final ValueChanged<String> onSelected;

  const _CategoryTabs({required this.selectedId, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: kCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = kCategories[index];
          final isSelected = category.id == selectedId;
          return GestureDetector(
            onTap: () => onSelected(category.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? _kAmber : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                category.name,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CompanyChips extends StatelessWidget {
  final List<Company> companies;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  const _CompanyChips({
    required this.companies,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chip(label: 'All', isSelected: selectedId == null, onTap: () => onSelected(null)),
          const SizedBox(width: 8),
          for (final company in companies) ...[
            _chip(
              label: company.name,
              isSelected: selectedId == company.id,
              onTap: () => onSelected(company.id),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _chip({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isSelected ? _kAmber : Colors.white.withValues(alpha: 0.25)),
          color: isSelected ? _kAmber.withValues(alpha: 0.15) : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? _kAmber : Colors.white.withValues(alpha: 0.8),
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
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
/// homepage sections.
class _ProductsPageResponsive {
  final int crossAxisCount;
  final double childAspectRatio;
  final double gridSpacing;
  final double hPadding;
  final double vPadding;
  final double sectionGap;

  const _ProductsPageResponsive({
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.gridSpacing,
    required this.hPadding,
    required this.vPadding,
    required this.sectionGap,
  });

  factory _ProductsPageResponsive.of(double w) {
    if (w > 900) {
      return const _ProductsPageResponsive(
        crossAxisCount: 4,
        childAspectRatio: 0.72,
        gridSpacing: 20,
        hPadding: 30,
        vPadding: 24,
        sectionGap: 20,
      );
    }
    if (w > 600) {
      return const _ProductsPageResponsive(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        gridSpacing: 16,
        hPadding: 22,
        vPadding: 20,
        sectionGap: 16,
      );
    }
    if (w > 400) {
      return const _ProductsPageResponsive(
        crossAxisCount: 2,
        childAspectRatio: 0.66,
        gridSpacing: 12,
        hPadding: 16,
        vPadding: 16,
        sectionGap: 14,
      );
    }
    return const _ProductsPageResponsive(
      crossAxisCount: 1,
      childAspectRatio: 1.1,
      gridSpacing: 12,
      hPadding: 14,
      vPadding: 14,
      sectionGap: 12,
    );
  }
}