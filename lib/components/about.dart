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
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side — Who Are We
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _RevealOnVisible(
                        visible: _visible,
                        delay: const Duration(milliseconds: 0),
                        child: const Text(
                          "Who Are We?",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _RevealOnVisible(
                        visible: _visible,
                        delay: const Duration(milliseconds: 100),
                        child: Container(
                          width: 80,
                          height: 4,
                          color: const Color.fromRGBO(245, 171, 30, 1),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _RevealOnVisible(
                        visible: _visible,
                        delay: const Duration(milliseconds: 200),
                        child: Image.asset(
                          'assets/logo.png',
                          height: 100,
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _RevealOnVisible(
                        visible: _visible,
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
                            fontSize: 18,
                            height: 1.6,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 120),

                // Right side — Why Choose Us
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _RevealOnVisible(
                        visible: _visible,
                        delay: const Duration(milliseconds: 100),
                        child: const Text(
                          "Why Choose Us",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _RevealOnVisible(
                        visible: _visible,
                        delay: const Duration(milliseconds: 200),
                        child: Container(
                          width: 80,
                          height: 4,
                          color: const Color.fromRGBO(245, 171, 30, 1),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _RevealOnVisible(
                        visible: _visible,
                        delay: const Duration(milliseconds: 300),
                        child: const _FeatureBox(title: "Premium Quality"),
                      ),
                      const SizedBox(height: 16),
                      _RevealOnVisible(
                        visible: _visible,
                        delay: const Duration(milliseconds: 400),
                        child: const _FeatureBox(title: "Durable & Long-Lasting"),
                      ),
                      const SizedBox(height: 16),
                      _RevealOnVisible(
                        visible: _visible,
                        delay: const Duration(milliseconds: 500),
                        child: const _FeatureBox(title: "Elegant Designs"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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

  const _FeatureBox({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}