import 'package:devansh/data/catalog.dart';
import 'package:flutter/material.dart';

const _kAmber = Color.fromRGBO(245, 171, 30, 1);

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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Top row: equal-width, equal-height columns ----
            IntrinsicHeight(
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
                        cacheWidth: 500,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade800,
                          child: const Icon(Icons.image_not_supported_outlined, color: Colors.white38, size: 32),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Right column: title, description, price, place order button.
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
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
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13.5, height: 1.4),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(color: _kAmber, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
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

            // ---- Details box: full width, below the equal-height row. ----
            if (specs.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Details',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    for (final entry in specs.entries) _SpecRow(label: entry.key, value: entry.value!),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;

  const _SpecRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}