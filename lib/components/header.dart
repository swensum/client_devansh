import 'package:flutter/material.dart';

class Header extends StatefulWidget {
  final Function(int, Offset, double)? onMenuHover;
  final Function()? onMenuExit;

  const Header({
    super.key,
    this.onMenuHover,
    this.onMenuExit,
  });

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

  final List<GlobalKey> _menuKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.blueGrey[900],
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
    final Color itemColor = isHovered
        ? const Color.fromRGBO(245, 171, 30, 1)
        : Colors.white;

    return MouseRegion(
      key: _menuKeys[index],
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hoveredIndex = index);
        // Calculate position and send to parent
        final RenderBox renderBox =
            _menuKeys[index].currentContext?.findRenderObject() as RenderBox;
        final offset = renderBox.localToGlobal(Offset.zero);
        final width = renderBox.size.width;
        widget.onMenuHover?.call(index, offset, width);
      },
      onExit: (_) {
        setState(() => _hoveredIndex = -1);
        widget.onMenuExit?.call();
      },
      child: Row(
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
          color:
              (title == "Register" && _hoveredRegister) ||
                  (title == "Login" && _hoveredLogin)
              ? const Color.fromRGBO(245, 171, 30, 1)
              : Colors.white70,
          fontSize: 11,
        ),
      ),
    );
  }
}