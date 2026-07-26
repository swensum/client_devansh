import 'package:devansh/components/footer.dart';
import 'package:devansh/components/header.dart';
import 'package:devansh/components/stat.dart';
import 'package:devansh/models/catalogmodels.dart';
import 'package:devansh/services/catalogservice.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visibility_detector/visibility_detector.dart';

const double _kHeaderHeight = 100;
const _gold = Color.fromRGBO(245, 171, 30, 1);

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: _kHeaderHeight),
                const _WelcomeSection(),
                const _GallerySection(),
                const StatsSection(),
                const _FeaturesSection(),
                 const _BrandsSection(),
                const Footer(),
              ],
            ),
          ),
          const Positioned(top: 0, left: 0, right: 0, child: Header()),
        ],
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 90),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1300),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              final image = _WelcomeImage(isWide: isWide);
              final text = _WelcomeText(isWide: isWide);

              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 5, child: image),
                        const SizedBox(width: 60),
                        Expanded(flex: 6, child: text),
                      ],
                    )
                  : Column(
                      children: [
                        image,
                        const SizedBox(height: 40),
                        text,
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }
}
class _WelcomeImage extends StatelessWidget {
  final bool isWide;
  const _WelcomeImage({required this.isWide});

  @override
  Widget build(BuildContext context) {
    final height = isWide ? 550.0 : 380.0;
    const offset = 24.0;
    const accentHeightReduction = 80.0; // how much shorter the gold block is vs the photo

    return SizedBox(
      height: height + offset,
      child: Stack(
        children: [
          // Accent block — now shorter than the photo, not full height.
          Positioned(
            left: offset,
            top: offset,
            right: 0,
            bottom: accentHeightReduction,
            child: Container(
              decoration: BoxDecoration(
                color: _gold,
                border: Border.all(color: _gold.withValues(alpha: 0.4), width: 1.2),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            right: offset,
            bottom: offset,
            child: ClipRRect(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/decor.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),

          // "Since 2019" badge — a small accent block over the photo's
          // bottom-left corner.
          Positioned(
            left: 10,
            bottom: offset + 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: _gold,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: const Text(
                "SINCE 2019",
                style: TextStyle(
                  fontFamily: 'BrandonGrotesque',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _WelcomeText extends StatelessWidget {
  final bool isWide;
  const _WelcomeText({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "WELCOME TO",
          textAlign: isWide ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            fontFamily: 'BrandonGrotesque',
            fontSize: 13,
            letterSpacing: 3,
            fontWeight: FontWeight.w600,
            color: _gold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Devansh Suppliers",
          textAlign: isWide ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            fontFamily: 'BrandonGrotesque',
            fontSize: isWide ? 40 : 30,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 70,
          height: 4,
          decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(height: 24),

        Text(
          "Namaste everyone from the DEVANSH family.\n"
          "At Devansh Hardware, we are committed to providing premium-quality "
          "hardware solutions that combine durability, functionality, and modern "
          "design. Our carefully selected range includes cabinet handles, door "
          "fittings, mortice locks, aldrops, tower bolts, hinges, and other "
          "architectural hardware designed to meet the needs of both residential "
          "and commercial projects.\n"
          "We believe that quality products and dependable service go hand in hand. "
          "Whether you are building a new space, renovating an existing one, or "
          "working on a custom interior project, our goal is to provide reliable "
          "products at competitive prices while helping you find the right solution "
          "for your requirements.\n"
          "Customer satisfaction is at the heart of everything we do. We take pride "
          "in offering genuine products, trusted brands, and professional service "
          "that you can rely on. Thank you for choosing Devansh Suppliers—we look "
          "forward to being a part of your next project.",
          textAlign: isWide ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            fontFamily: 'BrandonGrotesque',
            fontWeight: FontWeight.w400,
            fontSize: 15.5,
            height: 1.8,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 28),
        Align(
          alignment: isWide ? Alignment.centerLeft : Alignment.center,
          child: ElevatedButton(
            onPressed: () => context.push('/products'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text(
              "Explore Collection",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
            ),
          ),
        ),
      ],
    );
  }
}
class _GallerySection extends StatelessWidget {
  const _GallerySection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
     decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.85),
                  Colors.black.withValues(alpha: 0.6),
                ],
                stops: const [0.0, 0.65],
              ),
            ),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;

              if (isWide) {
                return SizedBox(
                  height: 500,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _GalleryImage(asset: 'assets/devansh.png'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Expanded(child: _GalleryImage(asset: 'assets/chimney.png')),
                            const SizedBox(height: 16),
                            Expanded(
                              child: _GalleryImage(
                                asset: 'assets/basket.png',
                               
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  SizedBox(
                    height: 260,
                    width: double.infinity,
                    child: _GalleryImage(asset: 'assets/devansh.png'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 140,
                          child: _GalleryImage(asset: 'assets/chimney.png'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 140,
                          child: _GalleryImage(
                            asset: 'assets/basket.png',
                           
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GalleryImage extends StatelessWidget {
  final String asset;
  final BoxFit fit;
  final Color? bg;

  // ignore: unused_element_parameter
  const _GalleryImage({required this.asset, this.fit = BoxFit.cover, this.bg});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
     
      child: Container(
        color: bg ?? Colors.white10,
        child: Image.asset(asset, fit: fit, width: double.infinity, height: double.infinity),
      ),
    );
  }

}
class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();

  static const List<_FeatureCardData> _features = [
    _FeatureCardData(
      iconAsset: 'assets/png/door-handle.png',
      
      title: "Genuine Products",
      description:
          "We provide you with top-quality, sustainable, and authentic products.",
    ),
    _FeatureCardData(
      iconAsset: 'assets/png/badge.png',
      title: "Verified Sellers",
      description:
          "We are verified suppliers certified by top global companies for our genuine products.",
    ),
    _FeatureCardData(
      iconAsset: 'assets/png/money.png',
      title: "Big Savings",
      description:
          "We present you with the best offers & deals on all our products and accessories.",
    ),
    _FeatureCardData(
      iconAsset: 'assets/png/virtual-assistant.png',
      title: "Excellent Supports",
      description:
          "We provide high-quality services for all our customers with personal assistance.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1300),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final columns = w > 900 ? 4 : (w > 600 ? 2 : 1);
              final cardWidth = (w - (columns - 1) * 24) / columns;

              return Wrap(
  spacing: 24,
  runSpacing: 24,
  children: _features
      .map((f) => SizedBox(
            width: cardWidth,
            height: 380, // fixed height — keeps all 4 cards equal
            child: _FeatureCard(data: f),
          ))
      .toList(),
);
            },
          ),
        ),
      ),
    );
  }
}

class _FeatureCardData {
  final String iconAsset;
  final String title;
  final String description;

  const _FeatureCardData({
    required this.iconAsset,
    required this.title,
    required this.description,
  });
}

class _FeatureCard extends StatefulWidget {
  final _FeatureCardData data;
  const _FeatureCard({required this.data});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}
class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFF1E1E1E) : const Color(0xFF161616),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hovered ? _gold : Colors.white.withValues(alpha: 0.12),
            width: _hovered ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? 0.4 : 0.2),
              blurRadius: _hovered ? 20 : 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 104,
              height: 104,
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: AnimatedRotation(
                turns: _hovered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                child: Image.asset(
                  widget.data.iconAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_outlined, size: 38, color: _gold);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              widget.data.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                height: 1.5,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _BrandsSection extends StatefulWidget {
  const _BrandsSection();

  @override
  State<_BrandsSection> createState() => _BrandsSectionState();
}
class _BrandsSectionState extends State<_BrandsSection> {
  final CatalogService _catalogService = CatalogService();
  bool _visible = false;

  void _handleVisibility(VisibilityInfo info) {
    if (!_visible && info.visibleFraction > 0.2) {
      setState(() => _visible = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('about-brands-visibility'),
      onVisibilityChanged: _handleVisibility,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.black.withValues(alpha: 0.85),
              Colors.black.withValues(alpha: 0.6),
            ],
            stops: const [0.0, 0.65],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                const Text(
                  "Brands We Work With",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 60,
                  height: 3,
                  decoration: BoxDecoration(
                    color: _gold,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Trusted global manufacturers behind every product we stock",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 44),
                StreamBuilder<List<Company>>(
                  stream: _catalogService.watchCompanies(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(color: _gold),
                      );
                    }

                    final companies = snapshot.data!;
                    if (companies.isEmpty) return const SizedBox.shrink();

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        const columns = 4;
                        const spacing = 20.0;
                        final w = constraints.maxWidth;
                        final tileWidth = (w - (columns - 1) * spacing) / columns;

                        return Wrap(
                          alignment: WrapAlignment.center,
                          spacing: spacing,
                          runSpacing: spacing,
                          children: companies
                              .map((company) => SizedBox(
                                    width: tileWidth,
                                    height: tileWidth * 0.75, // keeps a consistent aspect ratio
                                    child: _BrandTile(company: company),
                                  ))
                              .toList(),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandTile extends StatefulWidget {
  final Company company;
  const _BrandTile({required this.company});

  @override
  State<_BrandTile> createState() => _BrandTileState();
}
class _BrandTileState extends State<_BrandTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final logoAsset = widget.company.imageUrl;
    final isNetworkImage = logoAsset != null && logoAsset.startsWith('http');

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          context.push('/products?company=${widget.company.id}');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered ? _gold : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovered ? 0.3 : 0.15),
                blurRadius: _hovered ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: logoAsset == null
                ? Text(
                    widget.company.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  )
                : isNetworkImage
                    ? Image.network(
                        logoAsset,
                        fit: BoxFit.contain,
                        cacheWidth: 320,
                        errorBuilder: (context, error, stackTrace) => Text(
                          widget.company.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      )
                    : Image.asset(
                        logoAsset,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Text(
                          widget.company.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}