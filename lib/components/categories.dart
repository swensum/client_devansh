import 'package:flutter/material.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  // Map each company name to its logo asset path.
  // Update these paths to match wherever your logo images actually live.
  static const List<_Company> _companies = [
    _Company(name: "Hafele", logo: "assets/logo.png"),
    _Company(name: "Blum", logo: "assets/logo.png"),
    _Company(name: "Hettich", logo: "assets/logo.png"),
    _Company(name: "Grass", logo: "assets/logo.png"),
    _Company(name: "Salice", logo: "assets/logo.png"),
    _Company(name: "Ferrari", logo: "assets/logo.png"),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 55),
      color: Colors.black,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1250),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Section Title
              const Text(
                "Shop by Companies",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),

              // Underline bar
              Container(
          width: 60,
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromRGBO(245, 171, 30, 0.5),
                const Color.fromRGBO(245, 171, 30, 1),
                const Color.fromRGBO(245, 171, 30, 0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                "Premium hardware from the world's most trusted brands",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.6),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 36),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 24,
                runSpacing: 24,
                children: _companies
                    .map((company) => _CompanyLogoBox(company: company))
                    .toList(),
              ),

              const SizedBox(height: 36),

              // View All Button
              const _ViewAllButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Company {
  final String name;
  final String logo;

  const _Company({required this.name, required this.logo});
}

class _CompanyLogoBox extends StatefulWidget {
  final _Company company;

  const _CompanyLogoBox({required this.company});

  @override
  State<_CompanyLogoBox> createState() => _CompanyLogoBoxState();
}

class _CompanyLogoBoxState extends State<_CompanyLogoBox> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 180,
        height: 115,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        transform: Matrix4.identity()..scale(_isHovered ? 1.04 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
         
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? const Color.fromRGBO(245, 171, 30, 1)
                : Colors.white.withOpacity(0.15),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.25 : 0.12),
              blurRadius: _isHovered ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            widget.company.logo,
            fit: BoxFit.contain,
            
            errorBuilder: (context, error, stackTrace) => Text(
              widget.company.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewAllButton extends StatefulWidget {
  const _ViewAllButton();

  @override
  State<_ViewAllButton> createState() => _ViewAllButtonState();
}

class _ViewAllButtonState extends State<_ViewAllButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Color.fromRGBO(245, 171, 30, _isHovered ? 1.0 : 0.6),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
          color: _isHovered
              ? const Color.fromRGBO(245, 171, 30, 0.08)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "View All Products",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedRotation(
              duration: const Duration(milliseconds: 300),
              turns: _isHovered ? 0.125 : 0.0, // rotates ~45 degrees clockwise
              child: const Icon(
                Icons.arrow_forward,
                color: Color.fromRGBO(245, 171, 30, 1),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}