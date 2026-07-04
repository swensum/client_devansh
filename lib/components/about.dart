import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 560,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withOpacity(0.85),
                  Colors.black.withOpacity(0.6),
                ],
                stops: const [0.0, 0.65],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Who Are We?",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Underline bar below the headline
                    Container(
                      width: 80,
                      height: 4,
                      color: const Color.fromRGBO(245, 171, 30, 1),
                    ),
                    const SizedBox(height: 28),

                    // Logo
                    Image.asset(
                      'assets/logo.png',
                      height: 100,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                    ),
                    const SizedBox(height: 28),

                    // About text
                    Text(
                      "For years, we've been crafting premium cabinet handles, "
                      "door fittings, and hardware that combine durability "
                      "with timeless design. Every piece is built with "
                      "precision, so your space feels as good as it looks.",
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.6,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}