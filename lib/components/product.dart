import 'package:flutter/material.dart';

class TopProductsSection extends StatelessWidget {
  const TopProductsSection({super.key});

  static const List<_Product> _products = [
    _Product(
      name: "Matte Black Cabinet Handle",
      price: "\$12.99",
      image: "assets/port.jpg",
    ),
    _Product(
      name: "Brushed Steel Door Handle",
      price: "\$18.50",
      image: "assets/port2.png",
    ),
    _Product(
      name: "Premium Soft-Close Hinge",
      price: "\$9.75",
      image: "assets/port3.png",
    ),
    _Product(
      name: "Modern Aldrop Lock",
      price: "\$24.00",
      image: "assets/port.jpg",
    ),
    _Product(
      name: "Chrome Finish Handle",
      price: "\$14.25",
      image: "assets/port2.png",
    ),
    _Product(
      name: "Concealed Door Hinge",
      price: "\$11.00",
      image: "assets/port3.png",
    ),
    _Product(
      name: "Heavy Duty Tower Bolt",
      price: "\$8.50",
      image: "assets/port.jpg",
    ),
    _Product(
      name: "Antique Brass Handle",
      price: "\$21.99",
      image: "assets/port2.png",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withOpacity(0.9),
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Section Header
              _buildSectionHeader(),
              const SizedBox(height: 40),

              // Product Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 900
                      ? 4
                      : constraints.maxWidth > 600
                          ? 3
                          : constraints.maxWidth > 400
                              ? 2
                              : 1;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.77,
                    ),
                    itemBuilder: (context, index) {
                      return _PremiumProductCard(product: _products[index]);
                    },
                  );
                },
              ),

              const SizedBox(height: 40),

              // View All Button
              const _ViewAllProductsButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Column(
      children: [
        // Decorative top line
       
        const SizedBox(height: 16),

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
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _Product {
  final String name;
  final String price;
  final String image;

  const _Product({
    required this.name,
    required this.price,
    required this.image,
  });
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
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  static const double _cardRadius = 12;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _isHovered = true);
        _scaleController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _scaleController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(_cardRadius),
                border: Border.all(
                  color: _isHovered
                      ? const Color.fromRGBO(245, 171, 30, 0.6)
                      : Colors.grey.shade200,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.06),
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
                  // Product Image Section — explicitly rounded on the
                  // top-left and top-right corners only
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
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey.shade400,
                                size: 40,
                              ),
                            ),
                          ),
                          // Gradient overlay on hover
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: _isHovered ? 0.3 : 0.0,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Favorite / wishlist quick action only
                          Positioned(
                            top: 10,
                            right: 10,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: _isHovered ? 1.0 : 0.0,
                              child: _buildQuickActionButton(
                                Icons.favorite_border,
                                Colors.white,
                                () {},
                              ),
                            ),
                          ),

                          // Best Seller Badge
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
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

                  // Product Info Section
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
                            // Rating stars
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
                                Text(
                                  "(124)",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
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
                              duration: const Duration(milliseconds: 300),
                              opacity: _isHovered ? 1.0 : 0.0,
                              child: _buildQuickActionButton(
                                Icons.shopping_bag_outlined,
                                Colors.black,
                                () {},
                                backgroundColor:
                                    const Color.fromRGBO(245, 171, 30, 1),
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
          );
        },
      ),
    );
  }

  Widget _buildQuickActionButton(
    IconData icon,
    Color color,
    VoidCallback onTap, {
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.black.withOpacity(0.7),
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        size: 16,
        color: color,
      ),
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
          border: Border.all(
            color: Color.fromRGBO(245, 171, 30, _isHovered ? 1.0 : 0.6),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
          color: _isHovered
              ? const Color.fromRGBO(245, 171, 30, 0.08)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "View All Companies",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedRotation(
              duration: const Duration(milliseconds: 300),
              turns: _isHovered ? 0.125 : 0.0, // rotates ~45 degrees clockwise
              child: const Icon(
                Icons.arrow_forward,
                color: Color.fromRGBO(245, 171, 30, 1),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}