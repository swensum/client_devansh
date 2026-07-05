import 'package:devansh/components/about.dart';
import 'package:devansh/components/categories.dart';
import 'package:devansh/components/header.dart';
import 'package:devansh/components/stat.dart';

import 'package:flutter/material.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// Where the text block sits over the image
enum HeroTextAlign { left, right, center }

// Bundles everything that changes per-slide together
class _HeroSlide {
  final String image;
  final String headline;
  final String subtext;
  final HeroTextAlign align;

  const _HeroSlide({
    required this.image,
    required this.headline,
    required this.subtext,
    this.align = HeroTextAlign.left,
  });
}

class _HomePageState extends State<HomePage> {
  bool _isHovered = false;

  final List<_HeroSlide> _slides = const [
    _HeroSlide(
      image: 'assets/port.jpg',
      headline: "Elevate Every Space with Premium Cabinet Handles",
      subtext:
          "Discover modern, durable, and elegant cabinet & door handles "
          "crafted to complement every interior.",
      align: HeroTextAlign.left,
    ),
    _HeroSlide(
      image: 'assets/port2.png',
      headline: "Timeless Design Meets Everyday Durability",
      subtext:
          "Designed for modern homes and premium spaces, our aldrops deliver "
          "reliable protection with a refined matte-black aesthetic.",
      align: HeroTextAlign.right, // product sits on the left in this image
    ),
    _HeroSlide(
      image: 'assets/port3.png',
      headline: "Crafted Details, Built to Impress",
      subtext:
          "A collection of fittings and finishes designed to bring "
          "precision and character to every corner of your home.",
      align: HeroTextAlign.center,
    ),
  ];

  // Large arbitrary starting page — lets us always scroll forward
  // (incrementing) without ever needing to jump back to a lower index.
  static const int _initialPage = 10000;

  late final PageController _pageController;
  int _currentIndex = 0; // real slide index (wrapped), used for dots/text
  int _pageCounter = _initialPage; // raw page number, always increasing
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_pageController.hasClients) return;
      _pageCounter++; // always moves forward, never resets to 0
      _pageController.animateToPage(
        _pageCounter,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            const Header(),

            // Top Hero Carousel Section
            AspectRatio(
              aspectRatio: 16 / 8,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: null, // unbounded — always scrolls forward
                    onPageChanged: (index) {
                      setState(() {
                        _pageCounter = index;
                        _currentIndex =
                            index % _slides.length; // wraps 0,1,2,0,1,2...
                      });
                    },
                    itemBuilder: (context, index) {
                      final slide = _slides[index % _slides.length];

                      // Derive alignment/gradient/text-align from the enum
                      late final Alignment boxAlignment;
                      late final CrossAxisAlignment crossAlign;
                      late final TextAlign textAlign;
                      late final Alignment gradientBegin;
                      late final Alignment gradientEnd;

                      switch (slide.align) {
                        case HeroTextAlign.left:
                          boxAlignment = Alignment.centerLeft;
                          crossAlign = CrossAxisAlignment.start;
                          textAlign = TextAlign.left;
                          gradientBegin = Alignment.centerLeft;
                          gradientEnd = Alignment.centerRight;
                          break;
                        case HeroTextAlign.right:
                          boxAlignment = Alignment.centerRight;
                          crossAlign = CrossAxisAlignment.end;
                          textAlign = TextAlign.right;
                          gradientBegin = Alignment.centerRight;
                          gradientEnd = Alignment.centerLeft;
                          break;
                        case HeroTextAlign.center:
                          boxAlignment = Alignment.center;
                          crossAlign = CrossAxisAlignment.center;
                          textAlign = TextAlign.center;
                          gradientBegin = Alignment.center;
                          gradientEnd = Alignment.center;
                          break;
                      }

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background image for this slide
                          Image.asset(slide.image, fit: BoxFit.cover),

                          // Overlay — side gradient for left/right slides,
                          // even darkening for center slides so the text
                          // stays readable regardless of what's behind it.
                          if (slide.align == HeroTextAlign.center)
                            Container(color: Colors.black.withOpacity(0.4))
                          else
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: gradientBegin,
                                  end: gradientEnd,
                                  colors: [
                                    Colors.black.withOpacity(0.55),
                                    Colors.black.withOpacity(0.0),
                                  ],
                                  stops: const [0.0, 0.7],
                                ),
                              ),
                            ),

                          // Text content — changes per slide, and
                          // repositions based on slide.align
                          Positioned(
                            left: 60,
                            right: 60,
                            top: 0,
                            bottom: 0,
                            child: Align(
                              alignment: boxAlignment,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 520,
                                ),
                                child: Column(
                                  crossAxisAlignment: crossAlign,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // AnimatedSwitcher gives a smooth fade
                                    // when the text itself changes
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      child: Text(
                                        slide.headline,
                                        key: ValueKey<String>(slide.headline),
                                        textAlign: textAlign,
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          height: 1.25,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      child: Text(
                                        slide.subtext,
                                        key: ValueKey<String>(slide.subtext),
                                        textAlign: textAlign,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white.withOpacity(0.9),
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 35),

                                    // Hover animation wrapper
                                    MouseRegion(
                                      onEnter: (_) =>
                                          setState(() => _isHovered = true),
                                      onExit: (_) =>
                                          setState(() => _isHovered = false),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        transform: Matrix4.identity()
                                          ..scale(_isHovered ? 1.05 : 1.0),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Add your navigation logic here
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _isHovered
                                                ? const Color.fromRGBO(
                                                    255,
                                                    181,
                                                    40,
                                                    1,
                                                  )
                                                : const Color.fromRGBO(
                                                    245,
                                                    171,
                                                    30,
                                                    1,
                                                  ),
                                            foregroundColor: Colors.black,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 28,
                                              vertical: 18,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            elevation: _isHovered ? 8 : 2,
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
                                                duration: const Duration(
                                                  milliseconds: 300,
                                                ),
                                                turns: _isHovered ? 0.125 : 0.0,
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
                    },
                  ),

                  // Dot indicators
                  Positioned(
                    bottom: 20,
                    right: 30,
                    child: Row(
                      children: List.generate(_slides.length, (i) {
                        final isActive = i == _currentIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color.fromRGBO(245, 171, 30, 1)
                                : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              height: 2,
              color: const Color.fromRGBO(245, 171, 30, 1),
            ),

            const StatsSection(),
            Container(
              width: double.infinity,
              height: 2,
              color: const Color.fromRGBO(245, 171, 30, 1),
            ),
            const AboutSection(),
            Container(
              width: double.infinity,
              height: 2,
              color: const Color.fromRGBO(245, 171, 30, 1),
            ),
            const CategoriesSection(),
          ],
        ),
      ),
    );
  }
}
