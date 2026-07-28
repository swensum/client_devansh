import 'dart:async';
import 'package:devansh/models/blogmodel.dart';
import 'package:devansh/widgets/blogwidgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:devansh/services/blogservice.dart';

class BlogSection extends StatefulWidget {
  const BlogSection({super.key});

  @override
  State<BlogSection> createState() => _BlogSectionState();
}

class _BlogSectionState extends State<BlogSection> {
  static const int _maxPosts = 3;

  bool _isDisposed = false;
  final BlogService _blogService = BlogService();
  List<BlogPost> _posts = [];
  int _totalCount = 0;
  bool _loading = true;
  StreamSubscription<List<BlogPost>>? _postsSub;

  @override
  void initState() {
    super.initState();
    _postsSub = _blogService.watchPublishedPosts().listen((data) {
      if (!_isDisposed) {
        setState(() {
          _posts = data.take(_maxPosts).toList();
          _totalCount = data.length;
          _loading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _postsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Nothing published yet (and we're done loading) — skip the section
    // entirely rather than showing an empty block on the homepage.
    if (!_loading && _posts.isEmpty) {
      return const SizedBox.shrink();
    }

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
              const Text(
                "From Our Blog",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Container(height: 3, width: 60, color: kBlogAccent),
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
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: CircularProgressIndicator(color: kBlogAccent),
                )
              else ...[
                BlogGrid(posts: _posts),
                if (_totalCount > _maxPosts) ...[
                  const SizedBox(height: 36),
                  _SeeMoreButton(onTap: () => context.push('/blog')),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SeeMoreButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SeeMoreButton({required this.onTap});

  @override
  State<_SeeMoreButton> createState() => _SeeMoreButtonState();
}

class _SeeMoreButtonState extends State<_SeeMoreButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
          decoration: BoxDecoration(
            color: _isHovered ? kBlogAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: kBlogAccent, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "See More",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _isHovered ? Colors.black : kBlogAccent,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: _isHovered ? 0.125 : 0.0,
                child: Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: _isHovered ? Colors.black : kBlogAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}