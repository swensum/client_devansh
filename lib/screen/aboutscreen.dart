import 'package:devansh/components/footer.dart';
import 'package:devansh/components/header.dart';
import 'package:devansh/components/stat.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 125),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
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
    final height = isWide ? 440.0 : 300.0;

    return SizedBox(
      height: height + 24,
      child: Stack(
        children: [
          // Accent block offset behind the photo — the "modern" framing cue.
          Positioned(
            left: 24,
            top: 24,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _gold.withValues(alpha: 0.4), width: 1.2),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            right: 24,
            bottom: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
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
                  'assets/download.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
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
            fontSize: 13,
            letterSpacing: 3,
            fontWeight: FontWeight.w600,
            color: _gold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Devansh Hardware",
          textAlign: isWide ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            fontSize: isWide ? 40 : 30,
            fontWeight: FontWeight.bold,
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
          "For years, we've been delivering premium cabinet handles, door "
          "fittings, mortice locks, aldrops, and architectural hardware that "
          "blend exceptional durability with timeless design. Every product "
          "is crafted with precision using high-quality materials to ensure "
          "lasting performance, reliability, and elegance — for modern "
          "homes, commercial spaces, and custom interiors alike.",
          textAlign: isWide ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            fontSize: 15.5,
            height: 1.7,
            color: Colors.white.withValues(alpha: 0.8),
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
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;

              if (isWide) {
                return SizedBox(
                  height: 480,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _GalleryImage(asset: 'assets/port2.png'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Expanded(child: _GalleryImage(asset: 'assets/port3.png')),
                            const SizedBox(height: 16),
                            Expanded(
                              child: _GalleryImage(
                                asset: 'assets/logo.png',
                                fit: BoxFit.contain,
                                bg: Colors.black,
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
                    child: _GalleryImage(asset: 'assets/port2.png'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 140,
                          child: _GalleryImage(asset: 'assets/port3.png'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 140,
                          child: _GalleryImage(
                            asset: 'assets/logo.png',
                            fit: BoxFit.contain,
                            bg: Colors.black,
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

  const _GalleryImage({required this.asset, this.fit = BoxFit.cover, this.bg});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
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
      color: const Color(0xFF0D0D0D),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: _hovered ? 0.06 : 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hovered ? _gold.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedRotation(
              turns: _hovered ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              child: SizedBox(
                width: 64,
                height: 64,
                child: Image.asset(
                  widget.data.iconAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_outlined, size: 40, color: _gold);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.data.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
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