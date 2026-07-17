import 'package:devansh/components/about.dart';
import 'package:devansh/components/categories.dart';
import 'package:devansh/components/contact.dart';
import 'package:devansh/components/footer.dart';
import 'package:devansh/components/header.dart';
import 'package:devansh/components/product.dart';
import 'package:devansh/components/reviews.dart';
import 'package:devansh/components/stat.dart';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:go_router/go_router.dart';

const double _kHeaderHeight = 100;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _headerRevealed = false;

  @override
  void initState() {
    super.initState();
    // Slide the header in shortly after first paint, regardless of scroll.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) setState(() => _headerRevealed = true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: _kHeaderHeight), // reserve space
                const HeroCarousel(),
                const _Divider(),
                const StatsSection(),
                const _Divider(),
                const AboutSection(),
                const _Divider(),
                const CategoriesSection(),
                // const TopProductsSection(),
                const _Divider(),
                const ReviewsSection(),
                const ContactSection(),
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
  }
}

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

enum HeroTextAlign { left, right, center }

class HeroSlide {
  final String image;
  final String headline;
  final String subtext;
  final HeroTextAlign align;

  const HeroSlide({
    required this.image,
    required this.headline,
    required this.subtext,
    this.align = HeroTextAlign.left,
  });
}

const List<HeroSlide> _kSlides = [
  HeroSlide(
    image: 'assets/port.jpg',
    headline: "Elevate Every Space with Premium Cabinet Handles",
    subtext:
        "Discover modern, durable, and elegant cabinet & door handles "
        "crafted to complement every interior.",
    align: HeroTextAlign.left,
  ),
  HeroSlide(
    image: 'assets/port2.png',
    headline: "Timeless Design Meets Everyday Durability",
    subtext:
        "Designed for modern homes and premium spaces, our aldrops deliver "
        "reliable protection with a refined matte-black aesthetic.",
    align: HeroTextAlign.right,
  ),
  HeroSlide(
    image: 'assets/port3.png',
    headline: "Crafted Details, Built to Impress",
    subtext:
        "A collection of fittings and finishes designed to bring "
        "precision and character to every corner of your home.",
    align: HeroTextAlign.center,
  ),
];

class HeroCarousel extends StatefulWidget {
  const HeroCarousel({super.key});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel>
    with WidgetsBindingObserver {
  static const int _initialPage = 10000;

  late final PageController _pageController;
  int _currentIndex = 0;
  int _pageCounter = _initialPage;
  Timer? _autoScrollTimer;
  bool _imagesPrecached = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(initialPage: _initialPage);
    _startAutoScroll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPrecached) {
      _imagesPrecached = true;
      for (final slide in _kSlides) {
        precacheImage(AssetImage(slide.image), context);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _startAutoScroll();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _autoScrollTimer?.cancel();
        break;
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!_pageController.hasClients) return;
      _pageCounter++;
      _pageController.animateToPage(
        _pageCounter,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    double aspectRatio;
    if (screenWidth > 900) {
      aspectRatio = 16 / 8; // desktop – wider
    } else if (screenWidth > 600) {
      aspectRatio = 16 / 9; // tablet
    } else {
      aspectRatio = 16 / 10; // mobile – taller
    }

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final slide = _kSlides[index % _kSlides.length];
              return _HeroSlideView(slide: slide);
            },
            onPageChanged: (index) {
              setState(() {
                _pageCounter = index;
                _currentIndex = index % _kSlides.length;
              });
            },
          ),
          Positioned(
            bottom: 20,
            right: 30,
            child: Row(
              children: List.generate(_kSlides.length, (i) {
                final isActive = i == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color.fromRGBO(245, 171, 30, 1)
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroAlignmentInfo {
  final Alignment boxAlignment;
  final CrossAxisAlignment crossAlign;
  final TextAlign textAlign;
  final Alignment gradientBegin;
  final Alignment gradientEnd;

  const _HeroAlignmentInfo({
    required this.boxAlignment,
    required this.crossAlign,
    required this.textAlign,
    required this.gradientBegin,
    required this.gradientEnd,
  });

  static _HeroAlignmentInfo from(HeroTextAlign align) {
    switch (align) {
      case HeroTextAlign.left:
        return const _HeroAlignmentInfo(
          boxAlignment: Alignment.centerLeft,
          crossAlign: CrossAxisAlignment.start,
          textAlign: TextAlign.left,
          gradientBegin: Alignment.centerLeft,
          gradientEnd: Alignment.centerRight,
        );
      case HeroTextAlign.right:
        return const _HeroAlignmentInfo(
          boxAlignment: Alignment.centerRight,
          crossAlign: CrossAxisAlignment.end,
          textAlign: TextAlign.right,
          gradientBegin: Alignment.centerRight,
          gradientEnd: Alignment.centerLeft,
        );
      case HeroTextAlign.center:
        return const _HeroAlignmentInfo(
          boxAlignment: Alignment.center,
          crossAlign: CrossAxisAlignment.center,
          textAlign: TextAlign.center,
          gradientBegin: Alignment.center,
          gradientEnd: Alignment.center,
        );
    }
  }
}
class _HeroResponsive {
  final double headlineSize;
  final double subtextSize;
  final double hPadding;
  final double maxTextBoxWidth;
  final double btnPaddingH;
  final double btnPaddingV;
  final double btnFontSize;
  final double iconSize;

  const _HeroResponsive({
    required this.headlineSize,
    required this.subtextSize,
    required this.hPadding,
    required this.maxTextBoxWidth,
    required this.btnPaddingH,
    required this.btnPaddingV,
    required this.btnFontSize,
    required this.iconSize,
  });

  factory _HeroResponsive.of(double w) {
    if (w > 900) {
      return const _HeroResponsive(
        headlineSize: 36,
        subtextSize: 18,
        hPadding: 60,
        maxTextBoxWidth: 520,
        btnPaddingH: 28,
        btnPaddingV: 18,
        btnFontSize: 15,
        iconSize: 18,
      );
    }
    if (w > 600) {
      return const _HeroResponsive(
        headlineSize: 30,
        subtextSize: 16,
        hPadding: 40,
        maxTextBoxWidth: 420,
        btnPaddingH: 28,
        btnPaddingV: 18,
        btnFontSize: 15,
        iconSize: 18,
      );
    }
    if (w > 400) {
      return const _HeroResponsive(
        headlineSize: 24,
        subtextSize: 14.5,
        hPadding: 24,
        maxTextBoxWidth: double.infinity,
        btnPaddingH: 20,
        btnPaddingV: 12,
        btnFontSize: 13.5,
        iconSize: 16,
      );
    }
    return const _HeroResponsive(
      headlineSize: 20,
      subtextSize: 13,
      hPadding: 16,
      maxTextBoxWidth: double.infinity,
      btnPaddingH: 20,
      btnPaddingV: 12,
      btnFontSize: 13.5,
      iconSize: 16,
    );
  }
}

class _HeroSlideView extends StatefulWidget {
  final HeroSlide slide;

  const _HeroSlideView({required this.slide});

  @override
  State<_HeroSlideView> createState() => _HeroSlideViewState();
}

class _HeroSlideViewState extends State<_HeroSlideView> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final slide = widget.slide;
    final info = _HeroAlignmentInfo.from(slide.align);

    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: Image.asset(
            slide.image,
            fit: BoxFit.cover,
           
            gaplessPlayback: true,
          ),
        ),
        if (slide.align == HeroTextAlign.center)
          Container(color: Colors.black.withValues(alpha: 0.4))
        else
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: info.gradientBegin,
                end: info.gradientEnd,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.7],
              ),
            ),
          ),
        // Responsive text & button section
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final r = _HeroResponsive.of(constraints.maxWidth);

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: r.hPadding),
                child: Align(
                  alignment: info.boxAlignment,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: r.maxTextBoxWidth),
                    child: Column(
                      crossAxisAlignment: info.crossAlign,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          slide.headline,
                          textAlign: info.textAlign,
                          style: TextStyle(
                            fontSize: r.headlineSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.25,
                          ),
                        ),
                        SizedBox(height: r.headlineSize * 0.4),
                        Text(
                          slide.subtext,
                          textAlign: info.textAlign,
                          style: TextStyle(
                            fontSize: r.subtextSize,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: r.subtextSize * 1.8),
                        MouseRegion(
                          onEnter: (_) => setState(() => _isHovered = true),
                          onExit: (_) => setState(() => _isHovered = false),
                          child: AnimatedScale(
                            scale: _isHovered ? 1.005 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: ElevatedButton(
                              onPressed: () {
                                 
          context.push('/products');
        
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isHovered
                                    ? const Color.fromRGBO(255, 181, 40, 1)
                                    : const Color.fromRGBO(245, 171, 30, 1),
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                  horizontal: r.btnPaddingH,
                                  vertical: r.btnPaddingV,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                elevation: _isHovered ? 8 : 2,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Explore Collection",
                                    style: TextStyle(
                                      fontSize: r.btnFontSize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: r.btnFontSize * 0.6),
                                  AnimatedRotation(
                                    duration: const Duration(milliseconds: 300),
                                    turns: _isHovered ? 0.125 : 0.0,
                                    child: Icon(
                                      Icons.arrow_forward,
                                      size: r.iconSize,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}