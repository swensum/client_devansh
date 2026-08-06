import 'dart:async';
import 'package:devansh/homecomponents/topbar.dart';
import 'package:devansh/utils/navutils.dart';
import 'package:devansh/widgets/hoverwidgets.dart';
import 'package:url_launcher/link.dart';
import 'package:web/web.dart' as web;
import 'dart:ui';
import 'package:devansh/data/catalog.dart';

import 'package:devansh/models/catalogmodels.dart';
import 'package:devansh/models/authmodel.dart';
import 'package:devansh/services/catalogservice.dart';
import 'package:devansh/services/authservice.dart';

import 'package:devansh/services/orderservice.dart';
import 'package:flutter/material.dart';

const _gold = Color.fromRGBO(245, 171, 30, 1);

class _HeaderMetrics {
  final bool showNavRow;
  final bool showAccountText;
  final bool showSearchInHeader;
  final double horizontalPadding;
  final double logoHeight;
  final double logoWidth;
  final double searchWidth;
  final double iconSize;
  final double orderIconSize;
  final double hamburgerSize;
  final double gapSmall;
  final double gapMedium;
  final double gapLarge;

  const _HeaderMetrics({
    required this.showNavRow,
    required this.showAccountText,
    required this.showSearchInHeader,
    required this.horizontalPadding,
    required this.logoHeight,
    required this.logoWidth,
    required this.searchWidth,
    required this.iconSize,
    required this.orderIconSize,
    required this.hamburgerSize,
    required this.gapSmall,
    required this.gapMedium,
    required this.gapLarge,
  });

  bool get searchIsFlexible => searchWidth < 0;
  factory _HeaderMetrics.of(double width) {
    if (width >= 1120) {
      // Full desktop
      return const _HeaderMetrics(
        showNavRow: true,
        showAccountText: true,
        showSearchInHeader: true,
        horizontalPadding: 30,
        logoHeight: 50,
        logoWidth: 250,
        searchWidth: 250,
        iconSize: 40,
        orderIconSize: 30,
        hamburgerSize: 32,
        gapSmall: 20,
        gapMedium: 40,
        gapLarge: 60,
      );
    }
    if (width >= 700) {
      // Tablet / compact desktop — nav hidden, account text still shown
      return const _HeaderMetrics(
        showNavRow: false,
        showAccountText: true,
        showSearchInHeader: true,
        horizontalPadding: 30,
        logoHeight: 50,
        logoWidth: 250,
        searchWidth: 170,
        iconSize: 40,
        orderIconSize: 30,
        hamburgerSize: 32,
        gapSmall: 20,
        gapMedium: 40,
        gapLarge: 60,
      );
    }
    if (width >= 480) {
      // Tight phones/small tablets in landscape — search still fits, keep it
      return const _HeaderMetrics(
        showNavRow: false,
        showAccountText: false,
        showSearchInHeader: true,
        horizontalPadding: 10,
        logoHeight: 40,
        logoWidth: 150,
        searchWidth: 140,
        iconSize: 35,
        orderIconSize: 25,
        hamburgerSize: 32,
        gapSmall: 10,
        gapMedium: 10,
        gapLarge: 10,
      );
    }
    return const _HeaderMetrics(
      showNavRow: false,
      showAccountText: false,
      showSearchInHeader: false,
      horizontalPadding: 10,
      logoHeight: 32,
      logoWidth: 110,
      searchWidth: -1,
      iconSize: 28,
      orderIconSize: 22,
      hamburgerSize: 28,
      gapSmall: 6,
      gapMedium: 8,
      gapLarge: 8,
    );
  }
}

class SiteHeader extends StatefulWidget {
  final ScrollController scrollController;
  final double revealThreshold;

  const SiteHeader({
    super.key,
    required this.scrollController,
    this.revealThreshold = 4,
  });

  @override
  State<SiteHeader> createState() => _SiteHeaderState();
}

class _SiteHeaderState extends State<SiteHeader> {
  bool _showTopBar = true;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;
    final offset = widget.scrollController.offset;
    final show = offset <= widget.revealThreshold;
    if (show != _showTopBar && mounted) {
      setState(() => _showTopBar = show);
    }
  }

  @override
  void didUpdateWidget(covariant SiteHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_onScroll);
      widget.scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const totalHeight = TopBar.height + Header.height;

    return ClipRect(
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
        offset: _showTopBar
            ? Offset.zero
            : const Offset(0, -TopBar.height / totalHeight),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [TopBar(), Header()],
        ),
      ),
    );
  }
}

class Header extends StatefulWidget {
  const Header({super.key});

  static const double height = 100;

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  bool _isDisposed = false;
  int _hoveredIndex = -1;
  bool _hoveredAccount = false;
  bool _hoveredRegister = false;
  bool _hoveredLogin = false;
  bool _hoveredSignOut = false;
  bool _hoveredOrder = false;
  bool _hoveredPersonIcon = false;
  bool _hoveredHamburger = false;
  bool _hoveredLogo = false;
  int _openIndex = -1;

  final CatalogService _catalogService = CatalogService();
  List<Category> _categories = [];
  List<Product> _products = [];
  List<ProductType> _types = [];
  List<Company> _companies = [];

  StreamSubscription<List<Category>>? _categoriesSub;
  StreamSubscription<List<Product>>? _productsSub;
  StreamSubscription<List<ProductType>>? _typesSub;
  StreamSubscription<List<Company>>? _companiesSub;

  final Map<int, List<String>> _dropdownItems = {
    3: ["About Us", "Contact", "Blogs", "FAQs"],
  };
  static const Map<String, String> _pageRoutes = {
    "About Us": '/about',
    "Contact": '/contact',
    "Blogs": '/blog',
    "FAQs": '/faq',
  };
  final Map<int, LayerLink> _layerLinks = {
    1: LayerLink(),
    2: LayerLink(),
    3: LayerLink(),
  };

  String _shortLabel(String value, {int maxChars = 8}) {
    final trimmed = value.trim();
    if (trimmed.length <= maxChars) return trimmed;
    return '${trimmed.substring(0, maxChars)}...';
  }

  OverlayEntry? _overlayEntry;
  Timer? _closeTimer;

  OverlayEntry? _mobileMenuOverlay;
  final GlobalKey<_MobileSidebarState> _mobileSidebarKey =
      GlobalKey<_MobileSidebarState>();

  @override
  void initState() {
    super.initState();
    _categoriesSub = _catalogService.watchCategories().listen((data) {
      if (!_isDisposed) setState(() => _categories = data);
    });
    _productsSub = _catalogService.watchProducts().listen((data) {
      if (!_isDisposed) setState(() => _products = data);
    });
    _typesSub = _catalogService.watchProductTypes().listen((data) {
      if (!_isDisposed) setState(() => _types = data);
    });
    _companiesSub = _catalogService.watchCompanies().listen((data) {
      if (!_isDisposed) setState(() => _companies = data);
    });
  }

  void _cancelClose() {
    _closeTimer?.cancel();
    _closeTimer = null;
  }

  void _scheduleClose() {
    _closeTimer?.cancel();
    _closeTimer = Timer(const Duration(milliseconds: 150), _closeDropdown);
  }

  void _showDropdown(int index) {
    _cancelClose();
    if (_overlayEntry != null && _openIndex == index) return;
    _removeOverlay();
    _openIndex = index;

    final link = _layerLinks[index]!;
    final bool isShop = index == 1;
    final bool isCollection = index == 2;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _closeDropdown,
            child: Stack(
              children: [
                CompositedTransformFollower(
                  link: link,
                  showWhenUnlinked: false,
                  targetAnchor: Alignment.bottomLeft,
                  followerAnchor: Alignment.topLeft,
                  offset: const Offset(0, 15),
                  child: MouseRegion(
                    onEnter: (_) => _cancelClose(),
                    onExit: (_) => _scheduleClose(),
                    child: Material(
                      elevation: 8,
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            width: (isShop || isCollection) ? 220 : 180,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 20,
                                  offset: const Offset(2, 4),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: isShop
                                ? _ShopDropdownContent(
                                    categories: _categories,
                                    products: _products,
                                    types: _types,
                                    onNavigate: (route) {
                                      _closeDropdown();
                                      context.goSmart(route);
                                    },
                                  )
                                : isCollection
                                ? _CollectionDropdownContent(
                                    companies: _companies,
                                    onNavigate: (route) {
                                      _closeDropdown();
                                      context.goSmart(route);
                                    },
                                  )
                                : _DropdownList(
                                    items: _dropdownItems[index] ?? [],
                                    routeFor: (item) => _pageRoutes[item],
                                    onSelect: (item) {
                                      _closeDropdown();
                                      final route = _pageRoutes[item];
                                      if (route != null) {
                                        context.goSmart(route);
                                      }
                                    },
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _hoveredIndex = index);
  }

  void _closeDropdown() {
    _removeOverlay();
    if (!_isDisposed) setState(() => _hoveredIndex = -1);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _openIndex = -1;
  }

  void _toggleMobileMenu() {
    if (_mobileMenuOverlay != null) {
      _mobileSidebarKey.currentState?.close();
    } else {
      _openMobileMenu();
    }
  }

  void _openMobileMenu() {
    _removeMobileOverlay();

    _mobileMenuOverlay = OverlayEntry(
      builder: (context) {
        return _MobileSidebar(
          key: _mobileSidebarKey,
          categories: _categories,
          products: _products,
          types: _types,
          companies: _companies,
          dropdownItems: _dropdownItems,
          pageRoutes: _pageRoutes,
          onSelect: (item) {
            _mobileSidebarKey.currentState?.close();
            final route = _pageRoutes[item];
            if (route != null) context.goSmart(route);
          },
          onNavigate: (route) {
            _mobileSidebarKey.currentState?.close();
            context.goSmart(route);
          },
          onHome: () {
            _mobileSidebarKey.currentState?.close();
            _goHome();
          },
          onSearchSubmit: (query) {
            _mobileSidebarKey.currentState?.close();
            context.goSmart(_searchRouteFor(query));
          },
          onSelectProduct: (product) {
            _mobileSidebarKey.currentState?.close();
            _handleSearchProductSelected(product);
          },
          onClosed: _removeMobileOverlay,
        );
      },
    );

    Overlay.of(context).insert(_mobileMenuOverlay!);
    setState(() {});
  }

  void _removeMobileOverlay() {
    _mobileMenuOverlay?.remove();
    _mobileMenuOverlay = null;
    if (!_isDisposed) setState(() {});
  }

  Future<void> _handleSignOut() async {
    await AuthService.instance.signOut();
    web.window.location.reload();
  }

  void _goHome() {
    // Kept as a hard browser navigation (not goSmart) intentionally:
    // "logo tap" / "Home" is meant to feel like a full app reset from
    // anywhere, not just a route change.
    web.window.location.href = '/';
  }

  String _searchRouteFor(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return '/products';
    return '/products?search=${Uri.encodeQueryComponent(trimmed)}';
  }

  void _handleSearchSubmit(String query) {
    context.goSmart(_searchRouteFor(query));
  }

  void _handleSearchProductSelected(Product product) {
    // Drill-down (list/search -> detail): pushSmart so "back" returns to
    // where you were, but re-tapping the same product still reloads
    // instead of stacking a duplicate detail page.
    context.pushSmart('/product/${product.id}');
  }

  @override
  void dispose() {
    _isDisposed = true;
    _closeTimer?.cancel();
    _categoriesSub?.cancel();
    _productsSub?.cancel();
    _typesSub?.cancel();
    _companiesSub?.cancel();
    _removeOverlay();
    _removeMobileOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final m = _HeaderMetrics.of(constraints.maxWidth);

        return Container(
          height: Header.height,
          padding: EdgeInsets.symmetric(horizontal: m.horizontalPadding),
          color: const Color.fromARGB(255, 43, 43, 43),
          child: Row(
            children: [
              _LogoLink(
                hovered: _hoveredLogo,
                onEnter: () => setState(() => _hoveredLogo = true),
                onExit: () => setState(() => _hoveredLogo = false),
                onTap: _goHome,
                height: m.logoHeight,
                width: m.logoWidth,
              ),

              if (m.showNavRow) const Spacer(flex: 2) else const Spacer(),

              if (m.showNavRow)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMenuItem("Home", showArrow: false, index: 0),
                    SizedBox(width: m.gapMedium),
                    _buildMenuItem("Shop", showArrow: true, index: 1),
                    const SizedBox(width: 30),
                    _buildMenuItem("Collection", showArrow: true, index: 2),
                    const SizedBox(width: 30),
                    _buildMenuItem("Pages", showArrow: true, index: 3),
                  ],
                ),

              if (m.showSearchInHeader) ...[
                SizedBox(width: m.gapLarge),
                _SearchField(
                  flexible: m.searchIsFlexible,
                  width: m.searchWidth,
                  products: _products,
                  onSubmit: _handleSearchSubmit,
                  onSelectProduct: _handleSearchProductSelected,
                ),
              ],

              SizedBox(width: m.gapMedium),

              _AccountSection(
                showText: m.showAccountText,
                iconSize: m.iconSize,
                hoveredPersonIcon: _hoveredPersonIcon,
                hoveredAccount: _hoveredAccount,
                hoveredSignOut: _hoveredSignOut,
                hoveredRegister: _hoveredRegister,
                hoveredLogin: _hoveredLogin,
                shortLabel: _shortLabel,
                onPersonEnter: () => setState(() => _hoveredPersonIcon = true),
                onPersonExit: () => setState(() => _hoveredPersonIcon = false),
                onAccountEnter: () => setState(() => _hoveredAccount = true),
                onAccountExit: () => setState(() => _hoveredAccount = false),
                onSignOutEnter: () => setState(() => _hoveredSignOut = true),
                onSignOutExit: () => setState(() => _hoveredSignOut = false),
                onRegisterEnter: () => setState(() => _hoveredRegister = true),
                onRegisterExit: () => setState(() => _hoveredRegister = false),
                onLoginEnter: () => setState(() => _hoveredLogin = true),
                onLoginExit: () => setState(() => _hoveredLogin = false),
                onSignOut: _handleSignOut,
                onGoAuth: () => context.goSmart('/auth'),
              ),

              SizedBox(width: m.gapSmall),

              _OrdersLink(
                hovered: _hoveredOrder,
                onEnter: () => setState(() => _hoveredOrder = true),
                onExit: () => setState(() => _hoveredOrder = false),
                iconSize: m.orderIconSize,
              ),

              if (!m.showNavRow) ...[
                SizedBox(width: m.gapSmall),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _hoveredHamburger = true),
                  onExit: (_) => setState(() => _hoveredHamburger = false),
                  child: GestureDetector(
                    onTap: _toggleMobileMenu,
                    child: Icon(
                      Icons.menu,
                      color: _hoveredHamburger ? _gold : Colors.white,
                      size: m.hamburgerSize,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    String title, {
    required bool showArrow,
    required int index,
  }) {
    final isHovered = _hoveredIndex == index;
    final Color itemColor = isHovered ? _gold : Colors.white;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            color: itemColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (showArrow) ...[
          const SizedBox(width: 2),
          Icon(
            isHovered ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: itemColor,
            size: 22,
          ),
        ],
      ],
    );

    if (!showArrow) {
      // "Home" — a genuine navigational link (goes to '/'), so give it a
      // real <a href="/"> via Link, same click behavior as before.
      return Link(
        uri: Uri.parse('/'),
        builder: (context, followLink) {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hoveredIndex = index),
            onExit: (_) => setState(() => _hoveredIndex = -1),
            child: GestureDetector(onTap: _goHome, child: content),
          );
        },
      );
    }

    // Shop/Collection/Pages are dropdown *triggers*, not direct links —
    // they open a menu on hover rather than navigating anywhere
    // themselves, so there's no single destination URL to give them.
    // The real links live inside each dropdown's items instead.
    return CompositedTransformTarget(
      link: _layerLinks[index]!,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _showDropdown(index),
        onExit: (_) => _scheduleClose(),
        child: content,
      ),
    );
  }
}

/// Logo — doubles as the "go home" link. Wrapped in Link so it renders as
/// a real <a href="/">, giving the standard browser hover/right-click
/// link behavior, while still triggering the intentional hard reload.
class _LogoLink extends StatelessWidget {
  final bool hovered;
  final VoidCallback onEnter;
  final VoidCallback onExit;
  final VoidCallback onTap;
  final double height;
  final double width;

  const _LogoLink({
    required this.hovered,
    required this.onEnter,
    required this.onExit,
    required this.onTap,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Link(
      uri: Uri.parse('/'),
      builder: (context, followLink) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => onEnter(),
          onExit: (_) => onExit(),
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: hovered ? 0.85 : 1.0,
              child: Image.asset(
                'assets/logo.png',
                height: height,
                width: width,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Orders icon — real link to /orders.
class _OrdersLink extends StatelessWidget {
  final bool hovered;
  final VoidCallback onEnter;
  final VoidCallback onExit;
  final double iconSize;

  const _OrdersLink({
    required this.hovered,
    required this.onEnter,
    required this.onExit,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Link(
      uri: Uri.parse('/orders'),
      builder: (context, followLink) {
        return GestureDetector(
          onTap: () => context.goSmart('/orders'),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => onEnter(),
            onExit: (_) => onExit(),
            child: ValueListenableBuilder<List<PendingOrderItem>>(
              valueListenable: OrderCartService.instance.items,
              builder: (context, pendingItems, _) {
                final count = pendingItems.length;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      color: hovered ? _gold : Colors.white,
                      size: iconSize,
                    ),
                    if (count > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          decoration: BoxDecoration(
                            color: _gold,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF1A1A1A),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            '$count',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _SearchField extends StatefulWidget {
  final bool flexible;
  final double width;
  final List<Product> products;
  final void Function(String query) onSubmit;
  final void Function(Product product) onSelectProduct;

  const _SearchField({
    required this.flexible,
    required this.width,
    required this.products,
    required this.onSubmit,
    required this.onSelectProduct,
  });

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<Product> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChanged);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _updateSuggestions(_controller.text);
    } else {
      // Small delay so a tap on a suggestion registers as a tap before the
      // overlay disappears out from under it.
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted && !_focusNode.hasFocus) _removeOverlay();
      });
    }
  }

  void _onTextChanged() {
    setState(() {}); // refresh the clear (x) button visibility
    _updateSuggestions(_controller.text);
  }

  void _updateSuggestions(String query) {
    final trimmed = query.trim().toLowerCase();
    _suggestions = trimmed.isEmpty
        ? []
        : widget.products
              .where((p) => p.name.toLowerCase().contains(trimmed))
              .take(6)
              .toList();
    _showOverlay();
  }

  void _showOverlay() {
    _removeOverlay();
    if (_suggestions.isEmpty || !_focusNode.hasFocus) return;

    final overlayWidth = widget.flexible
        ? (context.findRenderObject() as RenderBox?)?.size.width ?? 200
        : widget.width;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: overlayWidth,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 44),
            child: Material(
              elevation: 8,
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, i) {
                    final product = _suggestions[i];
                    return _SearchSuggestionRow(
                      name: product.name,
                      query: _controller.text,
                      onTap: () {
                        _controller.clear();
                        _removeOverlay();
                        _focusNode.unfocus();
                        widget.onSelectProduct(product);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _submit() {
    _removeOverlay();
    _focusNode.unfocus();
    widget.onSubmit(_controller.text);
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_onFocusChange);
    _controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: _controller,
      focusNode: _focusNode,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => _submit(),
      decoration: InputDecoration(
        hintText: "Search...",
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: widget.flexible ? 13 : 14,
        ),
        filled: true,
        fillColor: Colors.white,
        isDense: widget.flexible,
        prefixIcon: GestureDetector(
          onTap: _submit,
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search,
              color: Colors.white,
              size: widget.flexible ? 16 : 18,
            ),
          ),
        ),
        suffixIcon: _controller.text.isEmpty
            ? null
            : GestureDetector(
                onTap: () {
                  _controller.clear();
                  _updateSuggestions('');
                },
                child: const Icon(Icons.close, color: Colors.black45, size: 16),
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );

    final sized = SizedBox(height: widget.flexible ? 36 : 38, child: field);

    return CompositedTransformTarget(
      link: _layerLink,
      child: widget.flexible
          ? Expanded(child: sized)
          : SizedBox(width: widget.width, child: sized),
    );
  }
}

class _SearchSuggestionRow extends StatelessWidget {
  final String name;
  final String query;
  final VoidCallback onTap;

  const _SearchSuggestionRow({
    required this.name,
    required this.query,
    required this.onTap,
  });

  List<TextSpan> _highlightedSpans(bool isHovered) {
    final baseStyle = TextStyle(
      color: isHovered ? _gold : Colors.white,
      fontSize: 13.5,
    );
    final matchStyle = baseStyle.copyWith(
      color: _gold,
      fontWeight: FontWeight.w700,
    );

    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return [TextSpan(text: name, style: baseStyle)];
    }

    final lowerName = name.toLowerCase();
    final lowerQuery = trimmedQuery.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;

    while (true) {
      final matchIndex = lowerName.indexOf(lowerQuery, start);
      if (matchIndex == -1) {
        spans.add(TextSpan(text: name.substring(start), style: baseStyle));
        break;
      }
      if (matchIndex > start) {
        spans.add(
          TextSpan(text: name.substring(start, matchIndex), style: baseStyle),
        );
      }
      spans.add(
        TextSpan(
          text: name.substring(matchIndex, matchIndex + lowerQuery.length),
          style: matchStyle,
        ),
      );
      start = matchIndex + lowerQuery.length;
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return HoverRegion(
      onTap: onTap,
      builder: (context, hovered) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        color: hovered ? _gold.withValues(alpha: 0.12) : Colors.transparent,
        child: RichText(
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          text: TextSpan(children: _highlightedSpans(hovered)),
        ),
      ),
    );
  }
}

/// Account/person section — collapses to icon-only on narrow widths.
class _AccountSection extends StatelessWidget {
  final bool showText;
  final double iconSize;
  final bool hoveredPersonIcon;
  final bool hoveredAccount;
  final bool hoveredSignOut;
  final bool hoveredRegister;
  final bool hoveredLogin;
  final String Function(String, {int maxChars}) shortLabel;
  final VoidCallback onPersonEnter;
  final VoidCallback onPersonExit;
  final VoidCallback onAccountEnter;
  final VoidCallback onAccountExit;
  final VoidCallback onSignOutEnter;
  final VoidCallback onSignOutExit;
  final VoidCallback onRegisterEnter;
  final VoidCallback onRegisterExit;
  final VoidCallback onLoginEnter;
  final VoidCallback onLoginExit;
  final VoidCallback onSignOut;
  final VoidCallback onGoAuth;

  const _AccountSection({
    required this.showText,
    required this.iconSize,
    required this.hoveredPersonIcon,
    required this.hoveredAccount,
    required this.hoveredSignOut,
    required this.hoveredRegister,
    required this.hoveredLogin,
    required this.shortLabel,
    required this.onPersonEnter,
    required this.onPersonExit,
    required this.onAccountEnter,
    required this.onAccountExit,
    required this.onSignOutEnter,
    required this.onSignOutExit,
    required this.onRegisterEnter,
    required this.onRegisterExit,
    required this.onLoginEnter,
    required this.onLoginExit,
    required this.onSignOut,
    required this.onGoAuth,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppUser?>(
      valueListenable: AuthService.instance.currentUser,
      builder: (context, user, _) {
        final signedIn = user != null;
        final accountLabel = signedIn
            ? shortLabel(
                user.name?.isNotEmpty == true
                    ? user.name!
                    : (user.email ?? 'My Account'),
              )
            : 'Account';

        return SizedBox(
          height: 80,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AuthLinkWrap(
                enabled: !signedIn,
                onTap: onGoAuth,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => onPersonEnter(),
                  onExit: (_) => onPersonExit(),
                  child: Icon(
                    Icons.person,
                    color: (hoveredPersonIcon || signedIn)
                        ? _gold
                        : Colors.white,
                    size: iconSize,
                  ),
                ),
              ),
              if (showText) ...[
                const SizedBox(width: 5),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AuthLinkWrap(
                      enabled: !signedIn,
                      onTap: onGoAuth,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        onEnter: (_) => onAccountEnter(),
                        onExit: (_) => onAccountExit(),
                        child: Text(
                          accountLabel,
                          style: TextStyle(
                            color: hoveredAccount ? _gold : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    if (!signedIn)
                      Row(
                        children: [
                          _authLink(
                            "Register",
                            hoveredRegister,
                            onRegisterEnter,
                            onRegisterExit,
                            onGoAuth,
                          ),
                          const Text(
                            " | ",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          _authLink(
                            "Login",
                            hoveredLogin,
                            onLoginEnter,
                            onLoginExit,
                            onGoAuth,
                          ),
                        ],
                      )
                    else
                      GestureDetector(
                        onTap: onSignOut,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          onEnter: (_) => onSignOutEnter(),
                          onExit: (_) => onSignOutExit(),
                          child: Text(
                            "Sign out",
                            style: TextStyle(
                              color: hoveredSignOut ? _gold : Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _authLink(
    String title,
    bool hovered,
    VoidCallback onEnter,
    VoidCallback onExit,
    VoidCallback onTap,
  ) {
    // Register/Login both go to /auth — real link.
    return Link(
      uri: Uri.parse('/auth'),
      builder: (context, followLink) {
        return GestureDetector(
          onTap: onTap,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => onEnter(),
            onExit: (_) => onExit(),
            child: Text(
              title,
              style: TextStyle(
                color: hovered ? _gold : Colors.white70,
                fontSize: 11,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Wraps a widget in a real /auth link only while relevant (i.e. while
/// signed out — once signed in, the person icon/name are no longer a
/// navigational link).
class _AuthLinkWrap extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  final Widget child;

  const _AuthLinkWrap({
    required this.enabled,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return GestureDetector(onTap: () {}, child: child);
    }
    return Link(
      uri: Uri.parse('/auth'),
      builder: (context, followLink) {
        return GestureDetector(onTap: onTap, child: child);
      },
    );
  }
}

class _ShopDropdownContent extends StatelessWidget {
  final List<Category> categories;
  final List<Product> products;
  final List<ProductType> types;
  final void Function(String route) onNavigate;

  const _ShopDropdownContent({
    required this.categories,
    required this.products,
    required this.types,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return _DropdownColumn(
      title: 'Categories',
      children: [
        for (final category in categories) ...[
          _DropdownColumnRow(
            item: _DropdownColumnItem(
              label: category.name,
              route: '/products?category=${category.id}',
              onTap: () => onNavigate('/products?category=${category.id}'),
            ),
          ),
          for (final type in Catalog.typesInCategory(
            products,
            types,
            category.id,
          ))
            _DropdownColumnRow(
              item: _DropdownColumnItem(
                label: '- ${type.name}',
                route: '/products?category=${category.id}&type=${type.id}',
                onTap: () => onNavigate(
                  '/products?category=${category.id}&type=${type.id}',
                ),
              ),
              isSubItem: true,
            ),
        ],
      ],
    );
  }
}

class _CollectionDropdownContent extends StatelessWidget {
  final List<Company> companies;
  final void Function(String route) onNavigate;

  const _CollectionDropdownContent({
    required this.companies,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final visibleCompanies = companies
        .where((c) => c.id != 'unknown' && c.id != 'others')
        .toList();

    return _DropdownColumn(
      title: 'Companies',
      children: [
        for (final company in visibleCompanies)
          _DropdownColumnRow(
            item: _DropdownColumnItem(
              label: company.name,
              route: '/products?company=${company.id}',
              onTap: () => onNavigate('/products?company=${company.id}'),
            ),
          ),
      ],
    );
  }
}

class _DropdownColumnItem {
  final String label;
  final String route;
  final VoidCallback onTap;
  const _DropdownColumnItem({
    required this.label,
    required this.route,
    required this.onTap,
  });
}

class _DropdownColumn extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _DropdownColumn({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: _gold,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 8),
      ],
    );
  }
}

class _DropdownColumnRow extends StatelessWidget {
  final _DropdownColumnItem item;
  final bool isSubItem;

  const _DropdownColumnRow({required this.item, this.isSubItem = false});

  @override
  Widget build(BuildContext context) {
    final row = HoverRegion(
      onTap: item.onTap,
      builder: (context, hovered) => Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          left: isSubItem ? 28 : 16,
          right: 16,
          top: isSubItem ? 6 : 8,
          bottom: isSubItem ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: hovered ? _gold.withValues(alpha: 0.15) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: hovered ? _gold : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          item.label,
          style: TextStyle(
            color: hovered
                ? _gold
                : (isSubItem ? Colors.white70 : Colors.white),
            fontSize: isSubItem ? 12.5 : 13.5,
            fontWeight: isSubItem ? FontWeight.w400 : FontWeight.w500,
          ),
        ),
      ),
    );

    // Every category/type/company row is a genuine destination — wrap in
    // Link for a real <a href>, keep HoverRegion's own onTap for the
    // actual SPA navigation (goSmart), same pattern as the footer.
    return Link(
      uri: Uri.parse(item.route),
      builder: (context, followLink) => row,
    );
  }
}

class _DropdownList extends StatelessWidget {
  final List<String> items;
  final String? Function(String item) routeFor;
  final void Function(String item) onSelect;

  const _DropdownList({
    required this.items,
    required this.routeFor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        final row = HoverRegion(
          onTap: () => onSelect(item),
          builder: (context, hovered) => Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: hovered
                  ? _gold.withValues(alpha: 0.1)
                  : Colors.transparent,
              border: Border(
                right: BorderSide(
                  color: hovered ? _gold : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Text(
              item,
              style: TextStyle(
                color: hovered ? _gold : Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        );

        final route = routeFor(item);
        if (route == null) return row;

        return Link(
          uri: Uri.parse(route),
          builder: (context, followLink) => row,
        );
      }).toList(),
    );
  }
}

class _MobileSidebar extends StatefulWidget {
  final List<Category> categories;
  final List<Product> products;
  final List<ProductType> types;
  final List<Company> companies;
  final Map<int, List<String>> dropdownItems;
  final Map<String, String> pageRoutes;
  final void Function(String item) onSelect;
  final void Function(String route) onNavigate;
  final VoidCallback onHome;
  final void Function(String query) onSearchSubmit;
  final void Function(Product product) onSelectProduct;
  final VoidCallback onClosed;

  const _MobileSidebar({
    super.key,
    required this.categories,
    required this.products,
    required this.types,
    required this.companies,
    required this.dropdownItems,
    required this.pageRoutes,
    required this.onSelect,
    required this.onNavigate,
    required this.onHome,
    required this.onSearchSubmit,
    required this.onSelectProduct,
    required this.onClosed,
  });

  @override
  State<_MobileSidebar> createState() => _MobileSidebarState();
}

class _MobileSidebarState extends State<_MobileSidebar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  final TextEditingController _searchController = TextEditingController();
  List<Product> _suggestions = [];

  static const double _sidebarWidth = 280;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _slide = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
    _searchController.addListener(_updateSuggestions);
  }

  void _updateSuggestions() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _suggestions = query.isEmpty
          ? []
          : widget.products
                .where((p) => p.name.toLowerCase().contains(query))
                .take(6)
                .toList();
    });
  }

  Future<void> close() async {
    if (_controller.status == AnimationStatus.reverse ||
        _controller.status == AnimationStatus.dismissed) {
      return;
    }
    await _controller.reverse();
    widget.onClosed();
  }

  void _submitSearch() {
    widget.onSearchSubmit(_searchController.text);
  }

  void _selectSuggestion(Product product) {
    _searchController.clear();
    widget.onSelectProduct(product);
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.removeListener(_updateSuggestions);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          FadeTransition(
            opacity: _controller,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: close,
              child: Container(color: Colors.black.withValues(alpha: 0.45)),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: SlideTransition(
              position: _slide,
              child: SizedBox(
                width: _sidebarWidth,
                height: double.infinity,
                child: Row(
                  children: [
                    Container(width: 3, color: _gold),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                        ),
                        child: Material(
                          elevation: 16,
                          color: const Color(0xFF1A1A1A),
                          child: SafeArea(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    12,
                                    8,
                                    8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Menu",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: close,
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                            ),
                                            splashRadius: 20,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 1),
                                      Container(
                                        height: 2,
                                        width: 30,
                                        color: _gold,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Search — lives here instead of the header
                                // row on mobile, where there's no room for it.
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: SizedBox(
                                    height: 40,
                                    child: TextField(
                                      controller: _searchController,
                                      textInputAction: TextInputAction.search,
                                      onSubmitted: (_) => _submitSearch(),
                                      decoration: InputDecoration(
                                        hintText: "Search...",
                                        hintStyle: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        isDense: true,
                                        prefixIcon: GestureDetector(
                                          onTap: _submitSearch,
                                          child: Container(
                                            margin: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: Colors.black,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.search,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                        suffixIcon:
                                            _searchController.text.isEmpty
                                            ? null
                                            : GestureDetector(
                                                onTap: () {
                                                  _searchController.clear();
                                                },
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.black45,
                                                  size: 16,
                                                ),
                                              ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Live suggestions — shown inline (not as a
                                // floating overlay) since the sidebar is
                                // already its own scrollable panel.
                                if (_suggestions.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      6,
                                      16,
                                      0,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF262626),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          for (final product in _suggestions)
                                            _SearchSuggestionRow(
                                              name: product.name,
                                              query: _searchController.text,
                                              onTap: () =>
                                                  _selectSuggestion(product),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 14),
                                const Divider(
                                  height: 1,
                                  color: Color(0xFF444444),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: _MobileNavMenu(
                                      categories: widget.categories,
                                      products: widget.products,
                                      types: widget.types,
                                      companies: widget.companies,
                                      dropdownItems: widget.dropdownItems,
                                      pageRoutes: widget.pageRoutes,
                                      onSelect: widget.onSelect,
                                      onNavigate: widget.onNavigate,
                                      onHome: widget.onHome,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Wraps a ListTile's normal onTap in a real <a href> for the given
/// route, so mobile menu items behave like genuine links too — hover
/// preview doesn't really apply on touch devices, but this still gives
/// crawlers and "long-press > open in new tab" style behavior on mobile
/// browsers, and is consistent with the rest of the site.
class _LinkedListTile extends StatelessWidget {
  final String route;
  final Widget child;
  const _LinkedListTile({required this.route, required this.child});

  @override
  Widget build(BuildContext context) {
    return Link(uri: Uri.parse(route), builder: (context, followLink) => child);
  }
}

class _MobileNavMenu extends StatelessWidget {
  final List<Category> categories;
  final List<Product> products;
  final List<ProductType> types;
  final List<Company> companies;
  final Map<int, List<String>> dropdownItems;
  final Map<String, String> pageRoutes;
  final void Function(String item) onSelect;
  final void Function(String route) onNavigate;
  final VoidCallback onHome;

  const _MobileNavMenu({
    required this.categories,
    required this.products,
    required this.types,
    required this.companies,
    required this.dropdownItems,
    required this.pageRoutes,
    required this.onSelect,
    required this.onNavigate,
    required this.onHome,
  });

  static const List<String> _labels = ["Home", "Shop", "Collection", "Pages"];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _labels.asMap().entries.map((entry) {
        final index = entry.key;
        final label = entry.value;

        if (index == 1) {
          return ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            iconColor: Colors.white,
            collapsedIconColor: Colors.white70,
            title: const Text(
              "Shop",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            children: [
              for (final category in categories) ...[
                _LinkedListTile(
                  route: '/products?category=${category.id}',
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.only(left: 32, right: 16),
                    title: Text(
                      category.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () =>
                        onNavigate('/products?category=${category.id}'),
                  ),
                ),
                for (final type in Catalog.typesInCategory(
                  products,
                  types,
                  category.id,
                ))
                  _LinkedListTile(
                    route: '/products?category=${category.id}&type=${type.id}',
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.only(
                        left: 48,
                        right: 16,
                      ),
                      title: Text(
                        type.name,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                        ),
                      ),
                      onTap: () => onNavigate(
                        '/products?category=${category.id}&type=${type.id}',
                      ),
                    ),
                  ),
              ],
            ],
          );
        }

        if (index == 2) {
          final visibleCompanies = companies
              .where((c) => c.id != 'unknown' && c.id != 'others')
              .toList();

          return ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            iconColor: Colors.white,
            collapsedIconColor: Colors.white70,
            title: const Text(
              "Collection",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            children: [
              for (final company in visibleCompanies)
                _LinkedListTile(
                  route: '/products?company=${company.id}',
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.only(left: 32, right: 16),
                    title: Text(
                      company.name,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    onTap: () => onNavigate('/products?company=${company.id}'),
                  ),
                ),
            ],
          );
        }

        final subItems = dropdownItems[index];

        if (subItems == null) {
          // "Home"
          return _LinkedListTile(
            route: '/',
            child: ListTile(
              dense: true,
              title: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              onTap: onHome,
            ),
          );
        }

        return ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          iconColor: Colors.white,
          collapsedIconColor: Colors.white70,
          title: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          children: subItems.map((item) {
            final route = pageRoutes[item];
            final tile = ListTile(
              dense: true,
              contentPadding: const EdgeInsets.only(left: 32, right: 16),
              title: Text(
                item,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              onTap: () => onSelect(item),
            );
            return route == null
                ? tile
                : _LinkedListTile(route: route, child: tile);
          }).toList(),
        );
      }).toList(),
    );
  }
}
