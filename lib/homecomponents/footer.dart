import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    _SocialIconData(icon: Icons.facebook),
    _SocialIconData(icon: Icons.camera_alt_outlined), // Instagram stand-in
    _SocialIconData(icon: Icons.alternate_email), // Twitter/X stand-in
    _SocialIconData(icon: Icons.chat_bubble_outline), // WhatsApp stand-in
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
                      // Give the categories block more room as it grows extra columns.
                      final categoriesFlex = 2 * categoryColumns.length;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 4, child: brand),
                          Expanded(flex: 2, child: quick),
                          Expanded(flex: categoriesFlex, child: categories),
                          Expanded(flex: 4, child: contact),
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
                        _LegalLink(label: "Privacy Policy"),
                        _LegalLink(label: "Terms of Service"),
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
      padding: const EdgeInsets.only(right: 20, bottom: 10),
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
                    child: _SocialIcon(icon: s.icon),
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
      padding: const EdgeInsets.only(right: 20, bottom: 10),
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
      padding: const EdgeInsets.only(right: 20, bottom: 10),
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
  final IconData icon;
  const _SocialIconData({required this.icon});
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          final route = widget.route;
          if (route == null) return;

          // `go` replaces the current route stack to match the target
          // location, instead of pushing a new page on top of it — so
          // tapping "About" while already on /about would normally just
          // stay put instead of stacking a second identical page.
          // Reserve `push` for cases where "back" should return to a
          // specific prior page (e.g. list → detail navigation).
          //
          // The catch: if we're ALREADY on the target route, go() is a
          // no-op (the location doesn't change, so GoRouter never
          // rebuilds anything) — which made it look like the footer link
          // was "broken" when tapped from the same page. So: if the
          // target route matches where we already are, force a real
          // reload instead, same as how the header's Home button behaves
          // (it uses a hard browser navigation, which always reloads).
          final currentPath = GoRouterState.of(context).uri.toString();
          if (currentPath == route) {
            web.window.location.reload();
          } else {
            context.go(route);
          }
        },
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
      ),
    );
  }
}

class _LegalLink extends StatefulWidget {
  final String label;
  const _LegalLink({required this.label});

  @override
  State<_LegalLink> createState() => _LegalLinkState();
}

class _LegalLinkState extends State<_LegalLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          // Add navigation logic here
        },
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
      ),
    );
  }
}

class _SocialIcon extends StatefulWidget {
  final IconData icon;
  const _SocialIcon({required this.icon});

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          // Add navigation/link-launch logic here
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
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
          child: Icon(
            widget.icon,
            size: 16,
            color: _isHovered
                ? Colors.black
                : Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}
