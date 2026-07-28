import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BlogSection extends StatelessWidget {
  const BlogSection({super.key});

  static const _accent = Color.fromRGBO(245, 171, 30, 1);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F0F0F),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 70),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "From Our Blog",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Container(height: 3, width: 60, color: _accent),
              const SizedBox(height: 14),
              Text(
                "Tips, trends, and stories from the world of premium hardware.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 44),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final columns = width > 900 ? 3 : (width > 600 ? 2 : 1);
                  final spacing = 24.0;
                  final cardWidth =
                      (width - spacing * (columns - 1)) / columns;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: _kPosts
                        .map(
                          (post) => SizedBox(
                            width: cardWidth,
                            child: _BlogCard(post: post),
                          ),
                        )
                        .toList(),
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

class _BlogPost {
  final String image;
  final String category;
  final String date;
  final String title;
  final String excerpt;
  final String? route;

  const _BlogPost({
    required this.image,
    required this.category,
    required this.date,
    required this.title,
    required this.excerpt,
    this.route,
  });
}

const List<_BlogPost> _kPosts = [
  _BlogPost(
    image: 'assets/port.jpg',
    category: "Buying Guide",
    date: "12 Jul 2026",
    title: "How to Choose the Right Cabinet Handles for Your Kitchen",
    excerpt:
        "From finish to grip style, here's what actually matters when "
        "picking hardware that lasts.",
  ),
  _BlogPost(
    image: 'assets/port2.png',
    category: "Trends",
    date: "28 Jun 2026",
    title: "Matte Black Is Still Having a Moment — Here's Why",
    excerpt:
        "A look at why matte-black fittings continue to dominate modern "
        "interior design.",
  ),
  _BlogPost(
    image: 'assets/port3.png',
    category: "Maintenance",
    date: "05 Jun 2026",
    title: "Simple Habits That Keep Your Door Hardware Looking New",
    excerpt:
        "A few minutes of care every month is all it takes to protect your "
        "investment.",
  ),
];

class _BlogCard extends StatefulWidget {
  final _BlogPost post;
  const _BlogCard({required this.post});

  @override
  State<_BlogCard> createState() => _BlogCardState();
}

class _BlogCardState extends State<_BlogCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          if (post.route != null) context.push(post.route!);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isHovered
                  ? BlogSection._accent
                  : Colors.white.withValues(alpha: 0.08),
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AnimatedScale(
                        duration: const Duration(milliseconds: 250),
                        scale: _isHovered ? 1.06 : 1.0,
                        child: Image.asset(post.image, fit: BoxFit.cover),
                      ),
                      Positioned(
                        left: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: BlogSection._accent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            post.category,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          post.date,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                        color: _isHovered ? BlogSection._accent : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      post.excerpt,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.5,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          "Read More",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _isHovered
                                ? BlogSection._accent
                                : Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 6),
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 200),
                          turns: _isHovered ? 0.125 : 0.0,
                          child: Icon(
                            Icons.arrow_forward,
                            size: 15,
                            color: _isHovered
                                ? BlogSection._accent
                                : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}