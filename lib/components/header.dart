import 'dart:async';
import 'package:devansh/components/topbar.dart';
import 'package:web/web.dart' as web;
import 'dart:ui';
import 'package:devansh/data/catalog.dart';

import 'package:devansh/models/catalogmodels.dart';
import 'package:devansh/models/authmodel.dart';
import 'package:devansh/services/catalogservice.dart';
import 'package:devansh/services/authservice.dart';

import 'package:devansh/services/orderservice.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _gold = Color.fromRGBO(245, 171, 30, 1);

/// -------------------------------------------------------------------------
/// Single source of truth for every size/spacing value the header uses.
///
/// Instead of repeating `isTight ? a : (isCompact ? b : c)` all over build(),
/// we compute ONE of these from the available width, then every widget below
/// just reads plain fields like `m.logoHeight` or `m.iconSize`.
///
/// To change how the header looks at a given width, edit this class only —
/// nothing else in the file needs to know about breakpoints at all.
/// -------------------------------------------------------------------------
class _HeaderMetrics {
  final bool showNavRow; // full desktop nav vs hamburger menu
  final bool showAccountText; // name/register/login text next to person icon
  final bool
  showSearchInHeader; // false on mobile — search moves into the sidebar instead
  final double horizontalPadding;
  final double logoHeight;
  final double logoWidth;
  final double searchWidth; // null-ish sentinel: -1 means "flexible/Expanded"
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

  /// The three tiers below are the only breakpoints in the whole header.
  /// Add/adjust a tier here if you need a new size step.
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
    // True mobile — search field moves into the sidebar entirely, so the
    // header row only has logo + account icon + order icon + hamburger,
    // none of which can overflow.
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
                                      context.push(route);
                                    },
                                  )
                                : isCollection
                                ? _CollectionDropdownContent(
                                    companies: _companies,
                                    onNavigate: (route) {
                                      _closeDropdown();
                                      context.push(route);
                                    },
                                  )
                                : _DropdownList(
                                    items: _dropdownItems[index] ?? [],
                                    onSelect: (item) {
                                      _closeDropdown();
                                      final route = _pageRoutes[item];
                                      if (route != null) context.push(route);
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
          onSelect: (item) {
            _mobileSidebarKey.currentState?.close();
            final route = _pageRoutes[item];
            if (route != null) context.push(route);
          },
          onNavigate: (route) {
            _mobileSidebarKey.currentState?.close();
            context.push(route);
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

  void _reloadHome() => web.window.location.reload();

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
          color: const Color(0xFF1A1A1A),
          child: Row(
            children: [
              Image.asset(
                'assets/logo.png',
                height: m.logoHeight,
                width: m.logoWidth,
                fit: BoxFit.contain,
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
                onGoAuth: () => context.push('/auth'),
              ),

              SizedBox(width: m.gapSmall),

              GestureDetector(
                onTap: () => context.push('/orders'),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _hoveredOrder = true),
                  onExit: (_) => setState(() => _hoveredOrder = false),
                  child: ValueListenableBuilder<List<PendingOrderItem>>(
                    valueListenable: OrderCartService.instance.items,
                    builder: (context, pendingItems, _) {
                      final count = pendingItems.length;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            color: _hoveredOrder ? _gold : Colors.white,
                            size: m.orderIconSize,
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
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hoveredIndex = index),
        onExit: (_) => setState(() => _hoveredIndex = -1),
        child: GestureDetector(onTap: _reloadHome, child: content),
      );
    }

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

/// Search box — either a fixed width (tablet/desktop) or Expanded/flexible
/// (mobile), controlled entirely by the metrics object above.
class _SearchField extends StatelessWidget {
  final bool flexible;
  final double width;

  const _SearchField({required this.flexible, required this.width});

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      decoration: InputDecoration(
        hintText: "Search...",
        hintStyle: TextStyle(color: Colors.grey, fontSize: flexible ? 13 : 14),
        filled: true,
        fillColor: Colors.white,
        isDense: flexible,
        prefixIcon: Container(
          margin: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.search,
            color: Colors.white,
            size: flexible ? 16 : 18,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );

    final sized = SizedBox(height: flexible ? 36 : 38, child: field);

    return flexible
        ? Expanded(child: sized)
        : SizedBox(width: width, child: sized);
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
              GestureDetector(
                onTap: () {
                  if (!signedIn) onGoAuth();
                },
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
                    GestureDetector(
                      onTap: () {
                        if (!signedIn) onGoAuth();
                      },
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
              onTap: () => onNavigate('/products?company=${company.id}'),
            ),
          ),
      ],
    );
  }
}

class _DropdownColumnItem {
  final String label;
  final VoidCallback onTap;
  const _DropdownColumnItem({required this.label, required this.onTap});
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

class _DropdownColumnRow extends StatefulWidget {
  final _DropdownColumnItem item;
  final bool isSubItem;

  const _DropdownColumnRow({required this.item, this.isSubItem = false});

  @override
  State<_DropdownColumnRow> createState() => _DropdownColumnRowState();
}

class _DropdownColumnRowState extends State<_DropdownColumnRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.item.onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            left: widget.isSubItem ? 28 : 16,
            right: 16,
            top: widget.isSubItem ? 6 : 8,
            bottom: widget.isSubItem ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? _gold.withValues(alpha: 0.15)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: _isHovered ? _gold : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            widget.item.label,
            style: TextStyle(
              color: _isHovered
                  ? _gold
                  : (widget.isSubItem ? Colors.white70 : Colors.white),
              fontSize: widget.isSubItem ? 12.5 : 13.5,
              fontWeight: widget.isSubItem ? FontWeight.w400 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownList extends StatefulWidget {
  final List<String> items;
  final void Function(String item) onSelect;

  const _DropdownList({required this.items, required this.onSelect});

  @override
  State<_DropdownList> createState() => _DropdownListState();
}

class _DropdownListState extends State<_DropdownList> {
  int _hoveredItem = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.items.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        final isHovered = _hoveredItem == i;

        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredItem = i),
          onExit: (_) => setState(() => _hoveredItem = -1),
          child: GestureDetector(
            onTap: () => widget.onSelect(item),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isHovered
                    ? _gold.withValues(alpha: 0.1)
                    : Colors.transparent,
                border: Border(
                  right: BorderSide(
                    color: isHovered ? _gold : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                item,
                style: TextStyle(
                  color: isHovered ? _gold : Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
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
  final void Function(String item) onSelect;
  final void Function(String route) onNavigate;
  final VoidCallback onClosed;

  const _MobileSidebar({
    super.key,
    required this.categories,
    required this.products,
    required this.types,
    required this.companies,
    required this.dropdownItems,
    required this.onSelect,
    required this.onNavigate,
    required this.onClosed,
  });

  @override
  State<_MobileSidebar> createState() => _MobileSidebarState();
}

class _MobileSidebarState extends State<_MobileSidebar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;

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
  }

  Future<void> close() async {
    if (_controller.status == AnimationStatus.reverse ||
        _controller.status == AnimationStatus.dismissed) {
      return;
    }
    await _controller.reverse();
    widget.onClosed();
  }

  @override
  void dispose() {
    _controller.dispose();
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
                                      decoration: InputDecoration(
                                        hintText: "Search...",
                                        hintStyle: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        isDense: true,
                                        prefixIcon: Container(
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
                                      onSelect: widget.onSelect,
                                      onNavigate: widget.onNavigate,
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

class _MobileNavMenu extends StatelessWidget {
  final List<Category> categories;
  final List<Product> products;
  final List<ProductType> types;
  final List<Company> companies;
  final Map<int, List<String>> dropdownItems;
  final void Function(String item) onSelect;
  final void Function(String route) onNavigate;

  const _MobileNavMenu({
    required this.categories,
    required this.products,
    required this.types,
    required this.companies,
    required this.dropdownItems,
    required this.onSelect,
    required this.onNavigate,
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
                ListTile(
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
                  onTap: () => onNavigate('/products?category=${category.id}'),
                ),
                for (final type in Catalog.typesInCategory(
                  products,
                  types,
                  category.id,
                ))
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.only(left: 48, right: 16),
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
                ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.only(left: 32, right: 16),
                  title: Text(
                    company.name,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  onTap: () => onNavigate('/products?company=${company.id}'),
                ),
            ],
          );
        }

        final subItems = dropdownItems[index];

        if (subItems == null) {
          return ListTile(
            dense: true,
            title: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            onTap: () => web.window.location.reload(),
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
          children: subItems
              .map(
                (item) => ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.only(left: 32, right: 16),
                  title: Text(
                    item,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  onTap: () => onSelect(item),
                ),
              )
              .toList(),
        );
      }).toList(),
    );
  }
}
