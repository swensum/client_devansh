import 'package:flutter/material.dart';

/// Wraps the whole app and floats a "back to top" button in the bottom
/// right whenever the user has scrolled down on ANY page. It listens for
/// ScrollNotifications bubbling up from whatever scroll view the current
/// page happens to be using — so it works everywhere without each screen
/// needing to expose its own ScrollController.
class ScrollToTopOverlay extends StatefulWidget {
  final Widget child;
  final double showAfterOffset;
  final Alignment alignment;
  final EdgeInsets margin;

  const ScrollToTopOverlay({
    super.key,
    required this.child,
    this.showAfterOffset = 300,
    this.alignment = Alignment.bottomRight,
    this.margin = const EdgeInsets.only(right: 24, bottom: 96),
  });

  @override
  State<ScrollToTopOverlay> createState() => _ScrollToTopOverlayState();
}

class _ScrollToTopOverlayState extends State<ScrollToTopOverlay> {
  bool _visible = false;
  BuildContext? _activeScrollContext;

  bool _onScrollNotification(ScrollNotification notification) {
    // Ignore horizontal scrollers (product carousels, etc.) — only react
    // to the page's main vertical scroll.
    if (notification.metrics.axis != Axis.vertical) return false;

    _activeScrollContext = notification.context;

    final shouldShow = notification.metrics.pixels > widget.showAfterOffset;
    if (shouldShow != _visible) {
      setState(() => _visible = shouldShow);
    }
    return false; // let the notification keep bubbling normally
  }

  void _scrollToTop() {
    final ctx = _activeScrollContext;
    if (ctx == null) return;
    Scrollable.of(ctx).position.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: Stack(
        children: [
          widget.child,
          Align(
            alignment: widget.alignment,
            child: Padding(
              padding: widget.margin,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                offset: _visible ? Offset.zero : const Offset(0, 0.4),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _visible ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: !_visible,
                    child: _ScrollTopButton(onTap: _scrollToTop),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrollTopButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ScrollTopButton({required this.onTap});

  @override
  State<_ScrollTopButton> createState() => _ScrollTopButtonState();
}

class _ScrollTopButtonState extends State<_ScrollTopButton> {
  bool _isHovered = false;

  static const _accent = Color.fromRGBO(245, 171, 30, 1);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: _isHovered ? 1.08 : 1.0,
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isHovered ? _accent : const Color(0xFF1A1A1A),
              border: Border.all(
                color: _accent.withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.keyboard_arrow_up,
              color: _isHovered ? Colors.black : Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
