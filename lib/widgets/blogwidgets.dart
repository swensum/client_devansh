import 'package:devansh/models/blogmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const Color kBlogAccent = Color.fromRGBO(245, 171, 30, 1);

const List<String> _kMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatBlogDate(DateTime? date) {
  if (date == null) return '';
  return '${date.day.toString().padLeft(2, '0')} ${_kMonths[date.month - 1]} ${date.year}';
}

class BlogGrid extends StatelessWidget {
  final List<BlogPost> posts;
  const BlogGrid({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width > 900 ? 3 : (width > 600 ? 2 : 1);
        const spacing = 24.0;
        final cardWidth = (width - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: posts
              .map(
                (post) => SizedBox(
                  width: cardWidth,
                  child: BlogPostCard(post: post),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class BlogPostCard extends StatefulWidget {
  final BlogPost post;
  const BlogPostCard({super.key, required this.post});

  @override
  State<BlogPostCard> createState() => _BlogPostCardState();
}

class _BlogPostCardState extends State<BlogPostCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.push('/blog/${post.slug}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isHovered
                  ? kBlogAccent
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                child: AspectRatio(
                  aspectRatio: 15 / 10,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AnimatedScale(
                        duration: const Duration(milliseconds: 250),
                        scale: _isHovered ? 1.06 : 1.0,
                        child: post.coverImage != null
                            ? Image.network(
                                post.coverImage!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _imagePlaceholder(),
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return _imagePlaceholder();
                                },
                              )
                            : _imagePlaceholder(),
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
                            color: kBlogAccent,
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
                          formatBlogDate(post.createdAt),
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
                        color: _isHovered ? kBlogAccent : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      post.excerpt ?? '',
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
                            color: _isHovered ? kBlogAccent : Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 6),
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 200),
                          turns: _isHovered ? 0.125 : 0.0,
                          child: Icon(
                            Icons.arrow_forward,
                            size: 15,
                            color: _isHovered ? kBlogAccent : Colors.white70,
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

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.white.withValues(alpha: 0.06),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: 28,
        color: Colors.white.withValues(alpha: 0.25),
      ),
    );
  }
}
