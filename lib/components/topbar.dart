import 'package:flutter/material.dart';

/// Thin bar shown above the main navbar with address & contact info.
/// Hidden automatically once the page scrolls away from the top
/// (see [SiteHeader] in header.dart).
class TopBar extends StatelessWidget {
  const TopBar({super.key});

  static const double height = 36;

  static const _textStyle = TextStyle(color: Colors.white70, fontSize: 12);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTight = width < 700; // hide phone on narrow screens
    final isCompact = width < 500; // hide email too on very narrow screens

    return Container(
      height: height,
      width: double.infinity,
      color: const Color(0xFF0F0F0F),
      padding: EdgeInsets.symmetric(horizontal: isTight ? 10 : 20),
      child: Row(
        children: [
          // Address — left side, shrinks if space is tight.
          const Icon(Icons.location_on, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Shop No. 12, Main Market, Biratnagar, Nepal',
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
            const Text('info@devansh.com', style: _textStyle),
          ],
          if (!isTight) ...[
            const SizedBox(width: 20),
            const Icon(Icons.phone, color: Colors.white70, size: 14),
            const SizedBox(width: 6),
            const Text('+977 98XXXXXXXX', style: _textStyle),
          ],
        ],
      ),
    );
  }
}