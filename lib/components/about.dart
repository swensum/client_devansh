import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AboutSection extends StatefulWidget {
  const AboutSection({super.key});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
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
      key: const Key('about-section-visibility'),
      onVisibilityChanged: _handleVisibility,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final r = _AboutResponsive.of(constraints.maxWidth);

          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: r.hPadding,
              vertical: r.vPadding,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.85),
                  Colors.black.withValues(alpha: 0.6),
                ],
                stops: const [0.0, 0.65],
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: r.stacked
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _WhoAreWe(visible: _visible, r: r),
                          SizedBox(height: r.columnGap),
                          _WhyChooseUs(visible: _visible, r: r),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: _WhoAreWe(visible: _visible, r: r),
                          ),
                          SizedBox(width: r.columnGap),
                          Expanded(
                            flex: 1,
                            child: _WhyChooseUs(visible: _visible, r: r),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WhoAreWe extends StatelessWidget {
  final bool visible;
  final _AboutResponsive r;

  const _WhoAreWe({required this.visible, required this.r});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _RevealOnVisible(
          visible: visible,
          delay: const Duration(milliseconds: 0),
          child: Text(
            "Who Are We?",
            style: TextStyle(
              fontSize: r.headingSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: r.underlineGap),
        _RevealOnVisible(
          visible: visible,
          delay: const Duration(milliseconds: 100),
          child: Container(
            width: 80,
            height: 4,
            color: const Color.fromRGBO(245, 171, 30, 1),
          ),
        ),
        SizedBox(height: r.blockGap),
        _RevealOnVisible(
          visible: visible,
          delay: const Duration(milliseconds: 200),
          child: Image.asset(
            'assets/logo.png',
            height: r.logoHeight,
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
          ),
        ),
        SizedBox(height: r.blockGap),
        _RevealOnVisible(
          visible: visible,
          delay: const Duration(milliseconds: 300),
          child: Text(
            "For years, we've been delivering premium cabinet handles, door fittings, "
            "mortice locks, aldrops, and architectural hardware that blend exceptional "
            "durability with timeless design. Every product is crafted with precision "
            "using high-quality materials to ensure lasting performance, reliability, "
            "and elegance. Whether for modern homes, commercial spaces, or custom "
            "interiors, our hardware is designed to enhance every detail while providing "
            "strength, security, and a flawless finish that stands the test of time.",
            style: TextStyle(
              fontSize: r.bodySize,
              height: 1.6,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }
}

class _WhyChooseUs extends StatelessWidget {
  final bool visible;
  final _AboutResponsive r;

  const _WhyChooseUs({required this.visible, required this.r});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _RevealOnVisible(
          visible: visible,
          delay: const Duration(milliseconds: 100),
          child: Text(
            "Why Choose Us",
            style: TextStyle(
              fontSize: r.headingSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: r.underlineGap),
        _RevealOnVisible(
          visible: visible,
          delay: const Duration(milliseconds: 200),
          child: Container(
            width: 80,
            height: 4,
            color: const Color.fromRGBO(245, 171, 30, 1),
          ),
        ),
        SizedBox(height: r.blockGap),
        _RevealOnVisible(
          visible: visible,
          delay: const Duration(milliseconds: 300),
          child: _FeatureBox(title: "Premium Quality", r: r),
        ),
        SizedBox(height: r.featureGap),
        _RevealOnVisible(
          visible: visible,
          delay: const Duration(milliseconds: 400),
          child: _FeatureBox(title: "Durable & Long-Lasting", r: r),
        ),
        SizedBox(height: r.featureGap),
        _RevealOnVisible(
          visible: visible,
          delay: const Duration(milliseconds: 500),
          child: _FeatureBox(title: "Elegant Designs", r: r),
        ),
      ],
    );
  }
}

/// Fades in + slides up from below, once, after [delay] has passed
/// following the moment [visible] first becomes true. Doesn't replay.
///
/// Checks both in initState (in case `visible` is already true on first
/// build) and didUpdateWidget (in case it becomes true later), so the
/// animation reliably fires regardless of when the section scrolls
/// into view relative to this widget's own build.
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
  bool _scheduled = false; // have we kicked off the delay timer yet?
  bool _started = false; // should we actually be visible/animated-in yet?

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
        if (mounted) setState(() => _started = true); // NOW it actually reveals
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

class _FeatureBox extends StatelessWidget {
  final String title;
  final _AboutResponsive r;

  const _FeatureBox({required this.title, required this.r});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: r.featureBoxHeight,
      padding: EdgeInsets.symmetric(horizontal: r.featureBoxHPadding),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color.fromRGBO(245, 171, 30, 1),
          width: 1,
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: r.featureFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Centralizes every breakpoint-dependent value for this section in one
/// place, instead of scattering separate if/else chains through each
/// widget. `stacked` controls whether the two columns lay out
/// side-by-side (Row) or on top of each other (Column) — below 900px the
/// two-column layout gets too cramped for the body text to read well, so
/// it switches to a single stacked column.
class _AboutResponsive {
  final bool stacked;
  final double hPadding;
  final double vPadding;
  final double columnGap;
  final double headingSize;
  final double bodySize;
  final double underlineGap;
  final double blockGap;
  final double featureGap;
  final double logoHeight;
  final double featureBoxHeight;
  final double featureBoxHPadding;
  final double featureFontSize;

  const _AboutResponsive({
    required this.stacked,
    required this.hPadding,
    required this.vPadding,
    required this.columnGap,
    required this.headingSize,
    required this.bodySize,
    required this.underlineGap,
    required this.blockGap,
    required this.featureGap,
    required this.logoHeight,
    required this.featureBoxHeight,
    required this.featureBoxHPadding,
    required this.featureFontSize,
  });

  factory _AboutResponsive.of(double w) {
    if (w > 900) {
      return const _AboutResponsive(
        stacked: false,
        hPadding: 30,
        vPadding: 80,
        columnGap: 120,
        headingSize: 34,
        bodySize: 18,
        underlineGap: 12,
        blockGap: 28,
        featureGap: 16,
        logoHeight: 100,
        featureBoxHeight: 120,
        featureBoxHPadding: 20,
        featureFontSize: 16,
      );
    }
    if (w > 600) {
      return const _AboutResponsive(
        stacked: false,
        hPadding: 24,
        vPadding: 60,
        columnGap: 40,
        headingSize: 28,
        bodySize: 16,
        underlineGap: 10,
        blockGap: 22,
        featureGap: 14,
        logoHeight: 80,
        featureBoxHeight: 100,
        featureBoxHPadding: 18,
        featureFontSize: 15,
      );
    }
    if (w > 400) {
      return const _AboutResponsive(
        stacked: true,
        hPadding: 20,
        vPadding: 48,
        columnGap: 36,
        headingSize: 24,
        bodySize: 15,
        underlineGap: 8,
        blockGap: 18,
        featureGap: 12,
        logoHeight: 64,
        featureBoxHeight: 90,
        featureBoxHPadding: 16,
        featureFontSize: 14,
      );
    }
    return const _AboutResponsive(
      stacked: true,
      hPadding: 16,
      vPadding: 40,
      columnGap: 32,
      headingSize: 20,
      bodySize: 13.5,
      underlineGap: 8,
      blockGap: 16,
      featureGap: 10,
      logoHeight: 56,
      featureBoxHeight: 80,
      featureBoxHPadding: 14,
      featureFontSize: 13,
    );
  }
}