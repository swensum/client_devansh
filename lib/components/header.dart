import 'dart:async';
import 'dart:ui';
import 'package:devansh/data/catalog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  static const double _navBreakpoint = 1120;
  static const double _compactBreakpoint = 820;
  static const double _tightBreakpoint = 620;
  bool _isDisposed = false;
  int _hoveredIndex = -1;
  bool _hoveredAccount = false;
  bool _hoveredRegister = false;
  bool _hoveredLogin = false;
  bool _hoveredOrder = false;
  bool _hoveredPersonIcon = false;
  bool _hoveredHamburger = false;
  int _openIndex = -1;

  // Dropdown data for the simple single-column menus (Collection, Pages).
  final Map<int, List<String>> _dropdownItems = {
    2: ["New Arrivals", "Best Sellers", "Special Offers", "Seasonal"],
    3: ["About Us", "Contact", "FAQs", "Shipping Info", "Terms & Conditions"],
  };
  final Map<int, LayerLink> _layerLinks = {
    1: LayerLink(),
    2: LayerLink(),
    3: LayerLink(),
  };

  OverlayEntry? _overlayEntry;
  Timer? _closeTimer;

  // Mobile sidebar menu
  OverlayEntry? _mobileMenuOverlay;
  final GlobalKey<_MobileSidebarState> _mobileSidebarKey =
      GlobalKey<_MobileSidebarState>();

  void _cancelClose() {
    _closeTimer?.cancel();
    _closeTimer = null;
  }

  void _scheduleClose() {
    _closeTimer?.cancel();
    _closeTimer = Timer(const Duration(milliseconds: 150), () {
      _closeDropdown();
    });
  }

  void _showDropdown(int index) {
  _cancelClose();
  if (_overlayEntry != null && _openIndex == index) return; // already open
  _removeOverlay();
  _openIndex = index;

  final link = _layerLinks[index]!;
  final bool isShop = index == 1;

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
                offset: const Offset(0, 15), // small gap below the menu item
                child: MouseRegion(
                  onEnter: (_) => _cancelClose(),
                  onExit: (_) => _scheduleClose(),
                  child: Material(
                    elevation: 8,
                    color: Colors.transparent, // let the glass show through, not Material's default surface
                    borderRadius: BorderRadius.circular(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          width: isShop ? 420 : 180,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15), // frosted glass tint
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
                                  onNavigate: (route) {
                                    _closeDropdown();
                                    context.push(route);
                                  },
                                )
                              : _DropdownList(
                                  items: _dropdownItems[index] ?? [],
                                  onSelect: (item) {
                                    _closeDropdown();
                                    print('Selected: $item');
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
          dropdownItems: _dropdownItems,
          onSelect: (item) {
            _mobileSidebarKey.currentState?.close();
            print('Selected: $item');
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
    if (!_isDisposed) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _closeTimer?.cancel();
    _removeOverlay();
    _removeMobileOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < _navBreakpoint;
        final bool isCompact = constraints.maxWidth < _compactBreakpoint;
        final bool isTight = constraints.maxWidth < _tightBreakpoint;

        return Container(
          height: 100,
          padding: EdgeInsets.symmetric(horizontal: isTight ? 10 : 20),
          color: const Color(0xFF1A1A1A),
          child: Row(
            children: [
              // Logo — smaller once things get very narrow
              Image.asset(
                'assets/logo.png',
                height: isTight ? 40 : 50,
                width: isTight ? 150 : 250,
                fit: BoxFit.contain,
              ),

              const Spacer(flex: 2),

              // Navigation Menus — hidden below the breakpoint
              if (!isNarrow)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMenuItem("Home", showArrow: false, index: 0),
                    const SizedBox(width: 40),
                    _buildMenuItem("Shop", showArrow: true, index: 1),
                    const SizedBox(width: 30),
                    _buildMenuItem("Collection", showArrow: true, index: 2),
                    const SizedBox(width: 30),
                    _buildMenuItem("Pages", showArrow: true, index: 3),
                  ],
                ),

              SizedBox(width: isTight ? 10 : 60),
              SizedBox(
                width: isTight ? 170 : (isCompact ? 170 : 250),
                height: 38,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),

              SizedBox(width: isTight ? 10 : 40),

              // Account Section
              SizedBox(
                height: 80,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) =>
                          setState(() => _hoveredPersonIcon = true),
                      onExit: (_) =>
                          setState(() => _hoveredPersonIcon = false),
                      child: Icon(
                        Icons.person,
                        color: _hoveredPersonIcon
                            ? const Color.fromRGBO(245, 171, 30, 1)
                            : Colors.white,
                        size: isTight ? 35 : 40,
                      ),
                    ),
                    if (!isCompact) ...[
                      const SizedBox(width: 5),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            onEnter: (_) =>
                                setState(() => _hoveredAccount = true),
                            onExit: (_) =>
                                setState(() => _hoveredAccount = false),
                            child: Text(
                              "Account",
                              style: TextStyle(
                                color: _hoveredAccount
                                    ? const Color.fromRGBO(245, 171, 30, 1)
                                    : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 0),
                          Row(
                            children: [
                              _buildAuthLink("Register"),
                              const Text(
                                " | ",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                              _buildAuthLink("Login"),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(width: isTight ? 10 : 20),

              // Order Icon
              MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _hoveredOrder = true),
                onExit: (_) => setState(() => _hoveredOrder = false),
                child: Icon(
                  Icons.receipt_long,
                  color: _hoveredOrder
                      ? const Color.fromRGBO(245, 171, 30, 1)
                      : Colors.white,
                  size: isTight ? 25 : 30,
                ),
              ),
              if (isNarrow) ...[
                SizedBox(width: isTight ? 14 : 16),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _hoveredHamburger = true),
                  onExit: (_) => setState(() => _hoveredHamburger = false),
                  child: GestureDetector(
                    onTap: _toggleMobileMenu,
                    child: Icon(
                      Icons.menu,
                      color: _hoveredHamburger
                          ? const Color.fromRGBO(245, 171, 30, 1)
                          : Colors.white,
                      size: isTight ? 32 : 32,
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
    final Color itemColor =
        isHovered ? const Color.fromRGBO(245, 171, 30, 1) : Colors.white;

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
      // "Home" has no dropdown, just hover color
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hoveredIndex = index),
        onExit: (_) => setState(() => _hoveredIndex = -1),
        child: content,
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

  Widget _buildAuthLink(String title) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          if (title == "Register") {
            _hoveredRegister = true;
          } else {
            _hoveredLogin = true;
          }
        });
      },
      onExit: (_) {
        setState(() {
          if (title == "Register") {
            _hoveredRegister = false;
          } else {
            _hoveredLogin = false;
          }
        });
      },
      child: Text(
        title,
        style: TextStyle(
          color: (title == "Register" && _hoveredRegister) ||
                  (title == "Login" && _hoveredLogin)
              ? const Color.fromRGBO(245, 171, 30, 1)
              : Colors.white70,
          fontSize: 11,
        ),
      ),
    );
  }
}
class _ShopDropdownContent extends StatelessWidget {
  final void Function(String route) onNavigate;

  const _ShopDropdownContent({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    // Exclude generic/placeholder companies from the nav dropdown.
    final companies =
        kCompanies.where((c) => c.id != 'unknown' && c.id != 'others').toList();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _DropdownColumn(
              title: 'Categories',
              children: [
                for (final category in kCategories) ...[
                  _DropdownColumnRow(
                    item: _DropdownColumnItem(
                      label: category.name,
                      onTap: () => onNavigate('/products?category=${category.id}'),
                    ),
                  ),
                  for (final type in Catalog.typesInCategory(category.id))
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
            ),
          ),
          Container(width: 1, color: Colors.white.withValues(alpha: 0.2)),
          Expanded(
            child: _DropdownColumn(
              title: 'Companies',
              children: [
                for (final company in companies)
                  _DropdownColumnRow(
                    item: _DropdownColumnItem(
                      label: company.name,
                      onTap: () => onNavigate('/products?company=${company.id}'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
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
  final List<Widget> children; // CHANGED: now takes built rows directly,
  // since rows can be either category rows or nested sub-type rows.

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
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: Color.fromRGBO(245, 171, 30, 1),
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
  final bool isSubItem; // NEW — true for nested type rows under a category

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
            left: widget.isSubItem ? 28 : 16, // extra indent for sub-types
            right: 16,
            top: widget.isSubItem ? 6 : 8,
            bottom: widget.isSubItem ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? const Color.fromRGBO(245, 171, 30, 0.15)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: _isHovered
                    ? const Color.fromRGBO(245, 171, 30, 1)
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            widget.item.label,
            style: TextStyle(
              color: _isHovered
                  ? const Color.fromRGBO(245, 171, 30, 1)
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

  const _DropdownList({
    required this.items,
    required this.onSelect,
  });

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
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isHovered
                    ? const Color.fromRGBO(245, 171, 30, 0.1)
                    : Colors.transparent,
                border: Border(
                  
                  right: BorderSide(
                    color: isHovered
                        ? const Color.fromRGBO(245, 171, 30, 1)
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                item,
                style: TextStyle(
                  color: isHovered
                      ? const Color.fromRGBO(245, 171, 30, 1)
                      : Colors.white,
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
  final Map<int, List<String>> dropdownItems;
  final void Function(String item) onSelect;
  final VoidCallback onClosed;

  const _MobileSidebar({
    super.key,
    required this.dropdownItems,
    required this.onSelect,
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
          // Dimmed scrim – tap anywhere to dismiss.
          FadeTransition(
            opacity: _controller,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: close,
              child: Container(color: Colors.black.withValues(alpha: 0.45)),
            ),
          ),
          // Sliding panel.
          Align(
            alignment: Alignment.centerRight,
            child: SlideTransition(
              position: _slide,
              child: SizedBox(
                width: _sidebarWidth,
                height: double.infinity,
                child: Row(
                  children: [
                    // Gold accent strip
                    Container(
                      width: 3,
                      color: const Color.fromRGBO(245, 171, 30, 1),
                    ),
                    // Main panel with rounded corner
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                        ),
                        child: Material(
                          elevation: 16,
                          color: const Color(0xFF1A1A1A), // Same as navbar
                          child: SafeArea(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with gold underline
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                            icon: const Icon(Icons.close,
                                                color: Colors.white),
                                            splashRadius: 20,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 1),
                                      Container(
                                        height: 2,
                                        width: 30,
                                        color:
                                            const Color.fromRGBO(245, 171, 30, 1),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Divider(
                                  height: 1,
                                  color: Color(0xFF444444),
                                ),
                                const SizedBox(height: 8),
                                // Scrollable menu
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: _MobileNavMenu(
                                      dropdownItems: widget.dropdownItems,
                                      onSelect: widget.onSelect,
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
  final Map<int, List<String>> dropdownItems;
  final void Function(String item) onSelect;

  const _MobileNavMenu({
    required this.dropdownItems,
    required this.onSelect,
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
          // "Shop" — now backed by live catalog data (categories only, to
          // keep the mobile menu compact).
          return ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            iconColor: Colors.white,
            collapsedIconColor: Colors.white70,
            title: const Text(
              "Shop",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            children: [
              for (final category in kCategories)
                ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.only(left: 32, right: 16),
                  title: Text(
                    category.name,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  onTap: () => onSelect(category.name),
                ),
            ],
          );
        }

        final subItems = dropdownItems[index];

        if (subItems == null) {
          // "Home" – just a tappable row
          return ListTile(
            dense: true,
            title: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            onTap: () => onSelect(label),
          );
        }

        // Items with sub‑menus (Collection, Pages)
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
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
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