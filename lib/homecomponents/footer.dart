import 'dart:async';

import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/link.dart';
import 'package:web/web.dart' as web;

import 'package:devansh/models/catalogmodels.dart';
import 'package:devansh/services/catalogservice.dart';

class Footer extends StatefulWidget {
  const Footer({super.key});

  static const _accent = Color.fromRGBO(245, 171, 30, 1);

  static const List<_FooterLink> _quickLinks = [
    _FooterLink(label: "About Us", route: "/about"),
    _FooterLink(label: "Products", route: "/products"),
    _FooterLink(label: "Blogs", route: "/blog"),
    _FooterLink(label: "Contact", route: "/contact"),
  ];

  static const List<_SocialIconData> _socials = [
    _SocialIconData(
      icon: FontAwesomeIcons.facebookF,
      url: "https://facebook.com/devanshhardware",
    ),
    _SocialIconData(
      icon: FontAwesomeIcons.instagram,
      url: "https://instagram.com/devanshhardware",
    ),
    _SocialIconData(
      icon: FontAwesomeIcons.whatsapp,
      url: "https://wa.me/9779857033614",
    ),
    _SocialIconData(
      icon: FontAwesomeIcons.tiktok,
      url: "https://tiktok.com/@devanshhardware",
    ),
  ];

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  bool _isDisposed = false;
  final CatalogService _catalogService = CatalogService();
  List<Category> _categories = [];
  StreamSubscription<List<Category>>? _categoriesSub;

  @override
  void initState() {
    super.initState();
    _categoriesSub = _catalogService.watchCategories().listen((data) {
      if (!_isDisposed) setState(() => _categories = data);
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _categoriesSub?.cancel();
    super.dispose();
  }

  static const int _categoriesPerColumn = 6;

  List<_FooterLink> get _categoryLinks => _categories
      .map(
        (c) => _FooterLink(label: c.name, route: '/products?category=${c.id}'),
      )
      .toList();

  List<List<_FooterLink>> get _categoryColumns {
    final links = _categoryLinks;
    final columns = <List<_FooterLink>>[];
    for (var i = 0; i < links.length; i += _categoriesPerColumn) {
      final end = (i + _categoriesPerColumn < links.length)
          ? i + _categoriesPerColumn
          : links.length;
      columns.add(links.sublist(i, end));
    }
    return columns.isEmpty ? [[]] : columns;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 800;

                    final brand = _buildBrandColumn();
                    final quick = _buildLinkColumn(
                      "Quick Links",
                      Footer._quickLinks,
                    );
                    final categoryColumns = _categoryColumns;
                    final categories = _buildCategoriesSection(categoryColumns);
                    final contact = _buildContactColumn();

                    if (isWide) {
                      // Give the categories block more room as it grows extra columns,
                      // but cap it so it doesn't crowd out the other columns when
                      // there are many category columns.
                      final categoriesFlex = (2 * categoryColumns.length).clamp(
                        2,
                        6,
                      );
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: brand),
                          const SizedBox(width: 32),
                          Expanded(flex: 2, child: quick),
                          const SizedBox(width: 32),
                          Expanded(flex: categoriesFlex, child: categories),
                          const SizedBox(width: 32),
                          Expanded(flex: 3, child: contact),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        brand,
                        const SizedBox(height: 36),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: quick),
                            const SizedBox(width: 24),
                            Expanded(flex: 4, child: categories),
                          ],
                        ),
                        const SizedBox(height: 36),
                        contact,
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 700;
                    final copyright = Text(
                      "© ${DateTime.now().year} Devansh Hardware. All rights reserved.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    );
                    final legalLinks = Wrap(
                      spacing: 20,
                      children: const [
                        _LegalLink(label: "Privacy Policy", route: "/privacy"),
                        _LegalLink(label: "Terms of Service", route: "/terms"),
                      ],
                    );

                    return isWide
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [copyright, legalLinks],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              copyright,
                              const SizedBox(height: 10),
                              legalLinks,
                            ],
                          );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandColumn() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Logo instead of text ────────────────────────────────
          Image.asset(
            'assets/logo.png', // <── your logo asset path
            height: 60, // adjust as needed
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 14),
          Text(
            "Premium cabinet and door hardware crafted for modern homes "
            "and everyday durability.",
            style: TextStyle(
              fontSize: 13.5,
              height: 1.6,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: Footer._socials
                .map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _SocialIcon(icon: s.icon, url: s.url),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkColumn(String title, List<_FooterLink> links) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          ...links.map(
            (link) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FooterLinkText(label: link.label, route: link.route),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(List<List<_FooterLink>> columns) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Categories",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              for (final column in columns)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final link in column)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _FooterLinkText(
                          label: link.label,
                          route: link.route,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactColumn() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Contact",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 16),
          _ContactRow(
            icon: Icons.location_on_outlined,
            text: "Sukhanagar(Old Napi Office),Butwal,Nepal",
          ),
          SizedBox(height: 14),
          _ContactRow(
            icon: Icons.phone_outlined,
            text: "+977 9857033614, +977 9857081383",
          ),
          SizedBox(height: 14),
          _ContactRow(
            icon: Icons.email_outlined,
            text: "info@devanshhardware.com",
          ),
          SizedBox(height: 14),
          _ContactRow(
            icon: Icons.access_time,
            text: "Sun - Fri (10 AM to 6 PM)",
          ),
        ],
      ),
    );
  }
}

class _FooterLink {
  final String label;
  final String? route;
  const _FooterLink({required this.label, this.route});
}

class _SocialIconData {
  final FaIconData icon;
  final String url;
  const _SocialIconData({required this.icon, required this.url});
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Footer._accent),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.white.withValues(alpha: 0.6),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterLinkText extends StatefulWidget {
  final String label;
  final String? route;
  const _FooterLinkText({required this.label, this.route});

  @override
  State<_FooterLinkText> createState() => _FooterLinkTextState();
}

class _FooterLinkTextState extends State<_FooterLinkText> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final route = widget.route;

    final content = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          fontSize: 13.5,
          color: _isHovered
              ? Footer._accent
              : Colors.white.withValues(alpha: 0.65),
        ),
        child: Text(widget.label),
      ),
    );

    if (route == null) return content;

    // Link renders a real <a href> under the hood on web, so search
    // engines can crawl it and users get standard browser link behavior
    // (hover preview, right-click "open in new tab", ctrl/cmd+click) —
    // while our own onTap still drives the actual SPA navigation via
    // GoRouter, same "reload if already here" behavior as before.
    return Link(
      uri: Uri.parse(route),
      builder: (context, followLink) {
        return GestureDetector(
          onTap: () {
            final currentPath = GoRouterState.of(context).uri.toString();
            if (currentPath == route) {
              web.window.location.reload();
            } else {
              context.go(route);
            }
          },
          child: content,
        );
      },
    );
  }
}

class _LegalLink extends StatefulWidget {
  final String label;
  final String route;
  const _LegalLink({required this.label, required this.route});

  @override
  State<_LegalLink> createState() => _LegalLinkState();
}

class _LegalLinkState extends State<_LegalLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final content = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          fontSize: 12.5,
          color: _isHovered
              ? Footer._accent
              : Colors.white.withValues(alpha: 0.5),
        ),
        child: Text(widget.label),
      ),
    );

    return Link(
      uri: Uri.parse(widget.route),
      builder: (context, followLink) {
        return GestureDetector(
          onTap: () {
            final currentPath = GoRouterState.of(context).uri.toString();
            if (currentPath == widget.route) {
              web.window.location.reload();
            } else {
              context.go(widget.route);
            }
          },
          child: content,
        );
      },
    );
  }
}

class _SocialIcon extends StatefulWidget {
  final FaIconData icon;
  final String url;
  const _SocialIcon({required this.icon, required this.url});

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final content = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isHovered
              ? Footer._accent
              : Colors.white.withValues(alpha: 0.08),
          border: Border.all(
            color: _isHovered
                ? Footer._accent
                : Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: FaIcon(
          widget.icon,
          size: 15,
          color: _isHovered
              ? Colors.black
              : Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );

    return Link(
      uri: Uri.parse(widget.url),
      target: LinkTarget.blank,
      builder: (context, followLink) {
        return GestureDetector(onTap: followLink, child: content);
      },
    );
  }
}
