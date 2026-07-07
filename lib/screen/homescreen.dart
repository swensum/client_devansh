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
                const TopProductsSection(),
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
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(initialPage: _initialPage);
    _startAutoScroll();
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
    return AspectRatio(
      aspectRatio: 16 / 8,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final slide = _kSlides[index % _kSlides.length];
              return _HeroSlideView(
                slide: slide,
                isHovered: _isHovered,
                onHoverChanged: (v) => setState(() => _isHovered = v),
              );
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

class _HeroSlideView extends StatelessWidget {
  final HeroSlide slide;
  final bool isHovered;
  final ValueChanged<bool> onHoverChanged;

  const _HeroSlideView({
    required this.slide,
    required this.isHovered,
    required this.onHoverChanged,
  });

  @override
  Widget build(BuildContext context) {
    final info = _HeroAlignmentInfo.from(slide.align);

    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: Image.asset(slide.image, fit: BoxFit.cover),
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
        Positioned(
          left: 60,
          right: 60,
          top: 0,
          bottom: 0,
          child: Align(
            alignment: info.boxAlignment,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: info.crossAlign,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    slide.headline,
                    textAlign: info.textAlign,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    slide.subtext,
                    textAlign: info.textAlign,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 35),
                  MouseRegion(
                    onEnter: (_) => onHoverChanged(true),
                    onExit: (_) => onHoverChanged(false),
                    child: AnimatedScale(
                      scale: isHovered ? 1.005 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: ElevatedButton(
                        onPressed: () {
                          // Add your navigation logic here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isHovered
                              ? const Color.fromRGBO(255, 181, 40, 1)
                              : const Color.fromRGBO(245, 171, 30, 1),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: isHovered ? 8 : 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Explore Collection",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 10),
                            AnimatedRotation(
                              duration: const Duration(milliseconds: 300),
                              turns: isHovered ? 0.125 : 0.0,
                              child: const Icon(
                                Icons.arrow_forward,
                                size: 18,
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
        ),
      ],
    );
  }
}