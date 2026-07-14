library;

enum ViewMode { grid, list }

enum SortOption { relevance, priceLowHigh, priceHighLow, nameAZ }

extension SortOptionLabel on SortOption {
  String get label {
    switch (this) {
      case SortOption.relevance:
        return 'Relevance';
      case SortOption.priceLowHigh:
        return 'Price: Low to High';
      case SortOption.priceHighLow:
        return 'Price: High to Low';
      case SortOption.nameAZ:
        return 'Name: A–Z';
    }
  }
}

class ProductsPageResponsive {
  final bool sidebarOnLeft;
  final double sidebarWidth;
  final int crossAxisCount;
  final double childAspectRatio;
  final double gridSpacing;
  final double hPadding;
  final double vPadding;
  final double sectionGap;
  final double bannerHeight;

  const ProductsPageResponsive({
    required this.sidebarOnLeft,
    required this.sidebarWidth,
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.gridSpacing,
    required this.hPadding,
    required this.vPadding,
    required this.sectionGap,
    required this.bannerHeight,
  });

  factory ProductsPageResponsive.of(double w) {
    if (w > 1100) {
      return const ProductsPageResponsive(
        sidebarOnLeft: true,
        sidebarWidth: 240,
        crossAxisCount: 4,
        childAspectRatio: 0.72,
        gridSpacing: 20,
        hPadding: 30,
        vPadding: 24,
        sectionGap: 28,
        bannerHeight: 130,
      );
    }
    if (w > 900) {
      return const ProductsPageResponsive(
        sidebarOnLeft: true,
        sidebarWidth: 220,
        crossAxisCount: 3,
        childAspectRatio: 0.72,
        gridSpacing: 18,
        hPadding: 24,
        vPadding: 22,
        sectionGap: 24,
        bannerHeight: 120,
      );
    }
    if (w > 700) {
      return const ProductsPageResponsive(
        sidebarOnLeft: true,
        sidebarWidth: 200,
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        gridSpacing: 16,
        hPadding: 20,
        vPadding: 20,
        sectionGap: 20,
        bannerHeight: 110,
      );
    }
    if (w > 500) {
      return const ProductsPageResponsive(
        sidebarOnLeft: false,
        sidebarWidth: 0,
        crossAxisCount: 3,
        childAspectRatio: 0.68,
        gridSpacing: 14,
        hPadding: 18,
        vPadding: 18,
        sectionGap: 18,
        bannerHeight: 100,
      );
    }
    if (w > 380) {
      return const ProductsPageResponsive(
        sidebarOnLeft: false,
        sidebarWidth: 0,
        crossAxisCount: 2,
        childAspectRatio: 0.66,
        gridSpacing: 12,
        hPadding: 14,
        vPadding: 14,
        sectionGap: 16,
        bannerHeight: 90,
      );
    }
    return const ProductsPageResponsive(
      sidebarOnLeft: false,
      sidebarWidth: 0,
      crossAxisCount: 1,
      childAspectRatio: 1.1,
      gridSpacing: 12,
      hPadding: 12,
      vPadding: 12,
      sectionGap: 14,
      bannerHeight: 80,
    );
  }
}