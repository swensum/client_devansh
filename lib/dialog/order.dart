import 'package:flutter/material.dart';

import 'package:devansh/models/catalogmodels.dart' hide MaterialType;

const _kBg = Color(0xFF0A1929);
const _kSurface = Color(0xFF12233A);
const _kAmber = Color.fromRGBO(245, 171, 30, 1);
const _kGreen = Color(0xFF4CAF50);
const _kBorder = Colors.white24;

const double _kStackBreakpoint = 560;

Future<void> handleOrderTap(
  BuildContext context,
  Product product, {
  Company? company,
  MaterialType? material,
  List<Product> relatedProducts = const [],
}) async {
  await showOrderDialog(
    context,
    product,
    company: company,
    material: material,
    relatedProducts: relatedProducts,
  );
}

Future<void> showOrderDialog(
  BuildContext context,
  Product product, {
  Company? company,
  MaterialType? material,
  List<Product> relatedProducts = const [],
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => _OrderDialog(
      product: product,
      company: company,
      material: material,
      relatedProducts: relatedProducts,
    ),
  );
}

class _OrderDialog extends StatefulWidget {
  final Product product;
  final Company? company;
  final MaterialType? material;
  final List<Product> relatedProducts;

  const _OrderDialog({
    required this.product,
    this.company,
    this.material,
    this.relatedProducts = const [],
  });

  @override
  State<_OrderDialog> createState() => _OrderDialogState();
}

class _OrderDialogState extends State<_OrderDialog> {
  late Product _product;
  int _quantity = 1;
  bool _submitting = false;

  // The full pool of products this dialog knows about — the product it
  // was originally opened with, plus whatever related products were
  // passed in. Whichever one is NOT currently shown as the main image
  // shows up in the thumbnail strip, so switching back and forth always
  // has something to show.
  late final List<Product> _allKnownProducts;

  @override
  void initState() {
    super.initState();
    _product = widget.product;

    final seenIds = <String>{};
    _allKnownProducts = [widget.product, ...widget.relatedProducts]
        .where((p) => seenIds.add(p.id)) // de-dupe by id
        .toList();
  }

  void _incrementQty() => setState(() => _quantity++);
  void _decrementQty() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  void _switchProduct(Product newProduct) {
    setState(() {
      _product = newProduct;
      _quantity = 1;
    });
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);

    // TODO: hook this up to Firestore once the backend is ready, e.g.:
    // await FirebaseFirestore.instance.collection('orders').add({
    //   'productId': _product.id,
    //   'productName': _product.name,
    //   'productImageUrl': _product.imageUrl,
    //   'quantity': _quantity,
    //   'status': 'pending',
    //   'createdAt': FieldValue.serverTimestamp(),
    // });

    await Future.delayed(const Duration(milliseconds: 600)); // placeholder

    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order request for "${_product.name}" submitted.'),
        backgroundColor: _kSurface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;

    // Brand/Material only reliably correspond to the originally-passed
    // product; if the dialog has switched to a related product, those
    // two rows are omitted rather than shown incorrectly.
    final isOriginalProduct = product.id == widget.product.id;

    final specs = <String, String?>{
      'Thickness': product.thickness,
      'Size': product.size,
      'Brand': isOriginalProduct ? widget.company?.name : null,
      'Finish': product.finish,
      'Material': isOriginalProduct ? widget.material?.name : null,
      'Availability': product.availability,
    }..removeWhere((key, value) => value == null || value.trim().isEmpty);

    final otherRelated = _allKnownProducts.where((p) => p.id != product.id).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 680),
        child: Container(
          decoration: BoxDecoration(
            color: _kBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kBorder),
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 30, offset: Offset(0, 12)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Place Order',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.of(context).pop(),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < _kStackBreakpoint;

                      final imageColumn = _ProductImagePane(
                        product: product,
                        relatedProducts: otherRelated,
                        onSelectRelated: _switchProduct,
                        mainImageHeight: isNarrow ? 160 : 230,
                      );

                      final detailsColumn = _ProductDetailsPane(
                        product: product,
                        specs: specs,
                        quantity: _quantity,
                        onIncrement: _incrementQty,
                        onDecrement: _decrementQty,
                      );

                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            imageColumn,
                            const SizedBox(height: 20),
                            detailsColumn,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 4, child: imageColumn),
                          const SizedBox(width: 24),
                          Expanded(flex: 5, child: detailsColumn),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kAmber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.black),
                          )
                        : const Text('Submit Order', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Left pane — the main product image, plus a horizontal strip of
/// related-product thumbnails directly beneath it.
class _ProductImagePane extends StatelessWidget {
  final Product product;
  final List<Product> relatedProducts;
  final ValueChanged<Product> onSelectRelated;
  final double mainImageHeight;

  const _ProductImagePane({
    required this.product,
    required this.relatedProducts,
    required this.onSelectRelated,
    required this.mainImageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: mainImageHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              color: Colors.grey.shade900,
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(color: _kAmber, strokeWidth: 2),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade800,
                        child: const Center(
                          child: Icon(Icons.image_not_supported_outlined, color: Colors.white38, size: 28),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade800,
                      child: const Center(
                        child: Icon(Icons.image_not_supported_outlined, color: Colors.white38, size: 28),
                      ),
                    ),
            ),
          ),
        ),

        if (relatedProducts.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: relatedProducts.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final related = relatedProducts[index];
                return GestureDetector(
                  onTap: () => onSelectRelated(related),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 84,
                      height: 84,
                      color: Colors.grey.shade900,
                      child: related.imageUrl.isNotEmpty
                          ? Image.network(
                              related.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.white38,
                                size: 24,
                              ),
                            )
                          : const Icon(Icons.image_not_supported_outlined, color: Colors.white38, size: 24),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

/// Right pane — name, description, the same spec grid style as the
/// product detail page (no price), and a quantity stepper for the order.
class _ProductDetailsPane extends StatelessWidget {
  final Product product;
  final Map<String, String?> specs;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _ProductDetailsPane({
    required this.product,
    required this.specs,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w700),
        ),
        if (product.description != null && product.description!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            product.description!,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 15, height: 1.45),
          ),
        ],
        if (specs.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: _DetailGrid(
              entries: [
                for (final entry in specs.entries)
                  _DetailEntry(
                    label: entry.key,
                    value: entry.value!,
                    isAvailability: entry.key == 'Availability',
                  ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),
        Text(
          'Quantity / Pieces',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 14.5, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _QtyButton(icon: Icons.remove, onTap: onDecrement),
            Container(
              width: 54,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                '$quantity',
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
            _QtyButton(icon: Icons.add, onTap: onIncrement),
          ],
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _kBorder),
        ),
        child: Icon(icon, color: Colors.white70, size: 18),
      ),
    );
  }
}

class _DetailEntry {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isAvailability;

  const _DetailEntry({
    required this.label,
    required this.value,
    this.valueColor,
    this.isAvailability = false,
  });
}

class _DetailGrid extends StatelessWidget {
  final List<_DetailEntry> entries;

  const _DetailGrid({required this.entries});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < entries.length; i += 2) {
      final left = entries[i];
      final right = i + 1 < entries.length ? entries[i + 1] : null;
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _DetailLine(entry: left)),
              const SizedBox(width: 16),
              Expanded(child: right != null ? _DetailLine(entry: right) : const SizedBox.shrink()),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}

class _DetailLine extends StatelessWidget {
  final _DetailEntry entry;

  const _DetailLine({required this.entry});

  bool get _isInStock =>
      entry.value.toLowerCase().contains('stock') && !entry.value.toLowerCase().contains('out');

  @override
  Widget build(BuildContext context) {
    final showGreen = entry.isAvailability && _isInStock;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${entry.label} : ',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 15.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              height: 1.5,
            ),
          ),
          TextSpan(
            text: entry.value,
            style: TextStyle(
              color: showGreen ? _kGreen : (entry.valueColor ?? const Color(0xFFF5F5F5)),
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
              height: 1.5,
            ),
          ),
          if (showGreen)
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: EdgeInsets.only(left: 5),
                child: Icon(Icons.check_circle, size: 14, color: _kGreen),
              ),
            ),
        ],
      ),
    );
  }
}