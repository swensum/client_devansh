import 'dart:async';
import 'package:flutter/material.dart';

class ReviewsSection extends StatefulWidget {
  const ReviewsSection({super.key});

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _Review {
  final String name;
  final String role;
  final String message;
  final int rating;

  const _Review({
    required this.name,
    required this.role,
    required this.message,
    required this.rating,
  });
}

class _ReviewsSectionState extends State<ReviewsSection> {
  static const List<_Review> _reviews = [
    _Review(
      name: "Ramesh Karki",
      role: "Interior Designer",
      message:
          "The build quality of these cabinet handles is outstanding. "
          "Clients always compliment the finish after installation.",
      rating: 5,
    ),
    _Review(
      name: "Sita Sharma",
      role: "Homeowner",
      message:
          "Ordered a full set of door fittings for our new house. "
          "Everything arrived on time and matched perfectly.",
      rating: 5,
    ),
    _Review(
      name: "Anil Gurung",
      role: "Contractor",
      message:
          "Reliable supplier for hardware on every project. "
          "The soft-close hinges especially have held up really well.",
      rating: 4,
    ),
    _Review(
      name: "Priya Thapa",
      role: "Homeowner",
      message:
          "Loved the matte black collection. Easy to install and "
          "looks a lot more premium than the price suggests.",
      rating: 5,
    ),
    _Review(
      name: "Bikash Adhikari",
      role: "Furniture Maker",
      message:
          "Consistent quality across every batch we've ordered. "
          "It's become our go-to source for premium hardware.",
      rating: 5,
    ),
  ];

  // Unbounded page counter — always increases, so auto-rotation only
  // ever moves in one direction (same technique as the hero carousel).
  static const int _initialPage = 10000;
  late final PageController _pageController;
  int _pageCounter = _initialPage;
  Timer? _autoScrollTimer;

  // How many cards are visible at once — 4 on desktop, fewer on
  // narrower screens. viewportFraction is fixed per PageController,
  // so we pick this once based on screen width.
  int _visibleCount = 4;

  @override
  void initState() {
    super.initState();
    final width = WidgetsBinding.instance.platformDispatcher.views.first
            .physicalSize.width /
        WidgetsBinding.instance.platformDispatcher.views.first
            .devicePixelRatio;

    if (width < 700) {
      _visibleCount = 1;
    } else if (width < 1000) {
      _visibleCount = 2;
    } else {
      _visibleCount = 4;
    }

    _pageController = PageController(
      initialPage: _initialPage,
      viewportFraction: 1 / _visibleCount,
    );
    _startAutoScroll();
  }

  void _startAutoScroll() {
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

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Section Title
              const Text(
                "What Our Customers Say",
                style: TextStyle(
                  fontSize: 30,
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
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 60),

              // Carousel row: left arrow — 4 review cards — right arrow
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _NavArrowButton(
                    icon: Icons.keyboard_double_arrow_left,
                    onTap: _handlePrevious,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 300,
                      child: PageView.builder(
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                            ),
                            child: _ReviewCard(review: review),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _NavArrowButton(
                    icon: Icons.keyboard_double_arrow_right,
                    onTap: _handleNext,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
                : Colors.white.withOpacity(0.08),
            shape: BoxShape.circle,
            border: Border.all(
              color: _isHovered
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.2),
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

// Unchanged from the original design
class _ReviewCard extends StatefulWidget {
  final _Review review;

  const _ReviewCard({required this.review});

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final initial = widget.review.name.isNotEmpty
        ? widget.review.name[0].toUpperCase()
        : "?";

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? const Color.fromRGBO(245, 171, 30, 0.7)
                : Colors.grey.shade200,
            width: _isHovered ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.10 : 0.04),
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
                style: const TextStyle(
                  fontSize: 13.5,
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
                          color: Colors.white.withOpacity(0.6),
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