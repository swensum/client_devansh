import 'dart:async';
import 'package:devansh/widgets/app_page_scaffold_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:go_router/go_router.dart';

import 'package:devansh/models/blogmodel.dart';
import 'package:devansh/services/blogservice.dart';
import 'package:devansh/widgets/blogwidgets.dart';
import 'package:devansh/components/header.dart';
import 'package:devansh/components/footer.dart';
import 'package:devansh/components/topbar.dart';

MarkdownStyleSheet _blogMarkdownStyleSheet() {
  final bodyColor = Colors.white.withValues(alpha: 0.72);
  const bodySize = 15.5;
  const bodyHeight = 1.8;

  return MarkdownStyleSheet(
    h1: const TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      height: 1.4,
    ),
    h2: const TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      height: 1.4,
    ),
    h3: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: Colors.white.withValues(alpha: 0.92),
      height: 1.4,
    ),
    h4: TextStyle(
      fontSize: bodySize,
      fontWeight: FontWeight.w700,
      color: Colors.white.withValues(alpha: 0.88),
    ),
    p: TextStyle(
      fontSize: bodySize,
      height: bodyHeight,
      fontWeight: FontWeight.w400,
      color: bodyColor,
    ),
    strong: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
    em: TextStyle(fontStyle: FontStyle.italic, color: bodyColor),
    listBullet: TextStyle(
      fontSize: bodySize,
      height: bodyHeight,
      color: kBlogAccent,
    ),
    listIndent: 20,
    blockSpacing: 18,
    horizontalRuleDecoration: BoxDecoration(
      border: Border(
        top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
    ),
    blockquote: TextStyle(
      fontSize: bodySize,
      fontStyle: FontStyle.italic,
      color: Colors.white.withValues(alpha: 0.6),
    ),
    blockquoteDecoration: BoxDecoration(
      border: Border(left: BorderSide(color: kBlogAccent, width: 3)),
    ),
    blockquotePadding: const EdgeInsets.only(left: 16),
    a: const TextStyle(
      color: kBlogAccent,
      decoration: TextDecoration.underline,
    ),
  );
}

class BlogDetailPage extends StatefulWidget {
  final String slug;
  const BlogDetailPage({super.key, required this.slug});

  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  final BlogService _blogService = BlogService();

  BlogPost? _post;
  bool _loading = true;
  bool _notFound = false;

  List<BlogPost> _recentPosts = [];
  StreamSubscription<List<BlogPost>>? _recentSub;

  @override
  void initState() {
    super.initState();
    _load();
    _recentSub = _blogService.watchPublishedPosts().listen((data) {
      if (!mounted) return;
      setState(() {
        _recentPosts = data
            .where((p) => p.slug != widget.slug)
            .take(5)
            .toList();
      });
    });
  }

  @override
  void didUpdateWidget(covariant BlogDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug) {
      setState(() {
        _loading = true;
        _notFound = false;
        _post = null;
      });
      _load();
    }
  }

  @override
  void dispose() {
    _recentSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final post = await _blogService.getPostBySlug(widget.slug);
    if (!mounted) return;
    setState(() {
      _post = post;
      _notFound = post == null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      body: Container(
        color: const Color(0xFF0F0F0F),
        child: Column(
          children: [
            SizedBox(height: Header.height + TopBar.height),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 140),
                child: CircularProgressIndicator(color: kBlogAccent),
              )
            else if (_notFound)
              _buildNotFound(context)
            else
              _buildContent(context, _post!),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
      child: Column(
        children: [
          Text(
            "Post not found",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "This post may have been removed or unpublished.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          _BackToBlogLink(onTap: () => context.go('/blog')),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, BlogPost post) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BackToBlogLink(onTap: () => context.go('/blog')),
              const SizedBox(height: 20),

              // ── Cover image (left) + Recent Blogs rail (right) ──────
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;

                  final image = _CoverImage(post: post);
                  final recent = _RecentBlogsPanel(
                    posts: _recentPosts,
                    onTapPost: (p) => context.go('/blog/${p.slug}'),
                  );

                  if (isWide) {
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 7, child: image),
                          const SizedBox(width: 28),
                          Expanded(flex: 3, child: recent),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [image, const SizedBox(height: 28), recent],
                  );
                },
              ),

              const SizedBox(height: 40),

              // ── Post details ─────────────────────────────────────────
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: kBlogAccent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        post.category,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatBlogDate(post.createdAt),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    const SizedBox(height: 28),

                    if ((post.excerpt ?? '').isNotEmpty) ...[
                      Text(
                        post.excerpt!,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.6,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    MarkdownBody(
                      data: post.content ?? '',
                      shrinkWrap: true,
                      styleSheet: _blogMarkdownStyleSheet(),
                    ),

                    if (post.faqs.isNotEmpty) ...[
                      const SizedBox(height: 44),
                      Container(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      const SizedBox(height: 36),
                      const Text(
                        "Frequently Asked Questions",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _FaqList(faqs: post.faqs),
                    ],

                    const SizedBox(height: 60),
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

class _CoverImage extends StatelessWidget {
  final BlogPost post;
  const _CoverImage({required this.post});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: post.coverImage != null
          ? Image.network(
              post.coverImage!,
              fit: BoxFit.fitWidth, // width fills, height adjusts naturally
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.white.withValues(alpha: 0.06),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: 36,
        color: Colors.white.withValues(alpha: 0.25),
      ),
    );
  }
}

/// Sidebar next to the cover image: "Recent Blogs" title + a compact list of
/// other posts (small thumbnail + title only, no excerpt/date).
class _RecentBlogsPanel extends StatelessWidget {
  final List<BlogPost> posts;
  final void Function(BlogPost post) onTapPost;

  const _RecentBlogsPanel({required this.posts, required this.onTapPost});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Blogs",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          if (posts.isEmpty)
            Text(
              "No other posts yet.",
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            )
          else
            ...posts.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _RecentBlogRow(post: p, onTap: () => onTapPost(p)),
              ),
            ),
        ],
      ),
    );
  }
}

class _FaqList extends StatelessWidget {
  final List<BlogFaq> faqs;
  const _FaqList({required this.faqs});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < faqs.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == faqs.length - 1 ? 0 : 12),
            child: _FaqTile(faq: faqs[i]),
          ),
      ],
    );
  }
}

class _FaqTile extends StatefulWidget {
  final BlogFaq faq;
  const _FaqTile({required this.faq});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _isOpen = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _isOpen || _isHovered
                ? kBlogAccent
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _isOpen = !_isOpen),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        widget.faq.question,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: _isOpen ? kBlogAccent : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: _isOpen ? 0.5 : 0.0,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: _isOpen ? kBlogAccent : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _isOpen
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                child: Text(
                  widget.faq.answer,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.7,
                    color: Colors.white.withValues(alpha: 0.68),
                  ),
                ),
              ),
              secondChild: const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentBlogRow extends StatefulWidget {
  final BlogPost post;
  final VoidCallback onTap;
  const _RecentBlogRow({required this.post, required this.onTap});

  @override
  State<_RecentBlogRow> createState() => _RecentBlogRowState();
}

class _RecentBlogRowState extends State<_RecentBlogRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 52,
                height: 52,
                child: post.coverImage != null
                    ? Image.network(
                        post.coverImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      )
                    : Container(color: Colors.white.withValues(alpha: 0.06)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: _isHovered
                      ? kBlogAccent
                      : Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackToBlogLink extends StatefulWidget {
  final VoidCallback onTap;
  const _BackToBlogLink({required this.onTap});

  @override
  State<_BackToBlogLink> createState() => _BackToBlogLinkState();
}

class _BackToBlogLinkState extends State<_BackToBlogLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back,
              size: 15,
              color: _isHovered ? kBlogAccent : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              "Back to Blog",
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: _isHovered ? kBlogAccent : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
