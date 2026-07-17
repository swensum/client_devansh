// import 'package:devansh/data/catalog.dart';
// import 'package:devansh/models/catalogmodels.dart';


// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:visibility_detector/visibility_detector.dart';

// class TopProductsSection extends StatefulWidget {
//   const TopProductsSection({super.key});

//   @override
//   State<TopProductsSection> createState() => _TopProductsSectionState();
// }

// class _TopProductsSectionState extends State<TopProductsSection> {
//   static const int _perPage = 8;

//   late final PageController _pageController;
//   int _currentPage = 0;

//   bool _visible = false;
// late final List<Product> _products = Catalog.topProducts;
//   late final List<List<Product>> _pages = _pagesFor(_products);

//   void _handleVisibility(VisibilityInfo info) {
//     if (!_visible && info.visibleFraction > 0.2) {
//       setState(() => _visible = true);
//     }
//   }
// List<List<Product>> _pagesFor(List<Product> products) {
//     final pages = <List<Product>>[];
//     for (var i = 0; i < products.length; i += _perPage) {
//       final end = (i + _perPage > products.length) ? products.length : i + _perPage;
//       pages.add(products.sublist(i, end));
//     }
//     return pages;
//   }
 

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _goToPrevious() {
//     if (_currentPage == 0) return;
//     _pageController.previousPage(
//       duration: const Duration(milliseconds: 450),
//       curve: Curves.easeOutCubic,
//     );
//   }

//   void _goToNext(int pageCount) {
//     if (_currentPage == pageCount - 1) return;
//     _pageController.nextPage(
//       duration: const Duration(milliseconds: 450),
//       curve: Curves.easeOutCubic,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final products = _products;
//      final pages = _pages;  

//     if (products.isEmpty) return const SizedBox.shrink();

//     return VisibilityDetector(
//       key: const Key('top-products-section-visibility'),
//       onVisibilityChanged: _handleVisibility,
//       child: LayoutBuilder(
//         builder: (context, outerConstraints) {
//           final r = _ProductsResponsive.of(outerConstraints.maxWidth);

//           return Container(
//             width: double.infinity,
//             padding: EdgeInsets.symmetric(horizontal: r.sectionHPadding, vertical: r.sectionVPadding),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [Colors.black.withValues(alpha: 0.9), Colors.black.withValues(alpha: 0.7)],
//               ),
//             ),
//             child: Center(
//               child: SizedBox(
//                 width: double.infinity,
//                 child: Stack(
//                   children: [
//                     Center(
//                       child: ConstrainedBox(
//                         constraints: const BoxConstraints(maxWidth: 1200),
//                         child: Column(
//                           children: [
//                             _buildSectionHeader(r),
//                             SizedBox(height: r.headerGap),
//                             _RevealOnVisible(
//                               visible: _visible,
//                               delay: const Duration(milliseconds: 400),
//                               child: LayoutBuilder(
//                                 builder: (context, constraints) {
//                                   final availableWidth =
//                                       constraints.maxWidth - (r.gridPadding * 2);
//                                   final cardWidth = (availableWidth -
//                                           (r.crossAxisCount - 1) * r.gridSpacing) /
//                                       r.crossAxisCount;
//                                   final cardHeight = cardWidth / r.childAspectRatio;

//                                   final rows = (_perPage / r.crossAxisCount).ceil();
//                                   final estimatedHeight = rows * cardHeight +
//                                       (rows - 1) * r.gridSpacing +
//                                       (r.gridPadding * 2);

//                                   return SizedBox(
//                                     height: estimatedHeight,
//                                     child: PageView.builder(
//                                       controller: _pageController,
//                                       physics: const NeverScrollableScrollPhysics(),
//                                       itemCount: pages.length,
//                                       allowImplicitScrolling: true,
//                                       onPageChanged: (index) =>
//                                           setState(() => _currentPage = index),
//                                       itemBuilder: (context, pageIndex) {
//                                         final pageProducts = pages[pageIndex];
//                                         return RepaintBoundary(
//                                           child: Padding(
//                                             padding: EdgeInsets.all(r.gridPadding),
//                                             child: GridView.builder(
//                                               clipBehavior: Clip.none,
//                                               physics: const NeverScrollableScrollPhysics(),
//                                               itemCount: pageProducts.length,
//                                               gridDelegate:
//                                                   SliverGridDelegateWithFixedCrossAxisCount(
//                                                 crossAxisCount: r.crossAxisCount,
//                                                 crossAxisSpacing: r.gridSpacing,
//                                                 mainAxisSpacing: r.gridSpacing,
//                                                 childAspectRatio: r.childAspectRatio,
//                                               ),
//                                               itemBuilder: (context, index) {
//                                                 return _PremiumProductCard(
//                                                   product: pageProducts[index],
//                                                   r: r,
//                                                 );
//                                               },
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                             SizedBox(height: r.headerGap * 0.6),
//                             _RevealOnVisible(
//                               visible: _visible,
//                               delay: const Duration(milliseconds: 500),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: List.generate(pages.length, (i) {
//                                   final isActive = i == _currentPage;
//                                   return AnimatedContainer(
//                                     duration: const Duration(milliseconds: 300),
//                                     margin: const EdgeInsets.symmetric(horizontal: 4),
//                                     width: isActive ? 20 : 8,
//                                     height: 8,
//                                     decoration: BoxDecoration(
//                                       color: isActive
//                                           ? const Color.fromRGBO(245, 171, 30, 1)
//                                           : Colors.white.withValues(alpha: 0.3),
//                                       borderRadius: BorderRadius.circular(4),
//                                     ),
//                                   );
//                                 }),
//                               ),
//                             ),
//                             SizedBox(height: r.headerGap * 0.6),
//                             _RevealOnVisible(
//                               visible: _visible,
//                               delay: const Duration(milliseconds: 600),
//                               child: const _ViewAllProductsButton(),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     if (r.showNavArrows) ...[
//                       Positioned(
//                         left: 0,
//                         top: 0,
//                         bottom: 0,
//                         child: Center(
//                           child: _NavArrow(
//                             icon: Icons.keyboard_double_arrow_left,
//                             enabled: _currentPage != 0,
//                             onTap: _goToPrevious,
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         right: 0,
//                         top: 0,
//                         bottom: 0,
//                         child: Center(
//                           child: _NavArrow(
//                             icon: Icons.keyboard_double_arrow_right,
//                             enabled: _currentPage != pages.length - 1,
//                             onTap: () => _goToNext(pages.length),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildSectionHeader(_ProductsResponsive r) {
//     return Column(
//       children: [
//         _RevealOnVisible(
//           visible: _visible,
//           delay: const Duration(milliseconds: 0),
//           child: Text(
//             "Top Products",
//             style: TextStyle(
//               fontSize: r.headingSize,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//               letterSpacing: 1.5,
//             ),
//           ),
//         ),
//         const SizedBox(height: 10),
//         _RevealOnVisible(
//           visible: _visible,
//           delay: const Duration(milliseconds: 100),
//           child: Container(
//             width: 60,
//             height: 3,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   const Color.fromRGBO(245, 171, 30, 0.5),
//                   const Color.fromRGBO(245, 171, 30, 1),
//                   const Color.fromRGBO(245, 171, 30, 0.5),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         _RevealOnVisible(
//           visible: _visible,
//           delay: const Duration(milliseconds: 200),
//           child: Text(
//             "Our best-selling hardware, loved by customers",
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: r.subtitleSize,
//               color: Colors.white.withValues(alpha: 0.7),
//               letterSpacing: 0.5,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _RevealOnVisible extends StatefulWidget {
//   final bool visible;
//   final Duration delay;
//   final Widget child;

//   const _RevealOnVisible({
//     required this.visible,
//     required this.delay,
//     required this.child,
//   });

//   @override
//   State<_RevealOnVisible> createState() => _RevealOnVisibleState();
// }

// class _RevealOnVisibleState extends State<_RevealOnVisible> {
//   bool _scheduled = false;
//   bool _started = false;

//   @override
//   void initState() {
//     super.initState();
//     _maybeSchedule();
//   }

//   @override
//   void didUpdateWidget(covariant _RevealOnVisible oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     _maybeSchedule();
//   }

//   void _maybeSchedule() {
//     if (widget.visible && !_scheduled) {
//       _scheduled = true;
//       Future.delayed(widget.delay, () {
//         if (mounted) setState(() => _started = true);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedOpacity(
//       duration: const Duration(milliseconds: 500),
//       curve: Curves.easeOut,
//       opacity: _started ? 1.0 : 0.0,
//       child: AnimatedSlide(
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeOutCubic,
//         offset: _started ? Offset.zero : const Offset(0, 0.15),
//         child: widget.child,
//       ),
//     );
//   }
// }

// class _NavArrow extends StatelessWidget {
//   final IconData icon;
//   final bool enabled;
//   final VoidCallback onTap;

//   const _NavArrow({required this.icon, required this.enabled, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: enabled ? onTap : null,
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: const Color.fromRGBO(245, 171, 30, 0.15),
//           border: Border.all(color: const Color.fromRGBO(245, 171, 30, 0.4), width: 1.5),
//         ),
//         child: Icon(
//           icon,
//           color: enabled ? const Color.fromRGBO(245, 171, 30, 1) : Colors.grey.shade600,
//           size: 24,
//         ),
//       ),
//     );
//   }
// }

// class _ProductsResponsive {
//   final int crossAxisCount;
//   final double childAspectRatio;
//   final double gridPadding;
//   final double gridSpacing;
//   final double sectionHPadding;
//   final double sectionVPadding;
//   final double headingSize;
//   final double subtitleSize;
//   final double headerGap;
//   final double cardContentHeight;
//   final double cardTitleFont;
//   final double cardPriceFont;
//   final bool showNavArrows;

//   const _ProductsResponsive({
//     required this.crossAxisCount,
//     required this.childAspectRatio,
//     required this.gridPadding,
//     required this.gridSpacing,
//     required this.sectionHPadding,
//     required this.sectionVPadding,
//     required this.headingSize,
//     required this.subtitleSize,
//     required this.headerGap,
//     required this.cardContentHeight,
//     required this.cardTitleFont,
//     required this.cardPriceFont,
//     required this.showNavArrows,
//   });

//   factory _ProductsResponsive.of(double w) {
//     if (w > 900) {
//       return const _ProductsResponsive(
//         crossAxisCount: 4,
//         childAspectRatio: 0.75,
//         gridPadding: 16,
//         gridSpacing: 20,
//         sectionHPadding: 30,
//         sectionVPadding: 60,
//         headingSize: 34,
//         subtitleSize: 16,
//         headerGap: 40,
//         cardContentHeight: 100,
//         cardTitleFont: 14,
//         cardPriceFont: 16,
//         showNavArrows: true,
//       );
//     }
//     if (w > 600) {
//       return const _ProductsResponsive(
//         crossAxisCount: 3,
//         childAspectRatio: 0.72,
//         gridPadding: 14,
//         gridSpacing: 16,
//         sectionHPadding: 24,
//         sectionVPadding: 48,
//         headingSize: 28,
//         subtitleSize: 15,
//         headerGap: 32,
//         cardContentHeight: 100,
//         cardTitleFont: 10.5,
//         cardPriceFont: 12,
//         showNavArrows: true,
//       );
//     }
//     if (w > 400) {
//       return const _ProductsResponsive(
//         crossAxisCount: 2,
//         childAspectRatio: 0.68,
//         gridPadding: 10,
//         gridSpacing: 12,
//         sectionHPadding: 16,
//         sectionVPadding: 40,
//         headingSize: 24,
//         subtitleSize: 14,
//         headerGap: 24,
//         cardContentHeight: 100,
//         cardTitleFont: 13,
//         cardPriceFont: 14.5,
//         showNavArrows: false,
//       );
//     }
//     return const _ProductsResponsive(
//       crossAxisCount: 1,
//       childAspectRatio: 1.15,
//       gridPadding: 8,
//       gridSpacing: 12,
//       sectionHPadding: 14,
//       sectionVPadding: 32,
//       headingSize: 20,
//       subtitleSize: 13,
//       headerGap: 20,
//       cardContentHeight: 88,
//       cardTitleFont: 13,
//       cardPriceFont: 14,
//       showNavArrows: false,
//     );
//   }
// }

// class _PremiumProductCard extends StatefulWidget {
//   final Product product; // now the real catalog Product
//   final _ProductsResponsive r;

//   const _PremiumProductCard({required this.product, required this.r});

//   @override
//   State<_PremiumProductCard> createState() => _PremiumProductCardState();
// }

// class _PremiumProductCardState extends State<_PremiumProductCard>
//     with SingleTickerProviderStateMixin {
//   bool _isHovered = false;
//   late final AnimationController _scaleController;
//   late final Animation<double> _scaleAnimation;

//   static const double _cardRadius = 12;

//   @override
//   void initState() {
//     super.initState();
//     _scaleController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 200),
//     );
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
//       CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
//     );
//   }

//   @override
//   void dispose() {
//     _scaleController.dispose();
//     super.dispose();
//   }

//   void _setHovered(bool value) {
//     if (_isHovered == value) return;
//     setState(() => _isHovered = value);
//     value ? _scaleController.forward() : _scaleController.reverse();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final r = widget.r;
//     final product = widget.product;

//     return MouseRegion(
//       cursor: SystemMouseCursors.click,
//       onEnter: (_) => _setHovered(true),
//       onExit: (_) => _setHovered(false),
//       child: GestureDetector(
//         onTap: () {
//           context.push('/product/${product.id}', extra: product);
//         },
//         child: RepaintBoundary(
//           child: ScaleTransition(
//             scale: _scaleAnimation,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white.withValues(alpha: 0.12),
//                 borderRadius: BorderRadius.circular(_cardRadius),
//                 border: Border.all(
//                   color: _isHovered
//                       ? const Color.fromRGBO(245, 171, 30, 0.6)
//                       : Colors.white.withValues(alpha: 0.12),
//                   width: 1.5,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withValues(alpha: _isHovered ? 0.15 : 0.06),
//                     blurRadius: _isHovered ? 20 : 8,
//                     offset: Offset(0, _isHovered ? 8 : 4),
//                     spreadRadius: _isHovered ? 2 : 0,
//                   ),
//                 ],
//               ),
//               clipBehavior: Clip.antiAlias,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: ClipRRect(
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(_cardRadius),
//                         topRight: Radius.circular(_cardRadius),
//                       ),
//                       child: Container(
//                         width: double.infinity,
//                         color: Colors.grey.shade50,
//                         child: Stack(
//                           fit: StackFit.expand,
//                           children: [
//                             Image.asset(
//                               product.imageAsset,
//                               fit: BoxFit.cover,
//                               cacheWidth: 400,
//                               errorBuilder: (context, error, stackTrace) => Center(
//                                 child: Icon(
//                                   Icons.image_not_supported_outlined,
//                                   color: Colors.grey.shade400,
//                                   size: 40,
//                                 ),
//                               ),
//                             ),
//                             AnimatedOpacity(
//                               duration: const Duration(milliseconds: 200),
//                               opacity: _isHovered ? 0.3 : 0.0,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     begin: Alignment.topCenter,
//                                     end: Alignment.bottomCenter,
//                                     colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Positioned(
//                               top: 10,
//                               right: 10,
//                               child: AnimatedOpacity(
//                                 duration: const Duration(milliseconds: 200),
//                                 opacity: _isHovered ? 1.0 : 0.0,
//                                 child: _buildQuickActionButton(Icons.favorite_border, Colors.white),
//                               ),
//                             ),
//                             Positioned(
//                               top: 10,
//                               left: 10,
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                                 decoration: BoxDecoration(
//                                   color: const Color.fromRGBO(245, 171, 30, 1),
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: const Text(
//                                   "BEST SELLER",
//                                   style: TextStyle(
//                                     fontSize: 9,
//                                     fontWeight: FontWeight.w700,
//                                     color: Colors.black,
//                                     letterSpacing: 0.5,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   Container(
//                     height: r.cardContentHeight,
//                     padding: const EdgeInsets.all(14),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               product.name,
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 fontSize: r.cardTitleFont,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.white,
//                                 height: 1.3,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Row(
//                               children: [
//                                 ...List.generate(
//                                   5,
//                                   (index) => Icon(
//                                     Icons.star,
//                                     size: 13,
//                                     color: index < 4
//                                         ? const Color.fromRGBO(245, 171, 30, 1)
//                                         : Colors.grey.shade300,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text("(124)", style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
//                               ],
//                             ),
//                           ],
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               '\$${product.price.toStringAsFixed(2)}',
//                               style: TextStyle(
//                                 fontSize: r.cardPriceFont,
//                                 fontWeight: FontWeight.bold,
//                                 color: const Color.fromRGBO(245, 171, 30, 1),
//                               ),
//                             ),
//                             AnimatedOpacity(
//                               duration: const Duration(milliseconds: 200),
//                               opacity: _isHovered ? 1.0 : 0.0,
//                               child: _buildQuickActionButton(
//                                 Icons.shopping_bag_outlined,
//                                 Colors.black,
//                                 backgroundColor: const Color.fromRGBO(245, 171, 30, 1),
//                                 borderColor: Colors.transparent,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildQuickActionButton(
//     IconData icon,
//     Color color, {
//     Color? backgroundColor,
//     Color? borderColor,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: backgroundColor ?? Colors.black.withValues(alpha: 0.7),
//         shape: BoxShape.circle,
//         border: Border.all(color: borderColor ?? Colors.white.withValues(alpha: 0.2), width: 1),
//       ),
//       child: Icon(icon, size: 16, color: color),
//     );
//   }
// }

// class _ViewAllProductsButton extends StatefulWidget {
//   const _ViewAllProductsButton();

//   @override
//   State<_ViewAllProductsButton> createState() => _ViewAllProductsButtonState();
// }

// class _ViewAllProductsButtonState extends State<_ViewAllProductsButton> {
//   bool _isHovered = false;

//   @override
//   Widget build(BuildContext context) {
//     return MouseRegion(
//       cursor: SystemMouseCursors.click,
//       onEnter: (_) => setState(() => _isHovered = true),
//       onExit: (_) => setState(() => _isHovered = false),
//       child: GestureDetector(
//         onTap: () {
//           context.push('/products');
//         },
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
//           decoration: BoxDecoration(
//             border: Border.all(color: Color.fromRGBO(245, 171, 30, _isHovered ? 1.0 : 0.6), width: 1.5),
//             borderRadius: BorderRadius.circular(8),
//             color: _isHovered ? const Color.fromRGBO(245, 171, 30, 0.08) : Colors.transparent,
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 "View All Products",
//                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.3),
//               ),
//               const SizedBox(width: 8),
//               AnimatedRotation(
//                 duration: const Duration(milliseconds: 300),
//                 turns: _isHovered ? 0.125 : 0.0,
//                 child: const Icon(Icons.arrow_forward, color: Color.fromRGBO(245, 171, 30, 1), size: 16),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }