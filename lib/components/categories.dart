import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CategoriesSection extends StatefulWidget {
  const CategoriesSection({super.key});

  @override
  State<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection> {
  
  static const List<_Company> _companies = [
    _Company(name: "Hafele", logo: "assets/logo.png"),
    _Company(name: "Blum", logo: "assets/logo.png"),
    _Company(name: "Hettich", logo: "assets/logo.png"),
    _Company(name: "Grass", logo: "assets/logo.png"),
    _Company(name: "Salice", logo: "assets/logo.png"),
    _Company(name: "Ferrari", logo: "assets/logo.png"),
  ];

  // Once true, stays true — one-shot reveal, doesn't replay on re-scroll.
  bool _visible = false;

  void _handleVisibility(VisibilityInfo info) {
    if (!_visible && info.visibleFraction > 0.2) {
      setState(() => _visible = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('categories-section-visibility'),
      onVisibilityChanged: _handleVisibility,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 55),
        color: Colors.black,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1250),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Section Title
                _RevealOnVisible(
                  visible: _visible,
                  delay: const Duration(milliseconds: 0),
                  child: const Text(
                    "Shop by Companies",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Underline bar
                _RevealOnVisible(
                  visible: _visible,
                  delay: const Duration(milliseconds: 100),
                  child: Container(
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
                ),
                const SizedBox(height: 12),

                // Subtitle
                _RevealOnVisible(
                  visible: _visible,
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    "Premium hardware from the world's most trusted brands",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.6),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 24,
                  runSpacing: 24,
                  children: _companies.asMap().entries.map((entry) {
                    final i = entry.key;
                    final company = entry.value;
                    return _RevealOnVisible(
                      visible: _visible,
                      delay: Duration(milliseconds: 300 + (i * 80)),
                      child: _CompanyLogoBox(company: company),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 36),

                // View All Button
                _RevealOnVisible(
                  visible: _visible,
                  delay: Duration(
                    milliseconds: 300 + (_companies.length * 80) + 100,
                  ),
                  child: const _ViewAllButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class _RevealOnVisible extends StatefulWidget {
  final bool visible;
  final Duration delay;
  final Widget child;

  const _RevealOnVisible({
    required this.visible,
    required this.delay,
    required this.child,
  });

  @override
  State<_RevealOnVisible> createState() => _RevealOnVisibleState();
}

class _RevealOnVisibleState extends State<_RevealOnVisible> {
  bool _scheduled = false; 
  bool _started = false; 

  @override
  void initState() {
    super.initState();
    _maybeSchedule();
  }

  @override
  void didUpdateWidget(covariant _RevealOnVisible oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeSchedule();
  }

  void _maybeSchedule() {
    if (widget.visible && !_scheduled) {
      _scheduled = true;
      Future.delayed(widget.delay, () {
        if (mounted) setState(() => _started = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      opacity: _started ? 1.0 : 0.0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        offset: _started ? Offset.zero : const Offset(0, 0.15),
        child: widget.child,
      ),
    );
  }
}

class _Company {
  final String name;
  final String logo;

  const _Company({required this.name, required this.logo});
}

class _CompanyLogoBox extends StatefulWidget {
  final _Company company;

  const _CompanyLogoBox({required this.company});

  @override
  State<_CompanyLogoBox> createState() => _CompanyLogoBoxState();
}

class _CompanyLogoBoxState extends State<_CompanyLogoBox> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Transform.scale(
        scale: _isHovered ? 1.04 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: 180,
          height: 115,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? const Color.fromRGBO(245, 171, 30, 1)
                  : Colors.white.withValues(alpha: 0.15),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.25 : 0.12),
                blurRadius: _isHovered ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              widget.company.logo,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Text(
                widget.company.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewAllButton extends StatefulWidget {
  const _ViewAllButton();

  @override
  State<_ViewAllButton> createState() => _ViewAllButtonState();
}

class _ViewAllButtonState extends State<_ViewAllButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Color.fromRGBO(245, 171, 30, _isHovered ? 1.0 : 0.6),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
          color: _isHovered
              ? const Color.fromRGBO(245, 171, 30, 0.08)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "View All Products",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedRotation(
              duration: const Duration(milliseconds: 300),
              turns: _isHovered ? 0.125 : 0.0, // rotates ~45 degrees clockwise
              child: const Icon(
                Icons.arrow_forward,
                color: Color.fromRGBO(245, 171, 30, 1),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}