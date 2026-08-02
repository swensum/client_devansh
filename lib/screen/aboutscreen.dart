// ignore_for_file: unused_element_parameter

import 'package:devansh/components/footer.dart';
import 'package:devansh/components/header.dart';
import 'package:devansh/components/reviews.dart' show userAvatar;
import 'package:devansh/components/stat.dart';
import 'package:devansh/components/topbar.dart';
import 'package:devansh/models/authmodel.dart';
import 'package:devansh/models/catalogmodels.dart';
import 'package:devansh/models/reviewmodel.dart';
import 'package:devansh/services/authservice.dart';
import 'package:devansh/services/catalogservice.dart';
import 'package:devansh/services/reviewservice.dart';
import 'package:devansh/widgets/app_page_scaffold_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visibility_detector/visibility_detector.dart';

const _gold = Color.fromRGBO(245, 171, 30, 1);

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precached) {
      _precached = true;
      precacheImage(const AssetImage('assets/decor.jpg'), context);
      precacheImage(const AssetImage('assets/devansh.jpg'), context);
      precacheImage(const AssetImage('assets/chimney.jpg'), context);
      precacheImage(const AssetImage('assets/basket.jpg'), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      body: Column(
        children: [
          SizedBox(height: Header.height + TopBar.height),
          const _WelcomeSection(),
          const _GallerySection(),
          const StatsSection(),
          const _FeaturesSection(),
          const _BrandsSection(),
          const _ReviewFormSection(),
          const Footer(),
        ],
      ),
    );
  }
}

class _RevealOnScroll extends StatefulWidget {
  final Widget child;
  final Key detectorKey;
  final double offsetY;
  final Duration duration;
  final double visibleThreshold;

  const _RevealOnScroll({
    required this.child,
    required this.detectorKey,
    this.offsetY = 24,
    this.duration = const Duration(milliseconds: 550),
    this.visibleThreshold = 0.15,
  });

  @override
  State<_RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<_RevealOnScroll> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: widget.detectorKey,
      onVisibilityChanged: (info) {
        if (!_visible && info.visibleFraction > widget.visibleThreshold) {
          setState(() => _visible = true);
        }
      },
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : Offset(0, widget.offsetY / 100),
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _visible ? 1 : 0,
          duration: widget.duration,
          curve: Curves.easeOut,
          child: widget.child,
        ),
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
                  : Column(children: [image, const SizedBox(height: 40), text]);
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
    const accentHeightReduction = 80.0;

    return SizedBox(
      height: height + offset,
      child: Stack(
        children: [
          Positioned(
            left: offset,
            top: offset,
            right: 0,
            bottom: accentHeightReduction,
            child: Container(
              decoration: BoxDecoration(
                color: _gold,
                border: Border.all(
                  color: _gold.withValues(alpha: 0.4),
                  width: 1.2,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            right: offset,
            bottom: offset,
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
                cacheWidth: 700,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
              ),
            ),
          ),
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
      crossAxisAlignment: isWide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
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
          decoration: BoxDecoration(
            color: _gold,
            borderRadius: BorderRadius.circular(2),
          ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
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
      child: _RevealOnScroll(
        detectorKey: const Key('reveal-gallery'),
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
                          child: _GalleryImage(asset: 'assets/devansh.jpg'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Expanded(
                                child: _GalleryImage(
                                  asset: 'assets/chimney.jpg',
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: _GalleryImage(
                                  asset: 'assets/basket.jpg',
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
                      child: _GalleryImage(asset: 'assets/devansh.jpg'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 140,
                            child: _GalleryImage(asset: 'assets/chimney.jpg'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 140,
                            child: _GalleryImage(asset: 'assets/basket.jpg'),
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
      ),
    );
  }
}

class _GalleryImage extends StatelessWidget {
  final String asset;
  const _GalleryImage({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white10,
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        cacheWidth: 700,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: child,
          );
        },
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
      child: _RevealOnScroll(
        detectorKey: const Key('reveal-features'),
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
                      .map(
                        (f) => SizedBox(
                          width: cardWidth,
                          height: 380,
                          child: _FeatureCard(data: f),
                        ),
                      )
                      .toList(),
                );
              },
            ),
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
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_outlined, size: 38, color: _gold),
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
        child: _RevealOnScroll(
          detectorKey: const Key('reveal-brands'),
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
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
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
                          final tileWidth =
                              (w - (columns - 1) * spacing) / columns;

                          return Wrap(
                            alignment: WrapAlignment.center,
                            spacing: spacing,
                            runSpacing: spacing,
                            children: companies
                                .map(
                                  (company) => SizedBox(
                                    width: tileWidth,
                                    height: tileWidth * 0.75,
                                    child: _BrandTile(company: company),
                                  ),
                                )
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
        onTap: () => context.push('/products?company=${widget.company.id}'),
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

class _ReviewFormSection extends StatefulWidget {
  const _ReviewFormSection();

  @override
  State<_ReviewFormSection> createState() => _ReviewFormSectionState();
}

class _ReviewFormSectionState extends State<_ReviewFormSection> {
  final _formKey = GlobalKey<FormState>();
  final _roleController = TextEditingController();
  final _messageController = TextEditingController();
  final _reviewService = ReviewService();

  int _rating = 0;
  bool _isSubmitting = false;
  bool _submitted = false;
  bool _loadingExisting = false;
  Review? _existingReview;
  String? _loadedForUid;

  @override
  void initState() {
    super.initState();
    // Kick off a load for whoever's already signed in (if anyone), and
    // re-run whenever the signed-in user changes (sign in, sign out, or a
    // different account). Doing this via a listener — rather than as a
    // side-effect inside build() — avoids calling setState() synchronously
    // during the build phase, which is what was leaving the spinner stuck
    // forever after signing in from this page.
    AuthService.instance.currentUser.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  void _onAuthChanged() {
    final user = AuthService.instance.currentUser.value;
    if (user == null) {
      // Signed out: reset so a future sign-in (possibly a different
      // account) triggers a fresh load instead of being skipped.
      if (_loadedForUid != null) {
        setState(() {
          _loadedForUid = null;
          _existingReview = null;
          _loadingExisting = false;
        });
      }
      return;
    }
    _loadExistingReview(user.uid);
  }

  @override
  void dispose() {
    AuthService.instance.currentUser.removeListener(_onAuthChanged);
    _roleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingReview(String uid) async {
    if (_loadedForUid == uid) return; // already loaded/loading for this user
    _loadedForUid = uid;
    setState(() => _loadingExisting = true);
    try {
      final review = await _reviewService.getUserReview(uid);
      if (!mounted) return;
      setState(() {
        _existingReview = review;
        _loadingExisting = false;
      });
    } catch (e) {
      debugPrint('🔥 Failed to load existing review: $e');
      if (!mounted) return;
      setState(() => _loadingExisting = false);
    }
  }

  Future<void> _handleSubmit(AppUser user) async {
    if (!_formKey.currentState!.validate()) return;
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a star rating.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final review = Review(
        id: '',
        name: user.name?.isNotEmpty == true
            ? user.name!
            : (user.email ?? 'Customer'),
        role: _roleController.text.trim().isEmpty
            ? "Customer"
            : _roleController.text.trim(),
        message: _messageController.text.trim(),
        rating: _rating,
        photoUrl: user.photoUrl,
      );

      await _reviewService.submitReview(review, user.uid);

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitted = true;
        _existingReview = review; // once submitted, locks the form permanently
      });
      _roleController.clear();
      _messageController.clear();

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _submitted = false);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to submit review. Please try again."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0D0D0D),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
      child: _RevealOnScroll(
        detectorKey: const Key('reveal-review-form'),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              children: [
                const Text(
                  "Share Your Experience",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                  "Tell other customers what you think of our products and service.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 32),
                ValueListenableBuilder<AppUser?>(
                  valueListenable: AuthService.instance.currentUser,
                  builder: (context, user, _) {
                    if (user == null) {
                      return _signInPrompt(context);
                    }

                    // The fetch itself is triggered by _onAuthChanged (via the
                    // listener set up in initState) — build() only reads state.
                    if (_loadingExisting &&
                        _existingReview == null &&
                        _loadedForUid == user.uid) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(color: _gold),
                      );
                    }

                    // Once a review exists, the form is permanently locked —
                    // no editing, just a summary of what was submitted.
                    if (_existingReview != null) {
                      return _alreadySubmittedCard(_existingReview!);
                    }
                    return _formCard(user);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _alreadySubmittedCard(Review review) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: _gold, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Thanks for your feedback!",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(5, (i) {
              return Icon(
                Icons.star,
                size: 18,
                color: i < review.rating ? _gold : Colors.white24,
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(
            review.message,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (!review.approved) ...[
            const SizedBox(height: 8),
            Text(
              "Pending approval — it'll appear publicly once reviewed.",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 12.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _signInPrompt(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_outline, color: _gold, size: 32),
          const SizedBox(height: 14),
          const Text(
            "Sign in to leave a review",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "We ask you to sign in so every review comes from a real customer.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.push('/auth'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _gold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Sign In",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formCard(AppUser user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                userAvatar(
                  photoUrl: user.photoUrl,
                  name: user.name ?? user.email ?? '?',
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    user.name?.isNotEmpty == true
                        ? user.name!
                        : (user.email ?? 'Customer'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildField(
              controller: _roleController,
              label: "Role / Occupation (optional)",
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _messageController,
              label: "Your Review",
              maxLines: 4,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? "Please enter a review"
                  : null,
            ),
            const SizedBox(height: 20),
            _buildStarPicker(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : () => _handleSubmit(user),
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text(
                      "Submit Review",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
            ),
            if (_submitted) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: _gold, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "Thanks! Your review has been submitted.",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      cursorColor: _gold,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _gold, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildStarPicker() {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Your Rating",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (i) {
            final starIndex = i + 1;
            return GestureDetector(
              onTap: () => setState(() => _rating = starIndex),
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.star,
                  size: 28,
                  color: starIndex <= _rating ? _gold : Colors.white24,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
