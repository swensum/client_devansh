import 'package:flutter/material.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({super.key});

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
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Section Title
              Text(
                "What Our Customers Say",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[900],
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                width: 50,
                height: 3,
                color: const Color.fromRGBO(245, 171, 30, 1),
              ),
              const SizedBox(height: 12),

              Text(
                "Real feedback from people who trust our hardware",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blueGrey[700],
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 40),

              // Review Grid — responsive column count
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 950
                      ? 4
                      : constraints.maxWidth > 620
                          ? 2
                          : 1;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _reviews.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (context, index) {
                      return _ReviewCard(review: _reviews[index]);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
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
          color: Colors.white,
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
            Icon(
              Icons.format_quote,
              color: const Color.fromRGBO(245, 171, 30, 0.5),
              size: 28,
            ),
            const SizedBox(height: 10),

            // Review message
            Expanded(
              child: Text(
                widget.review.message,
                style: TextStyle(
                  fontSize: 13.5,
                  color: Colors.blueGrey[800],
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
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey[900],
                        ),
                      ),
                      Text(
                        widget.review.role,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
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