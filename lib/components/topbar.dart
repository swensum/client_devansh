import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  static const double height = 36;

  static const _textStyle = TextStyle(
    color: Colors.white70,
    fontSize: 14,
    fontFamily: 'BrandonGrotesque',
  );

  static const String _email = 'info@devansh.com';
  static const List<String> _phoneNumbers = [
    '+977 9857033614',
    '+977 9857081383',
  ];

  Future<void> _openEmail() async {
    final uri = Uri(scheme: 'mailto', path: _email);
    await launchUrl(uri);
  }

  Future<void> _callNumber(String number) async {
    final sanitized = number.replaceAll(' ', '');
    final uri = Uri(scheme: 'tel', path: sanitized);
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTight = width < 700; // hide phone on narrow screens
    final isCompact = width < 500; // hide email too on very narrow screens

    return Container(
      height: height,
      width: double.infinity,
      color: const Color(0xFF0F0F0F),
      padding: EdgeInsets.symmetric(horizontal: isTight ? 10 : 30),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Sukhanagar(Old Napi Office),Butwal,Nepal',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: _textStyle,
            ),
          ),

          const Spacer(),

          // Contact info — pushed to the right side.
          if (!isCompact) ...[
            const Icon(Icons.email_outlined, color: Colors.white70, size: 14),
            const SizedBox(width: 6),
            _TopBarLink(text: _email, onTap: _openEmail),
          ],
          if (!isTight) ...[
            const SizedBox(width: 20),
            const Icon(Icons.phone, color: Colors.white70, size: 14),
            const SizedBox(width: 6),
            for (int i = 0; i < _phoneNumbers.length; i++) ...[
              if (i > 0)
                const Text(', ', style: _textStyle),
              _TopBarLink(
                text: _phoneNumbers[i],
                onTap: () => _callNumber(_phoneNumbers[i]),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// Small hover-aware clickable text used for the email/phone links in
/// [TopBar]. Underlines and brightens slightly on hover for web/desktop.
class _TopBarLink extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _TopBarLink({required this.text, required this.onTap});

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
            fontSize: 14,
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