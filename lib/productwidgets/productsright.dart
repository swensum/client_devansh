import 'package:devansh/data/catalog.dart';
import 'package:devansh/productwidgets/productdetail.dart';
import 'package:devansh/productwidgets/productview.dart';

import 'package:flutter/material.dart';


const _kAmber = Color.fromRGBO(245, 171, 30, 1);

class ProductsRightPanel extends StatelessWidget {
  final Category category;
  final Company? company;
  final List<Product> products;
  final ViewMode viewMode;
  final SortOption sortOption;
  final ValueChanged<ViewMode> onViewModeChanged;
  final ValueChanged<SortOption> onSortChanged;
  final ProductsPageResponsive r;

  const ProductsRightPanel({
    super.key,
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
        else if (viewMode == ViewMode.grid)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
               clipBehavior: Clip.none,
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: r.crossAxisCount,
                crossAxisSpacing: r.gridSpacing,
                mainAxisSpacing: r.gridSpacing,
                childAspectRatio: r.childAspectRatio,
              ),
              itemBuilder: (context, index) => _ProductCard(product: products[index]),
            ),
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

class _ProductsToolbar extends StatelessWidget {
  final ViewMode viewMode;
  final SortOption sortOption;
  final ValueChanged<ViewMode> onViewModeChanged;
  final ValueChanged<SortOption> onSortChanged;

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
                  color: _isHovered ? _kAmber.withValues(alpha: 0.6) : Colors.grey.shade200,
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