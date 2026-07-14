import 'package:devansh/data/catalog.dart';
import 'package:devansh/productwidgets/productdetail.dart';
import 'package:devansh/productwidgets/productview.dart';

import 'package:flutter/material.dart' hide MaterialType;


const _kAmber = Color.fromRGBO(245, 171, 30, 1);

const int _kItemsPerPage = 12;

class ProductsRightPanel extends StatefulWidget {
  final Category? category;
  final Company? company;
  final List<Product> products;
  final ProductType? type; // NEW
  final MaterialType? material;
  final ViewMode viewMode;
  final SortOption sortOption;
  final ValueChanged<ViewMode> onViewModeChanged;
  final ValueChanged<SortOption> onSortChanged;
  final ProductsPageResponsive r;
  final VoidCallback? onFilterTap;
  final int activeFilterCount;

  const ProductsRightPanel({
    super.key,
    required this.category,
    required this.company,
    required this.products,
    required this.type, // NEW
    required this.material,
    required this.viewMode,
    required this.sortOption,
    required this.onViewModeChanged,
    required this.onSortChanged,
    required this.r,
    this.onFilterTap,
    this.activeFilterCount = 0,
  });

  @override
  State<ProductsRightPanel> createState() => _ProductsRightPanelState();
}

class _ProductsRightPanelState extends State<ProductsRightPanel> {
  int _currentPage = 0;

  @override
  void didUpdateWidget(covariant ProductsRightPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category?.id != widget.category?.id ||
        oldWidget.company?.id != widget.company?.id ||
         oldWidget.type?.id != widget.type?.id || 
      oldWidget.material?.id != widget.material?.id || 
        oldWidget.products != widget.products ||
        oldWidget.viewMode != widget.viewMode) {
      _currentPage = 0;
    } else {
      final totalPages = _totalPages(widget.products.length);
      if (_currentPage > totalPages - 1) {
        _currentPage = totalPages > 0 ? totalPages - 1 : 0;
      }
    }
  }

  int _totalPages(int productCount) {
    if (productCount == 0) return 0;
    return (productCount / _kItemsPerPage).ceil();
  }

  void _goToPage(int page) {
    if (page == _currentPage) return;
    setState(() => _currentPage = page);
  }

  @override
  Widget build(BuildContext context) {
    final banner = widget.category != null ? Catalog.bannerFor(widget.category!.id) : null;
    final products = widget.products;
    final totalPages = _totalPages(products.length);

    final start = _currentPage * _kItemsPerPage;
    final end = (start + _kItemsPerPage).clamp(0, products.length);
    final pageProducts = products.isEmpty ? const <Product>[] : products.sublist(start, end);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Aldrops" or "Aldrops : Devansh Hardware"
        
       RichText(
  text: TextSpan(
    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    children: [
      TextSpan(text: widget.category?.name ?? 'All Products'),
      if (widget.company != null) ...[
        const TextSpan(text: '  :  ', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w400)),
        TextSpan(text: widget.company!.name, style: const TextStyle(color: _kAmber)),
      ],
      if (widget.type != null) ...[
        const TextSpan(text: '  /  ', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w400)),
        TextSpan(text: widget.type!.name, style: const TextStyle(color: _kAmber)),
      ],
      if (widget.material != null) ...[
        const TextSpan(text: '  /  ', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w400)),
        TextSpan(text: widget.material!.name, style: const TextStyle(color: _kAmber)),
      ],
    ],
  ),
),
        SizedBox(height: widget.r.sectionGap * 0.6),

        if (banner != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              banner,
              width: double.infinity,
              height: widget.r.bannerHeight,
              fit: BoxFit.cover,
              cacheWidth: 800,
            ),
          ),
          SizedBox(height: widget.r.sectionGap * 0.6),
        ],

        _ProductsToolbar(
          viewMode: widget.viewMode,
          sortOption: widget.sortOption,
          onViewModeChanged: widget.onViewModeChanged,
          onSortChanged: widget.onSortChanged,
          onFilterTap: widget.onFilterTap,
          activeFilterCount: widget.activeFilterCount,
        ),
        const SizedBox(height: 10),
        Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
        SizedBox(height: widget.r.sectionGap * 0.6),

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
        else if (widget.viewMode == ViewMode.grid)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              clipBehavior: Clip.none,
              itemCount: pageProducts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.r.crossAxisCount,
                crossAxisSpacing: widget.r.gridSpacing,
                mainAxisSpacing: widget.r.gridSpacing,
                childAspectRatio: widget.r.childAspectRatio,
              ),
              itemBuilder: (context, index) => _ProductCard(product: pageProducts[index]),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pageProducts.length,
            separatorBuilder: (_, _) => SizedBox(height: widget.r.gridSpacing),
            itemBuilder: (context, index) => _ProductListTile(product: pageProducts[index]),
          ),

        if (totalPages > 1) ...[
          SizedBox(height: widget.r.sectionGap * 0.8),
          _Pagination(
            currentPage: _currentPage,
            totalPages: totalPages,
            onPageSelected: _goToPage,
          ),
        ],
      ],
    );
  }
}
class _Pagination extends StatelessWidget {
  final int currentPage; // 0-based
  final int totalPages;
  final ValueChanged<int> onPageSelected;

  const _Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PageArrowButton(
              icon: Icons.chevron_left_rounded,
              enabled: currentPage > 0,
              onTap: () => onPageSelected(currentPage - 1),
            ),
            const SizedBox(width: 8),
            for (final page in _pagesToShow())
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: page == -1
                    ? const _PageEllipsis()
                    : _PageNumberButton(
                        page: page,
                        isSelected: page == currentPage,
                        onTap: () => onPageSelected(page),
                      ),
              ),
            const SizedBox(width: 8),
            _PageArrowButton(
              icon: Icons.chevron_right_rounded,
              enabled: currentPage < totalPages - 1,
              onTap: () => onPageSelected(currentPage + 1),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < totalPages; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: GestureDetector(
                  onTap: () => onPageSelected(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: i == currentPage ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == currentPage ? _kAmber : Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
  List<int> _pagesToShow() {
    if (totalPages <= 7) {
      return List.generate(totalPages, (i) => i);
    }

    final pages = <int>{0, totalPages - 1, currentPage};
    if (currentPage - 1 >= 0) pages.add(currentPage - 1);
    if (currentPage + 1 <= totalPages - 1) pages.add(currentPage + 1);

    final sorted = pages.toList()..sort();
    final result = <int>[];
    for (var i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i] - sorted[i - 1] > 1) {
        result.add(-1);
      }
      result.add(sorted[i]);
    }
    return result;
  }
}

class _PageArrowButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PageArrowButton({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: enabled ? 0.2 : 0.08)),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? Colors.white70 : Colors.white24,
        ),
      ),
    );
  }
}

class _PageNumberButton extends StatelessWidget {
  final int page; // 0-based
  final bool isSelected;
  final VoidCallback onTap;

  const _PageNumberButton({required this.page, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? _kAmber.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? _kAmber : Colors.white.withValues(alpha: 0.2)),
        ),
        child: Text(
          '${page + 1}',
          style: TextStyle(
            color: isSelected ? _kAmber : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _PageEllipsis extends StatelessWidget {
  const _PageEllipsis();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 32,
      child: Center(
        child: Text('…', style: TextStyle(color: Colors.white38, fontSize: 13)),
      ),
    );
  }
}

class _ProductsToolbar extends StatelessWidget {
  final ViewMode viewMode;
  final SortOption sortOption;
  final ValueChanged<ViewMode> onViewModeChanged;
  final ValueChanged<SortOption> onSortChanged;
  final VoidCallback? onFilterTap;
  final int activeFilterCount;

  const _ProductsToolbar({
    required this.viewMode,
    required this.sortOption,
    required this.onViewModeChanged,
    required this.onSortChanged,
    this.onFilterTap,
    this.activeFilterCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onFilterTap != null) ...[
          _FilterButton(count: activeFilterCount, onTap: onFilterTap!),
          const SizedBox(width: 10),
        ],
        _ViewToggleButton(
          icon: Icons.grid_view_rounded,
          isSelected: viewMode == ViewMode.grid,
          onTap: () => onViewModeChanged(ViewMode.grid),
        ),
        const SizedBox(width: 6),
        _ViewToggleButton(
          icon: Icons.view_list_rounded,
          isSelected: viewMode == ViewMode.list,
          onTap: () => onViewModeChanged(ViewMode.list),
        ),
        const Spacer(),
        Text('Sort by', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
        const SizedBox(width: 8),
        _SortDropdown(value: sortOption, onChanged: onSortChanged),
      ],
    );
  }
}

/// "Filters" trigger shown on narrow screens (where the sidebar is hidden)
/// that opens the filter drawer. Shows a small amber badge with the number
/// of active filters, if any.
class _FilterButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _FilterButton({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: count > 0 ? _kAmber.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: count > 0 ? _kAmber : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune_rounded, size: 16, color: count > 0 ? _kAmber : Colors.white70),
            const SizedBox(width: 6),
            Text(
              'Filters',
              style: TextStyle(
                color: count > 0 ? _kAmber : Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: _kAmber,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
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
  final SortOption value;
  final ValueChanged<SortOption> onChanged;

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
        child: DropdownButton<SortOption>(
          value: value,
          isDense: true,
          dropdownColor: const Color(0xFF1A1A1A),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 18),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          onChanged: (option) {
            if (option != null) onChanged(option);
          },
          items: SortOption.values
              .map((option) => DropdownMenuItem(value: option, child: Text(option.label)))
              .toList(),
        ),
      ),
    );
  }
}

/// Horizontal card used in list view: small thumbnail, details, price.
class _ProductListTile extends StatefulWidget {
  final Product product;

  const _ProductListTile({required this.product});

  @override
  State<_ProductListTile> createState() => _ProductListTileState();
}

class _ProductListTileState extends State<_ProductListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final company = Catalog.companyFor(product);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: _isHovered ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isHovered ? _kAmber.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.12),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.2 : 0.0),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  product.imageAsset,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  cacheWidth: 400,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 150,
                    height: 150,
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.image_not_supported_outlined, color: Colors.white38, size: 32),
                  ),
                ),
              ),
              const SizedBox(width: 26),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 21),
                    ),
                    if (company != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        company.name,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 15),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            Icons.star,
                            size: 18,
                            color: index < 4 ? _kAmber : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(124)',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: _kAmber, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 12),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isHovered ? 1.0 : 0.0,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _kAmber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _ProductCard extends StatefulWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  static const double _cardRadius = 12;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _setHovered(bool value) {
    if (_isHovered == value) return;
    setState(() => _isHovered = value);
    value ? _scaleController.forward() : _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final company = Catalog.companyFor(product);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
          );
        },
        child: RepaintBoundary(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(_cardRadius),
                border: Border.all(
                  color: _isHovered ? _kAmber.withValues(alpha: 0.6) :  Colors.white.withValues(alpha: 0.12),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: _isHovered ? 0.15 : 0.06),
                    blurRadius: _isHovered ? 20 : 8,
                    offset: Offset(0, _isHovered ? 8 : 4),
                    spreadRadius: _isHovered ? 2 : 0,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(_cardRadius),
                        topRight: Radius.circular(_cardRadius),
                      ),
                      child: Container(
                        width: double.infinity,
                        color: Colors.grey.shade50,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              product.imageAsset,
                              fit: BoxFit.cover,
                              cacheWidth: 400,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade800,
                                child: const Center(
                                  child: Icon(Icons.image_not_supported_outlined, color: Colors.white38),
                                ),
                              ),
                            ),
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: _isHovered ? 0.3 : 0.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: _isHovered ? 1.0 : 0.0,
                                child: _buildQuickActionButton(Icons.favorite_border, Colors.white),
                              ),
                            ),
                          ],
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
                        if (company != null)
                          Text(
                            company.name,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 11),
                          ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(color: _kAmber, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: _isHovered ? 1.0 : 0.0,
                              child: _buildQuickActionButton(
                                Icons.shopping_bag_outlined,
                                Colors.black,
                                backgroundColor: _kAmber,
                                borderColor: Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    IconData icon,
    Color color, {
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.black.withValues(alpha: 0.7),
        shape: BoxShape.circle,
        border: Border.all(color: borderColor ?? Colors.white.withValues(alpha: 0.2), width: 1),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}