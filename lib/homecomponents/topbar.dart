import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

enum _ContactMode { full, iconOnly }

class _TopBarMetrics {
  final _ContactMode emailMode;
  final _ContactMode phoneMode;
  final double horizontalPadding;
  final double fontSize;
  final double iconSize;
  final double iconGap; // gap between an icon and the text next to it
  final double sectionGap; // gap before the phone section
  final double iconOnlyGap; // gap between icon-only items when packed tight

  const _TopBarMetrics({
    required this.emailMode,
    required this.phoneMode,
    required this.horizontalPadding,
    required this.fontSize,
    required this.iconSize,
    required this.iconGap,
    required this.sectionGap,
    required this.iconOnlyGap,
  });

  factory _TopBarMetrics.of(double width) {
    if (width >= 700) {
      // Full desktop — everything shown at full size.
      return const _TopBarMetrics(
        emailMode: _ContactMode.full,
        phoneMode: _ContactMode.full,
        horizontalPadding: 30,
        fontSize: 14,
        iconSize: 14,
        iconGap: 6,
        sectionGap: 20,
        iconOnlyGap: 14,
      );
    }
    if (width >= 500) {
      // Tablet / compact desktop — phone collapses to icon-only, email
      // still fits with text.
      return const _TopBarMetrics(
        emailMode: _ContactMode.full,
        phoneMode: _ContactMode.iconOnly,
        horizontalPadding: 20,
        fontSize: 13,
        iconSize: 15,
        iconGap: 5,
        sectionGap: 16,
        iconOnlyGap: 12,
      );
    }
    if (width >= 380) {
      // Small phones — both collapse to icon-only so email/call stay one
      // tap away without eating up the row's width.
      return const _TopBarMetrics(
        emailMode: _ContactMode.iconOnly,
        phoneMode: _ContactMode.iconOnly,
        horizontalPadding: 12,
        fontSize: 12,
        iconSize: 16,
        iconGap: 4,
        sectionGap: 12,
        iconOnlyGap: 14,
      );
    }
    // Smallest phones — tightest padding, icons still shown (just packed
    // a little closer) so the address row never pushes against the edge.
    return const _TopBarMetrics(
      emailMode: _ContactMode.iconOnly,
      phoneMode: _ContactMode.iconOnly,
      horizontalPadding: 8,
      fontSize: 11,
      iconSize: 16,
      iconGap: 4,
      sectionGap: 8,
      iconOnlyGap: 10,
    );
  }
}

/// Thin bar shown above the main navbar with address & contact info.
/// Hidden automatically once the page scrolls away from the top
/// (see [SiteHeader] in header.dart).
class TopBar extends StatelessWidget {
  const TopBar({super.key});

  static const double height = 36;

  static const String _email = 'info@devansh.com';
  static const List<String> _phoneNumbers = [
    '+977 9857033614',
    '+977 9857081383',
  ];

  // Using package:web directly (same as the reload logic in header.dart)
  // instead of url_launcher — avoids the plugin/method-channel error that
  // url_launcher's web implementation can throw for mailto/tel schemes.
  void _openEmail() {
    web.window.location.href = 'mailto:$_email';
  }

  void _callNumber(String number) {
    final sanitized = number.replaceAll(' ', '');
    web.window.location.href = 'tel:$sanitized';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final m = _TopBarMetrics.of(width);
    final textStyle = TextStyle(
      color: Colors.white70,
      fontSize: m.fontSize,
      fontFamily: 'BrandonGrotesque',
    );

    return Container(
      height: height,
      width: double.infinity,
      color: const Color(0xFF0F0F0F),
      padding: EdgeInsets.symmetric(horizontal: m.horizontalPadding),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Colors.white70, size: m.iconSize),
          SizedBox(width: m.iconGap),
          Flexible(
            child: Text(
              'Sukhanagar(Old Napi Office),Butwal,Nepal',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: textStyle,
            ),
          ),

          const Spacer(),

          // Contact info — pushed to the right side.
          if (m.emailMode == _ContactMode.full) ...[
            Icon(Icons.email_outlined, color: Colors.white70, size: m.iconSize),
            SizedBox(width: m.iconGap),
            _TopBarLink(text: _email, fontSize: m.fontSize, onTap: _openEmail),
          ] else if (m.emailMode == _ContactMode.iconOnly) ...[
            _TopBarIconButton(
              icon: Icons.email_outlined,
              size: m.iconSize,
              onTap: _openEmail,
            ),
          ],

          if (m.phoneMode == _ContactMode.full) ...[
            SizedBox(width: m.sectionGap),
            Icon(Icons.phone, color: Colors.white70, size: m.iconSize),
            SizedBox(width: m.iconGap),
            for (int i = 0; i < _phoneNumbers.length; i++) ...[
              if (i > 0) Text(', ', style: textStyle),
              _TopBarLink(
                text: _phoneNumbers[i],
                fontSize: m.fontSize,
                onTap: () => _callNumber(_phoneNumbers[i]),
              ),
            ],
          ] else if (m.phoneMode == _ContactMode.iconOnly) ...[
            SizedBox(
              width: m.emailMode == _ContactMode.iconOnly
                  ? m.iconOnlyGap
                  : m.sectionGap,
            ),
            // Icon-only mode dials the primary number — there's no room to
            // represent multiple numbers as separate icons on mobile.
            _TopBarIconButton(
              icon: Icons.phone,
              size: m.iconSize,
              onTap: () => _callNumber(_phoneNumbers.first),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tappable icon used when a contact item collapses to icon-only on
/// mobile — brightens on hover/tap just like [_TopBarLink] does for text,
/// so it still reads as interactive even without a label next to it.
class _TopBarIconButton extends StatefulWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _TopBarIconButton({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  @override
  State<_TopBarIconButton> createState() => _TopBarIconButtonState();
}

class _TopBarIconButtonState extends State<_TopBarIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        // A little extra hit area beyond the icon's visual bounds so it's
        // comfortable to tap on touch devices.
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Icon(
            widget.icon,
            color: _isHovered ? Colors.white : Colors.white70,
            size: widget.size,
          ),
        ),
      ),
    );
  }
}

/// Small hover-aware clickable text used for the email/phone links in
/// [TopBar]. Underlines and brightens slightly on hover for web/desktop.
class _TopBarLink extends StatefulWidget {
  final String text;
  final double fontSize;
  final VoidCallback onTap;

  const _TopBarLink({
    required this.text,
    required this.fontSize,
    required this.onTap,
  });

  @override
  State<_TopBarLink> createState() => _TopBarLinkState();
}

class _TopBarLinkState extends State<_TopBarLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.text,
          style: TextStyle(
            color: _isHovered ? Colors.white : Colors.white70,
            fontSize: widget.fontSize,
            fontFamily: 'BrandonGrotesque',
            decoration: _isHovered
                ? TextDecoration.underline
                : TextDecoration.none,
            decorationColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
