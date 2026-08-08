import 'dart:async';

import 'package:devansh/models/authmodel.dart';
import 'package:devansh/models/ordermodel.dart';

import 'package:devansh/services/authservice.dart';
import 'package:devansh/services/orderservice.dart';
import 'package:devansh/services/orderrecordservice.dart';
import 'package:devansh/services/catalogservice.dart';
import 'package:devansh/models/catalogmodels.dart';
import 'package:flutter/material.dart' hide MaterialType;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

const _kBg = Colors.black;
const _kSurface = Color(0xFF141414);
const _kSurfaceRaised = Color(0xFF1D1D1D);
const _kAmber = Color.fromRGBO(245, 171, 30, 1);
const _kBorderSubtle = Color.fromRGBO(245, 171, 30, 0.16);

const double _kMaxContentWidth = 1400;

const String _kAdminWhatsAppNumber = '9779857033614';

const String _kDivider = '━━━━━━━━━━━━━━━━━━━━';
const String _kItemDivider = '┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈';

const List<String> _kKeycapDigits = [
  '1️⃣',
  '2️⃣',
  '3️⃣',
  '4️⃣',
  '5️⃣',
  '6️⃣',
  '7️⃣',
  '8️⃣',
  '9️⃣',
];

String _numberEmoji(int n) {
  if (n >= 1 && n <= 9) return _kKeycapDigits[n - 1];
  if (n == 10) return '🔟';
  return '$n.';
}

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  bool _submitting = false;
  bool _termsAccepted = false;

  final CatalogService _catalogService = CatalogService();
  final OrderRecordService _orderRecordService = OrderRecordService();
  Map<String, String> _categoryNames = {};
  Map<String, String> _companyNames = {};
  Map<String, String> _materialNames = {};
  StreamSubscription<List<Category>>? _categoriesSub;
  StreamSubscription<List<Company>>? _companiesSub;
  StreamSubscription<List<MaterialType>>? _materialsSub;

  final _shopNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _noteController = TextEditingController();
  AppUser? _autofilledFor;

  @override
  void initState() {
    super.initState();
    final currentUser = AuthService.instance.currentUser.value;
    if (currentUser != null) {
      _autofillFromUser(currentUser);
    }
    AuthService.instance.currentUser.addListener(_handleUserChanged);

    _categoriesSub = _catalogService.watchCategories().listen((categories) {
      if (!mounted) return;
      setState(() {
        _categoryNames = {for (final c in categories) c.id: c.name};
      });
    });

    // Needed so the WhatsApp order message (and the stored order record)
    // can show brand/material names instead of just raw IDs.
    _companiesSub = _catalogService.watchCompanies().listen((companies) {
      if (!mounted) return;
      setState(() {
        _companyNames = {for (final c in companies) c.id: c.name};
      });
    });
    _materialsSub = _catalogService.watchMaterials().listen((materials) {
      if (!mounted) return;
      setState(() {
        _materialNames = {for (final m in materials) m.id: m.name};
      });
    });
  }

  void _handleUserChanged() {
    final user = AuthService.instance.currentUser.value;
    if (user != null && user != _autofilledFor) {
      _autofillFromUser(user);
    }
  }

  void _autofillFromUser(AppUser user) {
    _autofilledFor = user;
    final name = user.name;
    final email = user.email;

    if (_ownerNameController.text.trim().isEmpty &&
        name != null &&
        name.trim().isNotEmpty) {
      _ownerNameController.text = name;
    }
    if (_emailController.text.trim().isEmpty &&
        email != null &&
        email.trim().isNotEmpty) {
      _emailController.text = email;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AuthService.instance.currentUser.removeListener(_handleUserChanged);
    _categoriesSub?.cancel();
    _companiesSub?.cancel();
    _materialsSub?.cancel();
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _taxIdController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int _totalUnits(List<PendingOrderItem> items) =>
      items.fold(0, (sum, i) => sum + i.quantity);

  List<String> _productSpecLines(Product product) {
    final lines = <String>[];

    final brand = _companyNames[product.companyId];
    if (brand != null && brand.trim().isNotEmpty) {
      lines.add('🏷️ Brand: $brand');
    }

    final material = _materialNames[product.materialId];
    if (material != null && material.trim().isNotEmpty) {
      lines.add('🧱 Material: $material');
    }

    if ((product.thickness ?? '').trim().isNotEmpty) {
      lines.add('📏 Thickness: ${product.thickness}');
    }
    if ((product.size ?? '').trim().isNotEmpty) {
      lines.add('📐 Size: ${product.size}');
    }
    if ((product.finish ?? '').trim().isNotEmpty) {
      lines.add('✨ Finish: ${product.finish}');
    }
    if ((product.quantity ?? '').trim().isNotEmpty) {
      lines.add('📦 Pack: ${product.quantity}');
    }
    if (!product.hasVariants &&
        (product.availability ?? '').trim().isNotEmpty) {
      lines.add('✅ Availability: ${product.availability}');
    }

    return lines;
  }

  String? _variantLine(ProductVariant variant) {
    final dims = [
      if ((variant.width ?? '').trim().isNotEmpty) 'W${variant.width}',
      if ((variant.depth ?? '').trim().isNotEmpty) 'D${variant.depth}',
      if ((variant.height ?? '').trim().isNotEmpty) 'H${variant.height}',
    ].join(' × ');

    final availability = (variant.availability ?? '').trim();
    final availabilitySuffix = availability.isNotEmpty
        ? ' — $availability'
        : '';
    final dimsSuffix = dims.isNotEmpty ? ' ($dims mm)' : '';

    return '🔩 Model: ${variant.model}$dimsSuffix$availabilitySuffix';
  }

  String _buildWhatsAppMessage(List<PendingOrderItem> items) {
    final buffer = StringBuffer();

    buffer.writeln('🧾 *NEW ORDER REQUEST*');
    buffer.writeln(_kDivider);
    buffer.writeln();
    buffer.writeln('📍 *Shop & Delivery Details*');
    buffer.writeln('🏪 Shop: ${_shopNameController.text.trim()}');
    buffer.writeln('👤 Owner: ${_ownerNameController.text.trim()}');
    buffer.writeln('📞 Phone: ${_phoneController.text.trim()}');
    if (_emailController.text.trim().isNotEmpty) {
      buffer.writeln('✉️ Email: ${_emailController.text.trim()}');
    }
    buffer.writeln('🏠 Address: ${_addressController.text.trim()}');
    if (_cityController.text.trim().isNotEmpty) {
      buffer.writeln('📍 City / Area: ${_cityController.text.trim()}');
    }
    if (_taxIdController.text.trim().isNotEmpty) {
      buffer.writeln('🧾 VAT / PAN: ${_taxIdController.text.trim()}');
    }
    if (_noteController.text.trim().isNotEmpty) {
      buffer.writeln('📝 Note: ${_noteController.text.trim()}');
    }

    buffer.writeln();
    buffer.writeln(_kDivider);
    buffer.writeln('🛒 *ORDER ITEMS* (${items.length})');
    buffer.writeln(_kDivider);

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final product = item.product;
      final categoryName =
          _categoryNames[product.categoryId] ?? product.categoryId;

      buffer.writeln();
      buffer.writeln('${_numberEmoji(i + 1)} *${product.name}*');
      buffer.writeln('📂 Category: $categoryName');

      for (final line in _productSpecLines(product)) {
        buffer.writeln(line);
      }

      if (item.variant != null) {
        final variantLine = _variantLine(item.variant!);
        if (variantLine != null) buffer.writeln(variantLine);
      }

      buffer.writeln('🔢 Quantity: *${item.quantity}* pcs');

      if (product.imageUrl.isNotEmpty) {
        buffer.writeln('🖼️ ${product.imageUrl}');
      }

      if (i != items.length - 1) buffer.writeln(_kItemDivider);
    }

    final totalUnits = _totalUnits(items);
    buffer.writeln();
    buffer.writeln(_kDivider);
    buffer.writeln(
      '📦 *Total Quantity:* $totalUnits ${totalUnits == 1 ? 'unit' : 'units'}',
    );
    buffer.writeln(_kDivider);
    buffer.writeln();
    buffer.writeln('_Sent via the Devansh website_');

    return buffer.toString();
  }

  OrderRecord _buildOrderRecord(List<PendingOrderItem> items, AppUser? user) {
    return OrderRecord(
      userId: user?.email,
      shopName: _shopNameController.text.trim(),
      ownerName: _ownerNameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      taxId: _taxIdController.text.trim().isEmpty
          ? null
          : _taxIdController.text.trim(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      items: [
        for (final item in items)
          OrderItemRecord.fromPendingItem(
            item,
            _categoryNames[item.product.categoryId] ?? item.product.categoryId,
          ),
      ],
      totalUnits: _totalUnits(items),
    );
  }

  Future<void> _submitAllOrders(List<PendingOrderItem> items) async {
    setState(() => _submitting = true);

    final user = AuthService.instance.currentUser.value;
    final orderRecord = _buildOrderRecord(items, user);

    // Save to Firestore first so the order exists for the admin panel
    // even if the person never finishes (or accidentally closes) the
    // WhatsApp step that follows. A failure here is logged but doesn't
    // block the WhatsApp handoff — the order still reaches the admin
    // that way either way.
    try {
      await _orderRecordService.submitOrder(orderRecord);
    } catch (e) {
      debugPrint('OrdersPage: failed to save order to Firestore: $e');
    }

    final message = _buildWhatsAppMessage(items);

    // Copy too, so the shop's order details aren't lost even if the
    // WhatsApp link fails to open (popup blocked, app not installed, etc).
    await Clipboard.setData(ClipboardData(text: message));

    final whatsappUri = Uri.parse(
      'https://wa.me/$_kAdminWhatsAppNumber?text=${Uri.encodeComponent(message)}',
    );

    var launched = false;
    try {
      launched = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    } catch (_) {
      launched = false;
    }

    if (!mounted) return;

    OrderCartService.instance.clear();
    setState(() {
      _submitting = false;
      _termsAccepted = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          launched
              ? "Order saved — continue in WhatsApp to confirm with us."
              : "Order saved, but WhatsApp didn't open automatically. Your order details were copied — please paste them into a chat with us.",
        ),
        backgroundColor: _kSurfaceRaised,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _goToSignIn(BuildContext context) {
    context.push('/auth?redirect=${Uri.encodeComponent('/orders')}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: ValueListenableBuilder<List<PendingOrderItem>>(
          valueListenable: OrderCartService.instance.items,
          builder: (context, items, _) {
            return ValueListenableBuilder<AppUser?>(
              valueListenable: AuthService.instance.currentUser,
              builder: (context, user, _) {
                final canSubmit =
                    user != null &&
                    items.isNotEmpty &&
                    _termsAccepted &&
                    _shopNameController.text.trim().isNotEmpty &&
                    _ownerNameController.text.trim().isNotEmpty &&
                    _phoneController.text.trim().isNotEmpty &&
                    _addressController.text.trim().isNotEmpty;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final r = _OrdersResponsive.of(width);

                    return SingleChildScrollView(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: _kMaxContentWidth,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: r.pageHPadding,
                              vertical: r.pageVPadding,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _TopBar(onBack: () => context.pop(), r: r),
                                SizedBox(height: r.sectionGap),
                                r.stacked
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          _DetailsPane(
                                            r: r,
                                            signedIn: user != null,
                                            shopNameController:
                                                _shopNameController,
                                            ownerNameController:
                                                _ownerNameController,
                                            phoneController: _phoneController,
                                            emailController: _emailController,
                                            addressController:
                                                _addressController,
                                            cityController: _cityController,
                                            taxIdController: _taxIdController,
                                            noteController: _noteController,
                                            onSignIn: () =>
                                                _goToSignIn(context),
                                            onChanged: () => setState(() {}),
                                          ),
                                          SizedBox(height: r.sectionGap),
                                          _OrdersSummaryPane(
                                            r: r,
                                            items: items,
                                            totalUnits: _totalUnits(items),
                                            categoryNames: _categoryNames,
                                          ),
                                        ],
                                      )
                                    : Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: _DetailsPane(
                                              r: r,
                                              signedIn: user != null,
                                              shopNameController:
                                                  _shopNameController,
                                              ownerNameController:
                                                  _ownerNameController,
                                              phoneController: _phoneController,
                                              emailController: _emailController,
                                              addressController:
                                                  _addressController,
                                              cityController: _cityController,
                                              taxIdController: _taxIdController,
                                              noteController: _noteController,
                                              onSignIn: () =>
                                                  _goToSignIn(context),
                                              onChanged: () => setState(() {}),
                                            ),
                                          ),
                                          SizedBox(width: r.columnGap),
                                          Expanded(
                                            flex: 7,
                                            child: _OrdersSummaryPane(
                                              r: r,
                                              items: items,
                                              totalUnits: _totalUnits(items),
                                              categoryNames: _categoryNames,
                                            ),
                                          ),
                                        ],
                                      ),
                                SizedBox(height: r.sectionGap),
                                _TermsAndSubmit(
                                  r: r,
                                  termsAccepted: _termsAccepted,
                                  onTermsChanged: (v) =>
                                      setState(() => _termsAccepted = v),
                                  canSubmit: canSubmit,
                                  submitting: _submitting,
                                  user: user,
                                  itemsEmpty: items.isEmpty,
                                  onSubmit: () => _submitAllOrders(items),
                                ),
                                SizedBox(height: r.sectionGap),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _OrdersResponsive {
  final bool stacked;
  final double pageHPadding;
  final double pageVPadding;
  final double sectionGap;
  final double columnGap;
  final double cardPadding;
  final double titleSize;
  final double sectionHeadingSize;
  final double bodySize;
  final double labelSize;

  const _OrdersResponsive({
    required this.stacked,
    required this.pageHPadding,
    required this.pageVPadding,
    required this.sectionGap,
    required this.columnGap,
    required this.cardPadding,
    required this.titleSize,
    required this.sectionHeadingSize,
    required this.bodySize,
    required this.labelSize,
  });

  factory _OrdersResponsive.of(double w) {
    if (w >= 1100) {
      return const _OrdersResponsive(
        stacked: false,
        pageHPadding: 56,
        pageVPadding: 40,
        sectionGap: 28,
        columnGap: 32,
        cardPadding: 32,
        titleSize: 32,
        sectionHeadingSize: 19,
        bodySize: 15,
        labelSize: 13,
      );
    }
    if (w >= 820) {
      return const _OrdersResponsive(
        stacked: false,
        pageHPadding: 32,
        pageVPadding: 32,
        sectionGap: 24,
        columnGap: 24,
        cardPadding: 26,
        titleSize: 28,
        sectionHeadingSize: 18,
        bodySize: 14.5,
        labelSize: 12.5,
      );
    }
    if (w >= 560) {
      return const _OrdersResponsive(
        stacked: true,
        pageHPadding: 24,
        pageVPadding: 24,
        sectionGap: 20,
        columnGap: 0,
        cardPadding: 22,
        titleSize: 24,
        sectionHeadingSize: 17,
        bodySize: 14,
        labelSize: 12.5,
      );
    }
    return const _OrdersResponsive(
      stacked: true,
      pageHPadding: 16,
      pageVPadding: 16,
      sectionGap: 16,
      columnGap: 0,
      cardPadding: 18,
      titleSize: 21,
      sectionHeadingSize: 16,
      bodySize: 13.5,
      labelSize: 12,
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  final _OrdersResponsive r;
  const _TopBar({required this.onBack, required this.r});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 18),
            Text(
              'Your Orders',
              style: TextStyle(
                color: Colors.white,
                fontSize: r.titleSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 58),
          child: Text(
            'Fill in your shop details and review your order before submitting.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: r.bodySize,
            ),
          ),
        ),
      ],
    );
  }
}

/// Left pane — business/shop details, gated behind sign-in.
class _DetailsPane extends StatelessWidget {
  final _OrdersResponsive r;
  final bool signedIn;
  final TextEditingController shopNameController;
  final TextEditingController ownerNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController taxIdController;
  final TextEditingController noteController;
  final VoidCallback onSignIn;
  final VoidCallback onChanged;

  const _DetailsPane({
    required this.r,
    required this.signedIn,
    required this.shopNameController,
    required this.ownerNameController,
    required this.phoneController,
    required this.emailController,
    required this.addressController,
    required this.cityController,
    required this.taxIdController,
    required this.noteController,
    required this.onSignIn,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.cardPadding),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PaneHeading(
            icon: Icons.storefront_outlined,
            label: 'Business & Delivery Details',
            r: r,
          ),
          SizedBox(height: r.sectionGap * 0.8),
          if (!signedIn)
            _SignInGate(onSignIn: onSignIn, r: r)
          else ...[
            _FormField(
              label: 'Shop / Business Name',
              controller: shopNameController,
              r: r,
              onChanged: onChanged,
            ),
            SizedBox(height: r.sectionGap * 0.6),
            _ResponsiveFieldRow(
              stacked: r.stacked,
              r: r,
              children: [
                _FormField(
                  label: 'Owner / Contact Name',
                  controller: ownerNameController,
                  r: r,
                  onChanged: onChanged,
                ),
                _FormField(
                  label: 'Phone Number',
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  r: r,
                  onChanged: onChanged,
                ),
              ],
            ),
            SizedBox(height: r.sectionGap * 0.6),
            _FormField(
              label: 'Email (optional)',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              r: r,
              onChanged: onChanged,
            ),
            SizedBox(height: r.sectionGap * 0.6),
            _FormField(
              label: 'Shop / Delivery Address',
              controller: addressController,
              maxLines: 2,
              r: r,
              onChanged: onChanged,
            ),
            SizedBox(height: r.sectionGap * 0.6),
            _ResponsiveFieldRow(
              stacked: r.stacked,
              r: r,
              children: [
                _FormField(
                  label: 'City / Area',
                  controller: cityController,
                  r: r,
                  onChanged: onChanged,
                ),
                _FormField(
                  label: 'VAT / PAN Number (optional)',
                  controller: taxIdController,
                  r: r,
                  onChanged: onChanged,
                ),
              ],
            ),
            SizedBox(height: r.sectionGap * 0.6),
            _FormField(
              label: 'Order Note (optional)',
              controller: noteController,
              maxLines: 2,
              r: r,
              onChanged: onChanged,
            ),
          ],
        ],
      ),
    );
  }
}

class _ResponsiveFieldRow extends StatelessWidget {
  final bool stacked;
  final _OrdersResponsive r;
  final List<Widget> children;
  const _ResponsiveFieldRow({
    required this.stacked,
    required this.r,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (stacked) {
      return Column(
        children: [
          children[0],
          SizedBox(height: r.sectionGap * 0.6),
          children[1],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: children[0]),
        SizedBox(width: r.columnGap * 0.5),
        Expanded(child: children[1]),
      ],
    );
  }
}

class _PaneHeading extends StatelessWidget {
  final IconData icon;
  final String label;
  final _OrdersResponsive r;
  const _PaneHeading({
    required this.icon,
    required this.label,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: _kAmber.withValues(alpha: 0.9),
          size: r.sectionHeadingSize + 3,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: r.sectionHeadingSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SignInGate extends StatelessWidget {
  final VoidCallback onSignIn;
  final _OrdersResponsive r;
  const _SignInGate({required this.onSignIn, required this.r});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: r.cardPadding * 1.6,
        horizontal: r.cardPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _kAmber.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline,
              color: _kAmber.withValues(alpha: 0.8),
              size: 28,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Sign in to enter your shop and delivery details',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: r.bodySize,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kAmber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;
  final _OrdersResponsive r;
  final VoidCallback? onChanged;

  const _FormField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
    required this.r,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: r.labelSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: (_) => onChanged?.call(),
          style: TextStyle(color: Colors.white, fontSize: r.bodySize),
          cursorColor: _kAmber,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.04),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: _kAmber, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

/// Right pane — order line items (name, model if applicable, category,
/// quantity — no pricing shown), plus a total-quantity summary at the
/// bottom. (This on-screen card stays compact; the full-detail version
/// with brand/material/dimensions goes into the WhatsApp message and the
/// Firestore order record.)
class _OrdersSummaryPane extends StatelessWidget {
  final _OrdersResponsive r;
  final List<PendingOrderItem> items;
  final int totalUnits;
  final Map<String, String> categoryNames;

  const _OrdersSummaryPane({
    required this.r,
    required this.items,
    required this.totalUnits,
    required this.categoryNames,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.cardPadding),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PaneHeading(
                icon: Icons.shopping_bag_outlined,
                label: 'Order Items',
                r: r,
              ),
            ],
          ),
          SizedBox(height: r.sectionGap * 0.7),
          if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: r.cardPadding * 1.8),
              alignment: Alignment.center,
              child: Text(
                'No items yet — browse products and tap "Place Order" to add one here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: r.bodySize,
                  height: 1.5,
                ),
              ),
            )
          else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) => Divider(
                color: Colors.white.withValues(alpha: 0.06),
                height: r.sectionGap * 0.75,
              ),
              itemBuilder: (context, index) => _OrderRow(
                index: index,
                item: items[index],
                r: r,
                categoryName:
                    categoryNames[items[index].product.categoryId] ??
                    items[index].product.categoryId,
              ),
            ),
            SizedBox(height: r.sectionGap * 0.6),
            Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
            SizedBox(height: r.sectionGap * 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total quantity',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: r.labelSize,
                  ),
                ),
                Text(
                  '$totalUnits ${totalUnits == 1 ? 'unit' : 'units'}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: r.bodySize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final int index;
  final PendingOrderItem item;
  final _OrdersResponsive r;
  final String categoryName;
  const _OrderRow({
    required this.index,
    required this.item,
    required this.r,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final variant = item.variant;
    final thumbSize = r.stacked ? 52.0 : 60.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Container(
            width: thumbSize,
            height: thumbSize,
            color: Colors.white.withValues(alpha: 0.04),
            child: product.imageUrl.isNotEmpty
                ? Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    cacheWidth: (thumbSize * 2).round(),
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white38,
                      size: 20,
                    ),
                  )
                : const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.white38,
                    size: 20,
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: r.bodySize + 0.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              // Category, and — for products sold as multiple models
              // (e.g. kitchen baskets) — the specific model chosen, so
              // two lines for the same product are still distinguishable.
              Row(
                children: [
                  Flexible(
                    child: Text(
                      categoryName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: r.labelSize,
                      ),
                    ),
                  ),
                  if (variant != null) ...[
                    Text(
                      '  ·  ',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: r.labelSize,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        'Model ${variant.model}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _kAmber.withValues(alpha: 0.85),
                          fontSize: r.labelSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            'x${item.quantity}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: r.labelSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        _RemoveButton(onTap: () => OrderCartService.instance.removeAt(index)),
      ],
    );
  }
}

class _RemoveButton extends StatefulWidget {
  final VoidCallback onTap;
  const _RemoveButton({required this.onTap});

  @override
  State<_RemoveButton> createState() => _RemoveButtonState();
}

class _RemoveButtonState extends State<_RemoveButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Icon(
          Icons.close,
          size: 18,
          color: _isHovered
              ? Colors.redAccent
              : Colors.white.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _TermsAndSubmit extends StatelessWidget {
  final _OrdersResponsive r;
  final bool termsAccepted;
  final ValueChanged<bool> onTermsChanged;
  final bool canSubmit;
  final bool submitting;
  final AppUser? user;
  final bool itemsEmpty;
  final VoidCallback onSubmit;

  const _TermsAndSubmit({
    required this.r,
    required this.termsAccepted,
    required this.onTermsChanged,
    required this.canSubmit,
    required this.submitting,
    required this.user,
    required this.itemsEmpty,
    required this.onSubmit,
  });

  String get _buttonLabel {
    if (user == null) return 'Sign in to submit your order';
    if (itemsEmpty) return 'No items to submit';
    if (!termsAccepted) return 'Confirm details to submit';
    return 'Submit Order';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.cardPadding * 0.85),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: (user == null || itemsEmpty)
                ? null
                : () => onTermsChanged(!termsAccepted),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: termsAccepted,
                    onChanged: (user == null || itemsEmpty)
                        ? null
                        : (v) => onTermsChanged(v ?? false),
                    activeColor: _kAmber,
                    checkColor: Colors.black,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'I confirm the shop and delivery details above are correct.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: r.bodySize,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: r.sectionGap * 0.7),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (submitting || !canSubmit) ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kAmber,
                foregroundColor: Colors.black,
                disabledBackgroundColor: _kAmber.withValues(alpha: 0.25),
                disabledForegroundColor: Colors.black.withValues(alpha: 0.6),
                padding: EdgeInsets.symmetric(vertical: r.cardPadding * 0.55),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      _buttonLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: r.bodySize + 1,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
