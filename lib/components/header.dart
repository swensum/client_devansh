import 'dart:async';
import 'package:flutter/material.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  int _hoveredIndex = -1;
  bool _hoveredAccount = false;
  bool _hoveredRegister = false;
  bool _hoveredLogin = false;
  bool _hoveredOrder = false;
  bool _hoveredPersonIcon = false;

  // Which dropdown is currently open (-1 = none)
  int _openIndex = -1;

  // Dropdown data
  final Map<int, List<String>> _dropdownItems = {
    1: ["Door Fittings", "Door Handles", "Hinges", "Locks", "Door Closers"],
    2: ["New Arrivals", "Best Sellers", "Special Offers", "Seasonal"],
    3: ["About Us", "Contact", "FAQs", "Shipping Info", "Terms & Conditions"],
  };

  // One LayerLink per dropdown-enabled menu item — anchors the dropdown
  // to that item's exact position on screen.
  final Map<int, LayerLink> _layerLinks = {
    1: LayerLink(),
    2: LayerLink(),
    3: LayerLink(),
  };

  OverlayEntry? _overlayEntry;
  Timer? _closeTimer;

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
    _cancelClose(); // stop any pending close from a previous hover
    if (_overlayEntry != null && _openIndex == index) return; // already open
    _removeOverlay();
    _openIndex = index;

    final link = _layerLinks[index]!;

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
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 180,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _DropdownList(
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
    if (mounted) setState(() => _hoveredIndex = -1);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _openIndex = -1;
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.black87,
      child: Row(
        children: [
          // Logo
          Image.asset(
            'assets/logo.png',
            height: 50,
            width: 250,
            fit: BoxFit.contain,
          ),

          const SizedBox(width: 220),

          // Navigation Menus
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

          const SizedBox(width: 50),

          // Search Bar
          SizedBox(
            width: 250,
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

          const SizedBox(width: 50),

          // Account Section
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _hoveredPersonIcon = true),
                  onExit: (_) => setState(() => _hoveredPersonIcon = false),
                  child: Icon(
                    Icons.person,
                    color: _hoveredPersonIcon
                        ? const Color.fromRGBO(245, 171, 30, 1)
                        : Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 5),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) => setState(() => _hoveredAccount = true),
                      onExit: (_) => setState(() => _hoveredAccount = false),
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
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        _buildAuthLink("Login"),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 30),

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
              size: 30,
            ),
          ),
        ],
      ),
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
        final isLast = i == widget.items.length - 1;
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
                  bottom: isLast
                      ? BorderSide.none
                      : BorderSide(
                          color: Colors.grey.shade200,
                          width: 0.5,
                        ),
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
                      : Colors.black87,
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