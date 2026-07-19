import 'package:flutter/material.dart';

import 'package:devansh/models/catalogmodels.dart' hide MaterialType;

const _kBg = Color(0xFF0A1929);
const _kBgLight = Color(0xFF122A45);
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
        constraints: const BoxConstraints(maxWidth: 840, maxHeight: 700),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_kBgLight, _kBg],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: const [
              BoxShadow(color: Colors.black87, blurRadius: 40, offset: Offset(0, 18)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(26, 22, 18, 18),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 22,
                          decoration: BoxDecoration(
                            color: _kAmber,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Place Order',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.of(context).pop(),
                      splashRadius: 20,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.06),
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(26, 22, 26, 0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < _kStackBreakpoint;

                      final imageColumn = _ProductImagePane(
                        product: product,
                        relatedProducts: otherRelated,
                        onSelectRelated: _switchProduct,
                        mainImageHeight: isNarrow ? 170 : 240,
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
                            const SizedBox(height: 24),
                            detailsColumn,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 4, child: imageColumn),
                          const SizedBox(width: 28),
                          Expanded(flex: 5, child: detailsColumn),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.fromLTRB(26, 18, 26, 22),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kAmber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ).copyWith(
                      overlayColor: WidgetStateProperty.all(Colors.black.withValues(alpha: 0.08)),
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
        Container(
          height: mainImageHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 8)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
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
          const SizedBox(height: 16),
          Text(
            'MORE IN THIS CATEGORY',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: relatedProducts.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return _RelatedThumbnail(
                  product: relatedProducts[index],
                  onTap: () => onSelectRelated(relatedProducts[index]),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _RelatedThumbnail extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const _RelatedThumbnail({required this.product, required this.onTap});

  @override
  State<_RelatedThumbnail> createState() => _RelatedThumbnailState();
}

class _RelatedThumbnailState extends State<_RelatedThumbnail> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? _kAmber : Colors.white.withValues(alpha: 0.14),
              width: _isHovered ? 2 : 1.2,
            ),
            boxShadow: _isHovered
                ? [BoxShadow(color: _kAmber.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.5),
            child: Container(
              color: Colors.grey.shade900,
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white38,
                        size: 22,
                      ),
                    )
                  : const Icon(Icons.image_not_supported_outlined, color: Colors.white38, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

/// Right pane — name, description, spec card, and quantity stepper.
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
            style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 15, height: 1.45),
          ),
        ],

        if (specs.isNotEmpty) ...[
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.07),
                  Colors.white.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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

        const SizedBox(height: 24),
        Text(
          'QUANTITY / PIECES',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _QtyButton(icon: Icons.remove, onTap: onDecrement),
              Container(
                width: 56,
                alignment: Alignment.center,
                child: Text(
                  '$quantity',
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              _QtyButton(icon: Icons.add, onTap: onIncrement),
            ],
          ),
        ),
      ],
    );
  }
}

class _QtyButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  State<_QtyButton> createState() => _QtyButtonState();
}

class _QtyButtonState extends State<_QtyButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _isHovered ? _kAmber.withValues(alpha: 0.15) : _kSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _isHovered ? _kAmber.withValues(alpha: 0.6) : _kBorder),
          ),
          child: Icon(widget.icon, color: _isHovered ? _kAmber : Colors.white70, size: 18),
        ),
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
          padding: const EdgeInsets.symmetric(vertical: 6),
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
            text: '${entry.label}\n',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              height: 1.8,
            ),
          ),
          TextSpan(
            text: entry.value,
            style: TextStyle(
              color: showGreen ? _kGreen : (entry.valueColor ?? const Color(0xFFF5F5F5)),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              height: 1.4,
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