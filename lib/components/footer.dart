import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  static const _accent = Color.fromRGBO(245, 171, 30, 1);

  static const List<_FooterLink> _quickLinks = [
    _FooterLink(label: "Home"),
    _FooterLink(label: "About Us"),
    _FooterLink(label: "Products"),
    _FooterLink(label: "Reviews"),
    _FooterLink(label: "Contact"),
  ];

  static const List<_FooterLink> _categoryLinks = [
    _FooterLink(label: "Cabinet Handles"),
    _FooterLink(label: "Door Handles"),
    _FooterLink(label: "Hinges & Locks"),
    _FooterLink(label: "Aldrops"),
    _FooterLink(label: "Accessories"),
  ];

  static const List<_SocialIconData> _socials = [
    _SocialIconData(icon: Icons.facebook),
    _SocialIconData(icon: Icons.camera_alt_outlined), // Instagram stand-in
    _SocialIconData(icon: Icons.alternate_email), // Twitter/X stand-in
    _SocialIconData(icon: Icons.chat_bubble_outline), // WhatsApp stand-in
  ];

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
                    final quick = _buildLinkColumn("Quick Links", _quickLinks);
                    final categories = _buildLinkColumn("Categories", _categoryLinks);
                    final newsletter = _buildNewsletterColumn();

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 4, child: brand),
                          Expanded(flex: 2, child: quick),
                          Expanded(flex: 2, child: categories),
                          Expanded(flex: 4, child: newsletter),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        brand,
                        const SizedBox(height: 36),
                        quick,
                        const SizedBox(height: 36),
                        categories,
                        const SizedBox(height: 36),
                        newsletter,
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          Container(width: double.infinity, height: 1, color: Colors.white.withValues(alpha: 0.08)),
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
                      style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5)),
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
                            children: [copyright, const SizedBox(height: 10), legalLinks],
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
          'assets/logo.png',          // <── your logo asset path
          height: 60,                 // adjust as needed
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 14),
        Text(
          "Premium cabinet and door hardware crafted for modern homes "
          "and everyday durability.",
          style: TextStyle(fontSize: 13.5, height: 1.6, color: Colors.white.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 20),
        Row(
          children: _socials
              .map((s) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _SocialIcon(icon: s.icon),
                  ))
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
          ...links.map((link) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _FooterLinkText(label: link.label),
              )),
        ],
      ),
    );
  }

  Widget _buildNewsletterColumn() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Stay Updated",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Subscribe for new arrivals and exclusive offers.",
            style: TextStyle(fontSize: 13.5, color: Colors.white.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 16),
          _NewsletterField(),
        ],
      ),
    );
  }
}

class _FooterLink {
  final String label;
  const _FooterLink({required this.label});
}

class _SocialIconData {
  final IconData icon;
  const _SocialIconData({required this.icon});
}

class _FooterLinkText extends StatefulWidget {
  final String label;
  const _FooterLinkText({required this.label});

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
          // Add navigation logic here
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
            color: _isHovered ? Footer._accent : Colors.white.withValues(alpha: 0.5),
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
              color: _isHovered ? Footer._accent : Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Icon(
            widget.icon,
            size: 16,
            color: _isHovered ? Colors.black : Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}

class _NewsletterField extends StatefulWidget {
  @override
  State<_NewsletterField> createState() => _NewsletterFieldState();
}

class _NewsletterFieldState extends State<_NewsletterField> {
  final _controller = TextEditingController();
  bool _subscribed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubscribe() {
    if (_controller.text.trim().isEmpty) return;

    // Replace with your actual newsletter signup call.
    setState(() => _subscribed = true);
    _controller.clear();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _subscribed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                cursorColor: Footer._accent,
                decoration: InputDecoration(
                  hintText: "Your email",
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Footer._accent, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _handleSubscribe,
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: const BoxDecoration(
                  color: Footer._accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward, size: 16, color: Colors.black),
              ),
            ),
          ],
        ),
        if (_subscribed) ...[
          const SizedBox(height: 10),
          Text(
            "Subscribed! Thanks for joining.",
            style: TextStyle(fontSize: 12, color: Footer._accent),
          ),
        ],
      ],
    );
  }
}