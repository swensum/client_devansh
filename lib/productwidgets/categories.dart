import 'package:devansh/data/catalog.dart';
import 'package:flutter/material.dart';

const _kAmber = Color.fromRGBO(245, 171, 30, 1);

/// "Categories" header, then each category as a row. Tapping a category
/// selects it (filters the grid) and, if it has more than one company
/// selling in it, expands a nested company list directly beneath that
/// one row — other categories' company lists stay collapsed.
class CategorySidebar extends StatelessWidget {
  final String selectedCategoryId;
  final String? selectedCompanyId;
  final ValueChanged<String> onCategoryTap;
  final ValueChanged<String?> onCompanyTap;

  const CategorySidebar({
    super.key,
    required this.selectedCategoryId,
    required this.selectedCompanyId,
    required this.onCategoryTap,
    required this.onCompanyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Categories',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        for (final category in kCategories)
          _CategoryEntry(
            category: category,
            isSelected: category.id == selectedCategoryId,
            selectedCompanyId: selectedCompanyId,
            onCategoryTap: () => onCategoryTap(category.id),
            onCompanyTap: onCompanyTap,
          ),
      ],
    );
  }
}

class _CategoryEntry extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final String? selectedCompanyId;
  final VoidCallback onCategoryTap;
  final ValueChanged<String?> onCompanyTap;

  const _CategoryEntry({
    required this.category,
    required this.isSelected,
    required this.selectedCompanyId,
    required this.onCategoryTap,
    required this.onCompanyTap,
  });

  @override
  Widget build(BuildContext context) {
    // Computed on the fly from the product list — a company never needs
    // to declare upfront which categories it sells in.
    final companies = Catalog.companiesInCategory(category.id);
    final showCompanies = isSelected && companies.length > 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onCategoryTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? _kAmber.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(
                    color: isSelected ? _kAmber : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      category.name,
                      style: TextStyle(
                        color: isSelected ? _kAmber : Colors.white,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                  if (companies.length > 1)
                    Icon(
                      showCompanies ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 18,
                      color: isSelected ? _kAmber : Colors.white54,
                    ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: showCompanies
                ? Padding(
                    padding: const EdgeInsets.only(left: 14, top: 4, bottom: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CompanyRow(
                          label: 'All',
                          isSelected: selectedCompanyId == null,
                          onTap: () => onCompanyTap(null),
                        ),
                        for (final company in companies)
                          _CompanyRow(
                            label: company.name,
                            isSelected: selectedCompanyId == company.id,
                            onTap: () => onCompanyTap(company.id),
                          ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _CompanyRow extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CompanyRow({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 14,
              color: isSelected ? _kAmber : Colors.white38,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? _kAmber : Colors.white.withValues(alpha: 0.75),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}