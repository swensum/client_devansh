import 'package:devansh/utils/navutils.dart';
import 'package:flutter/material.dart';

class HoverRegion extends StatefulWidget {
  final Widget Function(BuildContext context, bool isHovered) builder;
  final VoidCallback? onTap;
  final MouseCursor cursor;

  const HoverRegion({
    super.key,
    required this.builder,
    this.onTap,
    this.cursor = SystemMouseCursors.click,
  });

  @override
  State<HoverRegion> createState() => _HoverRegionState();
}

class _HoverRegionState extends State<HoverRegion> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.cursor,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: widget.builder(context, _isHovered),
      ),
    );
  }
}

class NavLink extends StatelessWidget {
  final String label;
  final String? route;
  final bool replace;

  final TextStyle Function(bool isHovered) style;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTapOverride;

  const NavLink({
    super.key,
    required this.label,
    required this.style,
    this.route,
    this.replace = true,
    this.padding = EdgeInsets.zero,
    this.onTapOverride,
  });

  @override
  Widget build(BuildContext context) {
    return HoverRegion(
      onTap:
          onTapOverride ??
          (route == null
              ? null
              : () => replace
                    ? context.goSmart(route!)
                    : context.pushSmart(route!)),
      builder: (context, hovered) => Padding(
        padding: padding,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: style(hovered),
          child: Text(label),
        ),
      ),
    );
  }
}
