import 'package:devansh/data/catalog.dart';
import 'package:flutter/material.dart';

const _kAmber = Color.fromRGBO(245, 171, 30, 1);

class CategorySidebar extends StatelessWidget {
  final String selectedCategoryId;
  final String? selectedCompanyId;
  final String? selectedMaterialId;
  final ValueChanged<String> onCategoryTap;
  final ValueChanged<String?> onCompanyTap;
  final ValueChanged<String?> onMaterialTap;

  const CategorySidebar({
    super.key,
    required this.selectedCategoryId,
    required this.selectedCompanyId,
    required this.selectedMaterialId,
    required this.onCategoryTap,
    required this.onCompanyTap,
    required this.onMaterialTap,
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

        const SizedBox(height: 16),
        Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
        const SizedBox(height: 16),

        const Text(
          'Materials',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _CompanyRow(
          label: 'All',
          isSelected: selectedMaterialId == null,
          onTap: () => onMaterialTap(null),
        ),
        for (final material in kMaterials)
          _CompanyRow(
            label: material.name,
            isSelected: selectedMaterialId == material.id,
            onTap: () => onMaterialTap(material.id),
          ),
      ],
    );
  }
}

class _CategoryEntry extends StatefulWidget {
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
  State<_CategoryEntry> createState() => _CategoryEntryState();
}

class _CategoryEntryState extends State<_CategoryEntry> {
  // Max companies visible before the list becomes scrollable.
  static const int _maxVisibleCompanies = 3;
  // Approx height of a single _CompanyRow (12 vertical padding + ~16 content height).
  static const double _companyRowHeight = 28;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final isSelected = widget.isSelected;
    final selectedCompanyId = widget.selectedCompanyId;
    final onCategoryTap = widget.onCategoryTap;
    final onCompanyTap = widget.onCompanyTap;

    final companies = Catalog.companiesInCategory(category.id);
    final showCompanies = isSelected && companies.length > 1;

    // "All" row + one row per company.
    final totalRows = companies.length + 1;
    final needsScroll = totalRows > _maxVisibleCompanies;

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
                    child: needsScroll
                        ? SizedBox(
                            height: _companyRowHeight * _maxVisibleCompanies,
                            child: RawScrollbar(
                              controller: _scrollController,
                              thumbVisibility: true,
                              trackVisibility: true,
                              thickness: 5,
                              radius: const Radius.circular(4),
                              thumbColor: _kAmber.withValues(alpha: 0.6),
                              trackColor: Colors.white.withValues(alpha: 0.08),
                              trackBorderColor: Colors.transparent,
                              child: Padding(
                                // Extra right padding so text doesn't sit under the thumb.
                                padding: const EdgeInsets.only(right: 10),
                                child: ListView(
                                  controller: _scrollController,
                                  padding: EdgeInsets.zero,
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
                              ),
                            ),
                          )
                        : Column(
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