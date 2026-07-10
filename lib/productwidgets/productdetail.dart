import 'dart:async';

import 'package:devansh/data/catalog.dart';
import 'package:devansh/productwidgets/productview.dart';
import 'package:flutter/material.dart';

const _kAmber = Color.fromRGBO(245, 171, 30, 1);
const _kGreen = Color(0xFF4CAF50);

const double _kImageHeight = 420;

// How many related product cards are visible on screen at once (per page).
const int _kRelatedItemsPerPage = 4;

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final company = Catalog.companyFor(product);
    final material = Catalog.materialFor(product);
    final category = kCategories.firstWhere((c) => c.id == product.categoryId);

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
    final relatedProducts =
        Catalog.byCategory(product.categoryId).where((p) => p.id != product.id).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: _kImageHeight,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              product.imageAsset,
                              fit: BoxFit.cover,
                              cacheWidth: 700,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade800,
                                child: const Icon(Icons.image_not_supported_outlined,
                                    color: Colors.white38, size: 32),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category.name,
                              style: TextStyle(color: _kAmber, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            if (product.description != null && product.description!.trim().isNotEmpty) ...[
                              const SizedBox(height: 15),
                              Text(
                                product.description!,
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.75), fontSize: 16, height: 1.5),
                              ),
                            ],
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                              ),
                              child: _DetailGrid(
                                entries: [
                                  _DetailEntry(
                                    label: 'Price',
                                    value: '\$${product.price.toStringAsFixed(2)}',
                                    valueColor: _kAmber,
                                  ),
                                  for (final entry in specs.entries)
                                    _DetailEntry(
                                      label: entry.key,
                                      value: entry.value!,
                                      isAvailability: entry.key == 'Availability',
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
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Place Order', style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ---- Related Products: full-width section with its own background ----
            if (relatedProducts.isNotEmpty) ...[
              const SizedBox(height: 56),
              _RelatedProductsSection(products: relatedProducts),
            ],
          ],
        ),
      ),
    );
  }
}

/// Full-width "Related Products" section shown at the bottom of the page,
/// with its own background, showing a fixed number of items per page and
/// auto-sliding one item at a time (1234 -> 2345 -> 3451 -> ...).
class _RelatedProductsSection extends StatefulWidget {
  final List<Product> products;

  const _RelatedProductsSection({required this.products});

  @override
  State<_RelatedProductsSection> createState() => _RelatedProductsSectionState();
}

class _RelatedProductsSectionState extends State<_RelatedProductsSection> {
  // A large multiple of the real list length lets us scroll "infinitely"
  // in one direction — we jump back to the middle range instead of ever
  // animating backwards to index 0.
  static const int _kLoopMultiplier = 1000;

  // Horizontal gap between cards. This is baked into the card width
  // calculation below (not applied as extra padding on top of the slot
  // width), so cards never get squeezed/cropped by double-counted spacing.
  static const double _kCardGap = 14;

  late final PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentIndex = 0; // Real index (0..products.length - 1) for dots.
  int _virtualIndex = 0; // Raw index into the looped PageView.

  int get _itemCount => widget.products.length;

  bool get _canSlide => _itemCount > _kRelatedItemsPerPage;

  @override
  void initState() {
    super.initState();
    final start = _canSlide ? (_kLoopMultiplier ~/ 2) * _itemCount : 0;
    _virtualIndex = start;
    _pageController = PageController(viewportFraction: 1 / _kRelatedItemsPerPage, initialPage: start);
    _startAutoSlide();
  }

  @override
  void didUpdateWidget(covariant _RelatedProductsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.products != widget.products) {
      _currentIndex = 0;
      final start = _canSlide ? (_kLoopMultiplier ~/ 2) * _itemCount : 0;
      _virtualIndex = start;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(start);
      }
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
    // Restart the auto-slide timer so a manual interaction doesn't get
    // immediately overridden by the next scheduled tick.
    _startAutoSlide();
  }

  @override
  Widget build(BuildContext context) {
    final pageItemCount = _canSlide ? _itemCount * _kLoopMultiplier : _itemCount;

    return Container(
      width: double.infinity,
      // Distinct background so the section reads as separate from the
      // product details above it.
      color: const Color(0xFF141414),
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const Text(
                  'Related Products',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 240,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Compute the exact pixel width for one card so that
                      // 4 cards + the gaps between them fill the row with
                      // zero leftover/rounding — this is what was causing
                      // the outer cards to render partially cropped.
                      final slotWidth = constraints.maxWidth / _kRelatedItemsPerPage;
                      final cardWidth = slotWidth - _kCardGap;

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
                          controller: _pageController,
                          padEnds: false,
                          itemCount: pageItemCount,
                          itemBuilder: (context, index) {
                            final product = widget.products[index % _itemCount];
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                width: cardWidth,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: _kCardGap),
                                  child: _RelatedProductCard(product: product),
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

/// Compact card used in the horizontal "Related Products" row.
class _RelatedProductCard extends StatelessWidget {
  final Product product;

  const _RelatedProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
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
                cacheWidth: 300,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade800,
                  child: const Center(
                    child: Icon(Icons.image_not_supported_outlined, color: Colors.white38),
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
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: _kAmber, fontWeight: FontWeight.bold, fontSize: 13.5),
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