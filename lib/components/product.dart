import 'package:flutter/material.dart';

class TopProductsSection extends StatefulWidget {
  const TopProductsSection({super.key});

  @override
  State<TopProductsSection> createState() => _TopProductsSectionState();
}

class _TopProductsSectionState extends State<TopProductsSection> {
  static const List<_Product> _products = [
    _Product(name: "Matte Black Cabinet Handle", price: "\$12.99", image: "assets/port.jpg"),
    _Product(name: "Brushed Steel Door Handle", price: "\$18.50", image: "assets/port2.png"),
    _Product(name: "Premium Soft-Close Hinge", price: "\$9.75", image: "assets/port3.png"),
    _Product(name: "Modern Aldrop Lock", price: "\$24.00", image: "assets/port.jpg"),
    _Product(name: "Chrome Finish Handle", price: "\$14.25", image: "assets/port2.png"),
    _Product(name: "Concealed Door Hinge", price: "\$11.00", image: "assets/port3.png"),
    _Product(name: "Heavy Duty Tower Bolt", price: "\$8.50", image: "assets/port.jpg"),
    _Product(name: "Antique Brass Handle", price: "\$21.99", image: "assets/port2.png"),
    _Product(name: "Luxury Glass Door Handle", price: "\$26.99", image: "assets/port3.png"),
    _Product(name: "Smart Digital Lock", price: "\$65.00", image: "assets/port.jpg"),
    _Product(name: "Stainless Pull Handle", price: "\$19.99", image: "assets/port2.png"),
    _Product(name: "Premium Mortise Lock", price: "\$32.50", image: "assets/port3.png"),
    _Product(name: "Designer Cabinet Knob", price: "\$10.99", image: "assets/port.jpg"),
  ];

  static const int _perPage = 8;
  static const double _gridPadding = 16.0;

  late final PageController _pageController;
  int _currentPage = 0;

  List<List<_Product>> get _pages {
    final pages = <List<_Product>>[];
    for (var i = 0; i < _products.length; i += _perPage) {
      final end = (i + _perPage > _products.length) ? _products.length : i + _perPage;
      pages.add(_products.sublist(i, end));
    }
    return pages;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPrevious() {
    if (_currentPage == 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _goToNext() {
    if (_currentPage == _pages.length - 1) return;
    _pageController.nextPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.black.withValues(alpha: 0.9), Colors.black.withValues(alpha: 0.7)],
        ),
      ),
      child: Center(
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      _buildSectionHeader(),
                      const SizedBox(height: 40),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 900
                              ? 4
                              : constraints.maxWidth > 600
                                  ? 3
                                  : constraints.maxWidth > 400
                                      ? 2
                                      : 1;

                          final rows = (_perPage / crossAxisCount).ceil();
                          final estimatedHeight =
                              rows * 380.0 + (rows - 1) * 20.0 + (_gridPadding * 2);

                          return SizedBox(
                            height: estimatedHeight,
                            child: PageView.builder(
                              controller: _pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: pages.length,
                              // Default clip (hardEdge) here is important —
                              // it cuts each page off cleanly at its own
                              // boundary during the slide. The 16px inner
                              // padding below already gives hover-scaled
                              // cards enough room, so the outer page itself
                              // doesn't need to skip clipping. Without this,
                              // the outgoing page's edge briefly lingers
                              // visible past the boundary, causing a flash.
                              // Pre-builds the neighboring page instead of
                              // building it only once the slide starts —
                              // this removes the stutter on the first
                              // frame of the animation.
                              allowImplicitScrolling: true,
                              onPageChanged: (index) =>
                                  setState(() => _currentPage = index),
                              itemBuilder: (context, pageIndex) {
                                final pageProducts = pages[pageIndex];
                                // RepaintBoundary lets Flutter cache each
                                // page as its own raster layer, so sliding
                                // it just moves a cached image instead of
                                // redrawing every card's shadow/blur each
                                // frame — this is the main fix for the lag.
                                return RepaintBoundary(
                                  child: Padding(
                                    padding: const EdgeInsets.all(_gridPadding),
                                    child: GridView.builder(
                                      clipBehavior: Clip.none,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: pageProducts.length,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        crossAxisSpacing: 20,
                                        mainAxisSpacing: 20,
                                        childAspectRatio: 0.75,
                                      ),
                                      itemBuilder: (context, index) {
                                        return _PremiumProductCard(
                                          product: pageProducts[index],
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(pages.length, (i) {
                          final isActive = i == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color.fromRGBO(245, 171, 30, 1)
                                  : Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      const _ViewAllProductsButton(),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _NavArrow(
                    icon: Icons.chevron_left,
                    enabled: _currentPage != 0,
                    onTap: _goToPrevious,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _NavArrow(
                    icon: Icons.chevron_right,
                    enabled: _currentPage != pages.length - 1,
                    onTap: _goToNext,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Column(
      children: [
        const Text(
          "Top Products",
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 60,
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromRGBO(245, 171, 30, 0.5),
                const Color.fromRGBO(245, 171, 30, 1),
                const Color.fromRGBO(245, 171, 30, 0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Our best-selling hardware, loved by customers",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.7), letterSpacing: 0.5),
        ),
      ],
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _NavArrow({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color.fromRGBO(245, 171, 30, 0.15),
          border: Border.all(color: const Color.fromRGBO(245, 171, 30, 0.4), width: 1.5),
        ),
        child: Icon(
          icon,
          color: enabled ? const Color.fromRGBO(245, 171, 30, 1) : Colors.grey.shade600,
          size: 24,
        ),
      ),
    );
  }
}

class _Product {
  final String name;
  final String price;
  final String image;

  const _Product({required this.name, required this.price, required this.image});
}

class _PremiumProductCard extends StatefulWidget {
  final _Product product;

  const _PremiumProductCard({required this.product});

  @override
  State<_PremiumProductCard> createState() => _PremiumProductCardState();
}

class _PremiumProductCardState extends State<_PremiumProductCard>
    with SingleTickerProviderStateMixin {
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      // Isolates the card's own hover animation into its own raster
      // layer so scaling/shadow changes don't force neighboring cards
      // (or the page behind them) to repaint.
      child: RepaintBoundary(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(_cardRadius),
              border: Border.all(
                color: _isHovered
                    ? const Color.fromRGBO(245, 171, 30, 0.6)
                    : Colors.grey.shade200,
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
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(_cardRadius),
                    topRight: Radius.circular(_cardRadius),
                  ),
                  child: Container(
                    height: 260,
                    width: double.infinity,
                    color: Colors.grey.shade50,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          widget.product.image,
                          fit: BoxFit.cover,
                          // Downsamples the decoded image to roughly the
                          // display size instead of decoding it at full
                          // resolution every time — a common hidden cause
                          // of jank with Image.asset in grids.
                          cacheWidth: 400,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey.shade400,
                              size: 40,
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
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(245, 171, 30, 1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "BEST SELLER",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 100,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (index) => Icon(
                                  Icons.star,
                                  size: 13,
                                  color: index < 4
                                      ? const Color.fromRGBO(245, 171, 30, 1)
                                      : Colors.grey.shade300,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text("(124)", style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.product.price,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(245, 171, 30, 1),
                            ),
                          ),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _isHovered ? 1.0 : 0.0,
                            child: _buildQuickActionButton(
                              Icons.shopping_bag_outlined,
                              Colors.black,
                              backgroundColor: const Color.fromRGBO(245, 171, 30, 1),
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

class _ViewAllProductsButton extends StatefulWidget {
  const _ViewAllProductsButton();

  @override
  State<_ViewAllProductsButton> createState() => _ViewAllProductsButtonState();
}

class _ViewAllProductsButtonState extends State<_ViewAllProductsButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Color.fromRGBO(245, 171, 30, _isHovered ? 1.0 : 0.6), width: 1.5),
          borderRadius: BorderRadius.circular(8),
          color: _isHovered ? const Color.fromRGBO(245, 171, 30, 0.08) : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "View All Companies",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.3),
            ),
            const SizedBox(width: 8),
            AnimatedRotation(
              duration: const Duration(milliseconds: 300),
              turns: _isHovered ? 0.125 : 0.0,
              child: const Icon(Icons.arrow_forward, color: Color.fromRGBO(245, 171, 30, 1), size: 16),
            ),
          ],
        ),
      ),
    );
  }
}