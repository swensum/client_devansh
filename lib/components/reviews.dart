import 'dart:async';
import 'package:devansh/models/reviewmodel.dart';
import 'package:devansh/services/reviewservice.dart';
import 'package:flutter/material.dart';

class ReviewsSection extends StatefulWidget {
  const ReviewsSection({super.key});

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}


class _ReviewsSectionState extends State<ReviewsSection> {
  final ReviewService _reviewService = ReviewService();
  List<Review> _reviews = [];
  StreamSubscription<List<Review>>? _reviewsSub;

  static const int _initialPage = 10000;
  late PageController _pageController;
  int _pageCounter = _initialPage;
  Timer? _autoScrollTimer;
  int _controllerVisibleCount = 1;
  bool _pendingRebuild = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage, viewportFraction: 1);
    _startAutoScroll();
    _reviewsSub = _reviewService.watchReviews().listen((data) {
      if (mounted) setState(() => _reviews = data);
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _reviewsSub?.cancel();
    super.dispose();
  }


  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _goToPage(_pageCounter + 1);
    });
  }

  void _goToPage(int page) {
    if (!_pageController.hasClients) return;
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  void _handleNext() {
    _autoScrollTimer?.cancel();
    _goToPage(_pageCounter + 1);
    _startAutoScroll();
  }

  void _handlePrevious() {
    _autoScrollTimer?.cancel();
    _goToPage(_pageCounter - 1);
    _startAutoScroll();
  }

  void _rebuildControllerFor(int visibleCount) {
    if (_pendingRebuild || visibleCount == _controllerVisibleCount) return;
    _pendingRebuild = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final oldController = _pageController;
      setState(() {
        _controllerVisibleCount = visibleCount;
        _pageController = PageController(
          initialPage: _pageCounter,
          viewportFraction: 1 / visibleCount,
        );
      });
      oldController.dispose();
      _pendingRebuild = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final r = _ReviewsResponsive.of(constraints.maxWidth);
        _rebuildControllerFor(r.visibleCount);

        return Container(
          width: double.infinity,
          color: Colors.black,
          padding: EdgeInsets.symmetric(
            horizontal: r.sectionHPadding,
            vertical: r.sectionVPadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Section Title
                  Text(
                    "What Our Customers Say",
                    style: TextStyle(
                      fontSize: r.headingSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.1,
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
                    "Real feedback from people who trust our hardware",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: r.subtitleSize,
                      color: Colors.white.withValues(alpha: 0.6),
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(height: r.headerGap),

                  // Carousel row: left arrow — review cards — right arrow
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (r.showArrows) ...[
                        _NavArrowButton(
                          icon: Icons.keyboard_double_arrow_left,
                          onTap: _handlePrevious,
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
  child: SizedBox(
    height: r.cardHeight,
    child: _reviews.isEmpty
        ? const Center(
            child: Text(
              "No reviews yet.",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          )
        : _controllerVisibleCount == r.visibleCount
            ? PageView.builder(
                controller: _pageController,
                padEnds: false,
                onPageChanged: (index) {
                  setState(() {
                    _pageCounter = index;
                  });
                },
                itemBuilder: (context, index) {
                  final review = _reviews[index % _reviews.length];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.cardHGap,
                    ),
                    child: _ReviewCard(review: review, r: r),
                  );
                },
              )
            : const SizedBox.shrink(),
  ),
),
                      if (r.showArrows) ...[
                        const SizedBox(width: 12),
                        _NavArrowButton(
                          icon: Icons.keyboard_double_arrow_right,
                          onTap: _handleNext,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReviewsResponsive {
  final int visibleCount;
  final double cardHeight;
  final double cardHGap;
  final double sectionHPadding;
  final double sectionVPadding;
  final double headingSize;
  final double subtitleSize;
  final double headerGap;
  final double cardPadding;
  final double cardMessageFont;
  final bool showArrows;

  const _ReviewsResponsive({
    required this.visibleCount,
    required this.cardHeight,
    required this.cardHGap,
    required this.sectionHPadding,
    required this.sectionVPadding,
    required this.headingSize,
    required this.subtitleSize,
    required this.headerGap,
    required this.cardPadding,
    required this.cardMessageFont,
    required this.showArrows,
  });

  factory _ReviewsResponsive.of(double w) {
    if (w > 1000) {
      return const _ReviewsResponsive(
        visibleCount: 4,
        cardHeight: 300,
        cardHGap: 15,
        sectionHPadding: 30,
        sectionVPadding: 80,
        headingSize: 30,
        subtitleSize: 14,
        headerGap: 60,
        cardPadding: 20,
        cardMessageFont: 13.5,
        showArrows: true,
      );
    }
    if (w > 700) {
      return const _ReviewsResponsive(
        visibleCount: 2,
        cardHeight: 280,
        cardHGap: 12,
        sectionHPadding: 24,
        sectionVPadding: 60,
        headingSize: 26,
        subtitleSize: 13.5,
        headerGap: 44,
        cardPadding: 18,
        cardMessageFont: 13,
        showArrows: true,
      );
    }
    if (w > 420) {
      return const _ReviewsResponsive(
        visibleCount: 1,
        cardHeight: 260,
        cardHGap: 8,
        sectionHPadding: 18,
        sectionVPadding: 48,
        headingSize: 22,
        subtitleSize: 13,
        headerGap: 32,
        cardPadding: 16,
        cardMessageFont: 13,
        showArrows: true,
      );
    }
    return const _ReviewsResponsive(
      visibleCount: 1,
      cardHeight: 280,
      cardHGap: 4,
      sectionHPadding: 12,
      sectionVPadding: 36,
      headingSize: 19,
      subtitleSize: 12,
      headerGap: 24,
      cardPadding: 14,
      cardMessageFont: 12.5,
      // Arrows plus a single narrow card leaves almost no room; swiping
      // and autoplay still work without them.
      showArrows: false,
    );
  }
}

class _NavArrowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavArrowButton({required this.icon, required this.onTap});

  @override
  State<_NavArrowButton> createState() => _NavArrowButtonState();
}

class _NavArrowButtonState extends State<_NavArrowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _isHovered
                ? const Color.fromRGBO(245, 171, 30, 1)
                : Colors.white.withValues(alpha: 0.08),
            shape: BoxShape.circle,
            border: Border.all(
              color: _isHovered
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: Icon(
            widget.icon,
            size: 22,
            color: _isHovered ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatefulWidget {
  final Review review;
  final _ReviewsResponsive r;

  const _ReviewCard({required this.review, required this.r});

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.r;
    final initial = widget.review.name.isNotEmpty
        ? widget.review.name[0].toUpperCase()
        : "?";

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.all(r.cardPadding),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? const Color.fromRGBO(245, 171, 30, 0.7)
                : Colors.grey.shade200,
            width: _isHovered ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.10 : 0.04),
              blurRadius: _isHovered ? 16 : 6,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quote icon
            const Icon(
              Icons.format_quote,
              color: Color.fromARGB(186, 245, 170, 30),
              size: 28,
            ),
            const SizedBox(height: 10),

            // Review message
            Expanded(
              child: Text(
                widget.review.message,
                style: TextStyle(
                  fontSize: r.cardMessageFont,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Star rating
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  Icons.star,
                  size: 15,
                  color: i < widget.review.rating
                      ? const Color.fromRGBO(245, 171, 30, 1)
                      : Colors.grey.shade300,
                );
              }),
            ),
            const SizedBox(height: 14),

            // Reviewer info
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color.fromRGBO(245, 171, 30, 1),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.review.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        widget.review.role,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}