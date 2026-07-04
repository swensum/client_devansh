import 'package:flutter/material.dart';

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
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: LayoutBuilder(
        builder: (context, constraints) {
          
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