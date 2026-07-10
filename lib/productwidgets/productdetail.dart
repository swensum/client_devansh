import 'package:devansh/data/catalog.dart';
import 'package:flutter/material.dart';

const _kAmber = Color.fromRGBO(245, 171, 30, 1);
const _kGreen = Color(0xFF4CAF50);

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final company = Catalog.companyFor(product);
    final material = Catalog.materialFor(product);
    final category = kCategories.firstWhere((c) => c.id == product.categoryId);

    // Only fields the product actually has get a row. Nothing here means
    // no "N/A" placeholder — the row simply doesn't exist.
    final specs = <String, String?>{
      'Thickness': product.thickness,
      'Size': product.size,
      'Quantity': product.quantity,
      'Brand': company?.name,
      'Finish': product.finish,
      'Material': material?.name,
      'Availability': product.availability,
    }..removeWhere((key, value) => value == null || value.trim().isEmpty);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left column: image, fills the full height of the row.
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          product.imageAsset,
                          fit: BoxFit.cover,
                          cacheWidth: 700,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey.shade800,
                            child: const Icon(Icons.image_not_supported_outlined, color: Colors.white38, size: 32),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Right column: title, description, details (price + specs), button.
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            category.name,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                          ),
                          if (product.description != null && product.description!.trim().isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              product.description!,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 14, height: 1.4),
                            ),
                          ],

                          // ---- Details: simple "Label: value" list, one column ----
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _DetailLine(
                                  label: 'Price',
                                  value: '\$${product.price.toStringAsFixed(2)}',
                                  valueColor: _kAmber,
                                ),
                                for (final entry in specs.entries)
                                  _DetailLine(
                                    label: entry.key,
                                    value: entry.value!,
                                    isAvailability: entry.key == 'Availability',
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _kAmber,
                                foregroundColor: Colors.black,
                                minimumSize: const Size(double.infinity, 46),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Place Order', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A single "Label: value" line. Plain white by default; pass [valueColor]
/// to color just the value (used for Price). Pass [isAvailability] to get
/// green text + a checkmark icon when the value reads as "in stock".
class _DetailLine extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isAvailability;

  const _DetailLine({
    required this.label,
    required this.value,
    this.valueColor,
    this.isAvailability = false,
  });

  bool get _isInStock => value.toLowerCase().contains('stock') && !value.toLowerCase().contains('out');

  @override
  Widget build(BuildContext context) {
    final showGreen = isAvailability && _isInStock;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: TextStyle(
                color: showGreen ? _kGreen : (valueColor ?? Colors.white),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (showGreen)
              const WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: Icon(Icons.check_circle, size: 15, color: _kGreen),
                ),
              ),
          ],
        ),
      ),
    );
  }
}