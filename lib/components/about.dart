import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80), // Reduced from 60 to 30
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
          constraints: const BoxConstraints(maxWidth: 1200), // Increased from 1100 to allow more space
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
                  ],
                ),
              ),

              const SizedBox(width: 120), // Increased from 80 to 120 for more gap

              // Right side — Why Choose Us (single column, full-width boxes)
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Why Choose Us",
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

                    // Feature boxes — now fill the full column width
                    const _FeatureBox(title: "Premium Quality"),
                    const SizedBox(height: 16),
                    const _FeatureBox(title: "Durable & Long-Lasting"),
                    const SizedBox(height: 16),
                    const _FeatureBox(title: "Elegant Designs"),
                    
                  ],
                ),
              ),
            ],
          ),
        ),
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