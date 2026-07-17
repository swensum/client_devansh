import 'dart:async';

import 'package:devansh/components/footer.dart';
import 'package:devansh/components/header.dart';
import 'package:devansh/data/catalog.dart';
import 'package:devansh/models/catalogmodels.dart';
import 'package:devansh/services/catalogservice.dart';
import 'package:flutter/material.dart' hide MaterialType;

const _kAmber = Color.fromRGBO(245, 171, 30, 1);
const _kGreen = Color(0xFF4CAF50);

const double _kImageHeight = 420;
const double _kImageHeightNarrow = 300;
const double _kHeaderHeight = 100;
const double _kBannerHeight = 100;

// Below this width, the image and details stack vertically instead of
// sitting side-by-side in a Row.
const double _kDetailStackBreakpoint = 800;

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool _headerRevealed = false;
  final CatalogService _catalogService = CatalogService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) setState(() => _headerRevealed = true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    // Live lookup data — companies, materials, categories, and all
    // products (needed to find related items in the same category).
    return StreamBuilder<List<Company>>(
      stream: _catalogService.watchCompanies(),
      builder: (context, companySnap) {
        final companies = companySnap.data ?? [];
        return StreamBuilder<List<MaterialType>>(
          stream: _catalogService.watchMaterials(),
          builder: (context, materialSnap) {
            final materials = materialSnap.data ?? [];
            return StreamBuilder<List<Category>>(
              stream: _catalogService.watchCategories(),
              builder: (context, categorySnap) {
                final categories = categorySnap.data ?? [];
                return StreamBuilder<List<Product>>(
                  stream: _catalogService.watchProducts(),
                  builder: (context, productSnap) {
                    final allProducts = productSnap.data ?? [];

                    final stillLoading =
                        categorySnap.connectionState == ConnectionState.waiting &&
                            categories.isEmpty;

                    if (stillLoading) {
                      return const Scaffold(
                        backgroundColor: Colors.black,
                        body: Center(
                          child: CircularProgressIndicator(color: _kAmber),
                        ),
                      );
                    }

                    final company = Catalog.companyFor(product, companies);
                    final material = Catalog.materialFor(product, materials);
                    final category = categories.firstWhere(
                      (c) => c.id == product.categoryId,
                      orElse: () => Category(id: product.categoryId, name: 'Uncategorized'),
                    );

                    final specs = <String, String?>{
                      'Thickness': product.thickness,
                      'Size': product.size,
                      'Quantity': product.quantity,
                      'Brand': company?.name,
                      'Finish': product.finish,
                      'Material': material?.name,
                      'Availability': product.availability,
                    }..removeWhere((key, value) => value == null || value.trim().isEmpty);

                    // Same category, excluding the product currently being viewed.
                    final relatedProducts = Catalog.byCategory(allProducts, product.categoryId)
                        .where((p) => p.id != product.id)
                        .toList();

                    return Scaffold(
                      backgroundColor: Colors.black,
                      body: Stack(
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: _kHeaderHeight),
                                const _DetailBanner(),
                                const SizedBox(height: 40),
                                Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 1200),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final isNarrow =
                                            constraints.maxWidth < _kDetailStackBreakpoint;

                                        final imageWidget = SizedBox(
                                          height: isNarrow ? _kImageHeightNarrow : _kImageHeight,
                                          width: double.infinity,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: product.imageUrl.isNotEmpty
                                                ? Image.network(
                                                    product.imageUrl,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (context, child, progress) {
                                                      if (progress == null) return child;
                                                      return Container(
                                                        color: Colors.grey.shade900,
                                                        child: const Center(
                                                          child: CircularProgressIndicator(
                                                            color: _kAmber,
                                                            strokeWidth: 2,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    errorBuilder: (context, error, stackTrace) =>
                                                        Container(
                                                      color: Colors.grey.shade800,
                                                      child: const Icon(
                                                          Icons.image_not_supported_outlined,
                                                          color: Colors.white38,
                                                          size: 32),
                                                    ),
                                                  )
                                                : Container(
                                                    color: Colors.grey.shade800,
                                                    child: const Icon(
                                                        Icons.image_not_supported_outlined,
                                                        color: Colors.white38,
                                                        size: 32),
                                                  ),
                                          ),
                                        );

                                        final detailsWidget = Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: isNarrow ? 22 : 28,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              category.name,
                                              style: const TextStyle(
                                                  color: _kAmber,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            if (product.description != null &&
                                                product.description!.trim().isNotEmpty) ...[
                                              const SizedBox(height: 15),
                                              Text(
                                                product.description!,
                                                style: TextStyle(
                                                    color: Colors.white.withValues(alpha: 0.75),
                                                    fontSize: 16,
                                                    height: 1.5),
                                              ),
                                            ],
                                            const SizedBox(height: 20),
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(18),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.08),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                    color: Colors.white.withValues(alpha: 0.15)),
                                              ),
                                              child: _DetailGrid(
                                                entries: [
                                                  _DetailEntry(
                                                    label: 'Price',
                                                    value:
                                                        '\$${product.price.toStringAsFixed(2)}',
                                                    valueColor: _kAmber,
                                                  ),
                                                  for (final entry in specs.entries)
                                                    _DetailEntry(
                                                      label: entry.key,
                                                      value: entry.value!,
                                                      isAvailability:
                                                          entry.key == 'Availability',
                                                    ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 30),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: () {},
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: _kAmber,
                                                  foregroundColor: Colors.black,
                                                  minimumSize: const Size(double.infinity, 46),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8)),
                                                ),
                                                child: const Text('Place Order',
                                                    style:
                                                        TextStyle(fontWeight: FontWeight.w600)),
                                              ),
                                            ),
                                          ],
                                        );

                                        return Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(16, isNarrow ? 24 : 50, 16, 16),
                                          child: isNarrow
                                              ? Column(
                                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                                  children: [
                                                    imageWidget,
                                                    const SizedBox(height: 24),
                                                    detailsWidget,
                                                  ],
                                                )
                                              : Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(child: imageWidget),
                                                    const SizedBox(width: 24),
                                                    Expanded(child: detailsWidget),
                                                  ],
                                                ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                if (relatedProducts.isNotEmpty) ...[
                                  const SizedBox(height: 86),
                                  _RelatedProductsSection(
                                    products: relatedProducts,
                                    companies: companies,
                                  ),
                                ],
                                const _Divider(),
                                const Footer(),
                              ],
                            ),
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

class _DetailBanner extends StatelessWidget {
  const _DetailBanner();

   @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: _kBannerHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/port3.png', 
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey.shade900,
            ),
          ),
          
        ],
      ),
    );
  }
}


/// Same divider style as used on HomePage/ProductsPage.
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

class _RelatedProductsSection extends StatefulWidget {
  final List<Product> products;
  final List<Company> companies;

  const _RelatedProductsSection({required this.products, required this.companies});

  @override
  State<_RelatedProductsSection> createState() => _RelatedProductsSectionState();
}

class _RelatedProductsSectionState extends State<_RelatedProductsSection> {
  static const int _kLoopMultiplier = 1000;

  static const double _kCardGap = 18;
  static const double _kMaxSingleCardWidth = 340;

  late PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentIndex = 0;
  int _virtualIndex = 0;

  // Responsive — how many related-product cards are visible at once.
  // Updated in build() based on available width.
  int _itemsPerPage = 4;

  int get _itemCount => widget.products.length;

  bool get _canSlide => _itemCount > _itemsPerPage;

  static int _computeItemsPerPage(double width) {
    if (width >= 900) return 4;
    if (width >= 650) return 3;
    if (width >= 420) return 2;
    return 1;
  }

  @override
  void initState() {
    super.initState();
    _setupController(_itemsPerPage);
  }

  void _setupController(int itemsPerPage) {
    _itemsPerPage = itemsPerPage;
    final start = _canSlide ? (_kLoopMultiplier ~/ 2) * _itemCount : 0;
    _virtualIndex = start;
    _currentIndex = 0;
    _pageController = PageController(viewportFraction: 1 / itemsPerPage, initialPage: start);
  }

  @override
  void didUpdateWidget(covariant _RelatedProductsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.products != widget.products) {
      _pageController.dispose();
      _setupController(_itemsPerPage);
      _startAutoSlide();
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    if (!_canSlide) return;
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_pageController.hasClients) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  void _goToRealIndex(int realIndex) {
    if (!_pageController.hasClients) return;
    final delta = realIndex - _currentIndex;
    _pageController.animateToPage(
      _virtualIndex + delta,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    _startAutoSlide();
  }

  // Swaps the PageController for a new viewportFraction after the current
  // frame, so a resize (e.g. browser window) updates how many cards are
  // shown without rebuilding mid-layout.
  void _scheduleItemsPerPageChange(int newItemsPerPage) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _pageController.dispose();
        _setupController(newItemsPerPage);
        _startAutoSlide();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageItemCount = _canSlide ? _itemCount * _kLoopMultiplier : _itemCount;

    return Container(
      width: double.infinity,
      color: const Color(0xFF141414),
      padding: const EdgeInsets.symmetric(vertical: 58),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1300),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Text(
                  'Related Products',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 52),
                SizedBox(
                  height: 290,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final desiredItemsPerPage = _computeItemsPerPage(constraints.maxWidth);
                      if (desiredItemsPerPage != _itemsPerPage) {
                        // Use the current controller for this frame; the
                        // rebuild with the new controller happens right after.
                        _scheduleItemsPerPageChange(desiredItemsPerPage);
                      }

                      final slotWidth = constraints.maxWidth / _itemsPerPage;
                      final rawCardWidth = slotWidth - _kCardGap;
                      final cardWidth = _itemsPerPage == 1
                          ? rawCardWidth.clamp(0, _kMaxSingleCardWidth).toDouble()
                          : rawCardWidth;
                      final alignment =
                          _itemsPerPage == 1 ? Alignment.center : Alignment.centerLeft;

                      return NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification is ScrollEndNotification && _pageController.hasClients) {
                            final page = _pageController.page?.round() ?? _virtualIndex;
                            _virtualIndex = page;
                            setState(() => _currentIndex = page % _itemCount);
                          }
                          return false;
                        },
                        child: PageView.builder(
                          key: ValueKey(_itemsPerPage),
                          controller: _pageController,
                          padEnds: false,
                          itemCount: pageItemCount,
                          itemBuilder: (context, index) {
                            final product = widget.products[index % _itemCount];
                            return Align(
                              alignment: alignment,
                              child: SizedBox(
                                width: cardWidth,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(_kCardGap / 2, 8, _kCardGap / 2, 8),
                                  child: _RelatedProductCard(
                                    product: product,
                                    companies: widget.companies,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                if (_canSlide) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _itemCount; i++)
                        GestureDetector(
                          onTap: () => _goToRealIndex(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentIndex == i ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentIndex == i ? _kAmber : Colors.white24,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RelatedProductCard extends StatefulWidget {
  final Product product;
  final List<Company> companies;

  const _RelatedProductCard({required this.product, required this.companies});

  @override
  State<_RelatedProductCard> createState() => _RelatedProductCardState();
}

class _RelatedProductCardState extends State<_RelatedProductCard> with SingleTickerProviderStateMixin {
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
    final company = Catalog.companyFor(product, widget.companies);

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
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(_cardRadius),
                 border: Border.all(
    color: _isHovered ? _kAmber.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.12),
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
                        color: Colors.grey.shade900,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            product.imageUrl.isNotEmpty
                                ? Image.network(
                                    product.imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          color: _kAmber,
                                          strokeWidth: 2,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: Colors.grey.shade800,
                                      child: const Center(
                                        child: Icon(Icons.image_not_supported_outlined,
                                            color: Colors.white38),
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: Colors.grey.shade800,
                                    child: const Center(
                                      child: Icon(Icons.image_not_supported_outlined,
                                          color: Colors.white38),
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
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12.5),
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
                              style: const TextStyle(color: _kAmber, fontWeight: FontWeight.bold, fontSize: 13.5),
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
    Color iconColor, {
    Color backgroundColor = Colors.black54,
    Color borderColor = Colors.white24,
  }) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Icon(icon, size: 14, color: iconColor),
    );
  }
}

class _DetailEntry {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isAvailability;

  const _DetailEntry({
    required this.label,
    required this.value,
    this.valueColor,
    this.isAvailability = false,
  });
}

class _DetailGrid extends StatelessWidget {
  final List<_DetailEntry> entries;

  const _DetailGrid({required this.entries});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < entries.length; i += 2) {
      final left = entries[i];
      final right = i + 1 < entries.length ? entries[i + 1] : null;
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _DetailLine(entry: left)),
              const SizedBox(width: 16),
              Expanded(child: right != null ? _DetailLine(entry: right) : const SizedBox.shrink()),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}

class _DetailLine extends StatelessWidget {
  final _DetailEntry entry;

  const _DetailLine({required this.entry});

  bool get _isInStock =>
      entry.value.toLowerCase().contains('stock') &&
      !entry.value.toLowerCase().contains('out');

  @override
  Widget build(BuildContext context) {
    final showGreen = entry.isAvailability && _isInStock;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${entry.label} : ',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              height: 1.4,
            ),
          ),
          TextSpan(
            text: entry.value,
            style: TextStyle(
              color: showGreen
                  ? _kGreen
                  : (entry.valueColor ?? const Color(0xFFF5F5F5)),
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
              height: 1.4,
            ),
          ),
          if (showGreen)
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: EdgeInsets.only(left: 5),
                child: Icon(
                  Icons.check_circle,
                  size: 15,
                  color: _kGreen,
                ),
              ),
            ),
        ],
      ),
    );
  }
}