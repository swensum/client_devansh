import 'package:flutter/material.dart';

/// Data model for a single stat item (e.g. "15+ Years Legacy")
class StatItem {
  final IconData icon;
  final String value;
  final String label;

  const StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });
}

/// A horizontal band showing key business figures — legacy years,
/// products, customers, and partner companies. Designed to sit right
/// below the hero carousel as a "trust bar" section.
class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  static const List<StatItem> _stats = [
    StatItem(
      icon: Icons.emoji_events_outlined,
      value: "15+",
      label: "Years of Legacy",
    ),
    StatItem(
      icon: Icons.inventory_2_outlined,
      value: "500+",
      label: "Products",
    ),
    StatItem(
      icon: Icons.people_outline,
      value: "10,000+",
      label: "Happy Customers",
    ),
    StatItem(
      icon: Icons.apartment_outlined,
      value: "50+",
      label: "Partner Companies",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.blueGrey[900],
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // On narrow screens, wrap into two rows instead of squeezing
          // four items into one line.
          final isNarrow = constraints.maxWidth < 700;

          return Wrap(
            alignment: WrapAlignment.center,
            runSpacing: 40,
            spacing: 20,
            children: _stats.map((stat) {
              return SizedBox(
                width: isNarrow
                    ? (constraints.maxWidth / 2) - 30
                    : (constraints.maxWidth / _stats.length) - 30,
                child: _StatTile(stat: stat),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final StatItem stat;

  const _StatTile({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          stat.icon,
          size: 34,
          color: const Color.fromRGBO(245, 171, 30, 1),
        ),
        const SizedBox(height: 12),
        Text(
          stat.value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          stat.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.75),
          ),
        ),
      ],
    );
  }
}