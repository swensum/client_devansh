import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:web/web.dart' as web;

class WhatsAppFloatButton extends StatefulWidget {
  final String
  phoneNumber; // digits only, with country code, e.g. "9779857033614"
  final String? message; // optional prefilled message
  final Alignment alignment;
  final EdgeInsets margin;

  const WhatsAppFloatButton({
    super.key,
    required this.phoneNumber,
    this.message,
    this.alignment = Alignment.bottomRight,
    this.margin = const EdgeInsets.only(right: 24, bottom: 24),
  });

  @override
  State<WhatsAppFloatButton> createState() => _WhatsAppFloatButtonState();
}

class _WhatsAppFloatButtonState extends State<WhatsAppFloatButton> {
  bool _isHovered = false;

  void _open() {
    final query = widget.message != null && widget.message!.isNotEmpty
        ? '?text=${Uri.encodeComponent(widget.message!)}'
        : '';
    web.window.open('https://wa.me/${widget.phoneNumber}$query', '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: Padding(
        padding: widget.margin,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: _open,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 150),
              scale: _isHovered ? 1.08 : 1.0,
              child: Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF25D366), // WhatsApp brand green
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const FaIcon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
