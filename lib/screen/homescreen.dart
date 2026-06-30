import 'package:devansh/components/header.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _activeDropdown = -1;
  Offset _dropdownPosition = Offset.zero;

  final Map<int, List<String>> _dropdownItems = {
    1: ["Door Fittings", "Door Handles", "Hinges", "Locks", "Door Closers"],
    2: ["New Arrivals", "Best Sellers", "Special Offers", "Seasonal"],
    3: ["About Us", "Contact", "FAQs", "Shipping Info", "Terms & Conditions"],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              Header(
                onMenuHover: (index, offset, width) {
                  setState(() {
                    _activeDropdown = index;
                    _dropdownPosition = offset;
                  });
                },
                onMenuExit: () {
                  setState(() {
                    _activeDropdown = -1;
                  });
                },
              ),

              // Top Image Section
              SizedBox(
                width: double.infinity,
                height: 250,
                child: Image.asset(
                  'assets/port.jpg',
                  fit: BoxFit.cover,
                ),
              ),

              // Rest of homepage content will go here
            ],
          ),

          // Dropdown Overlay (appears over everything)
          if (_activeDropdown != -1 && _dropdownItems.containsKey(_activeDropdown))
            Positioned(
              left: _dropdownPosition.dx - 15,
              top: _dropdownPosition.dy + 30,
              child: MouseRegion(
                onEnter: (_) => setState(() {}),
                onExit: (_) => setState(() => _activeDropdown = -1),
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (_dropdownItems[_activeDropdown] ?? [])
                          .map(
                            (item) => InkWell(
                              onTap: () {
                                setState(() => _activeDropdown = -1);
                              },
                              hoverColor:
                                  const Color.fromRGBO(245, 171, 30, 0.1),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade200,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}