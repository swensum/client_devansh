import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key});

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

          const SizedBox(width: 230),

          // Navigation Menus (Centered)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMenuItem("Home"),
              const SizedBox(width: 40),
              _buildMenuItem("Shop"),
              const SizedBox(width: 40),
              _buildMenuItem("Collection"),
              const SizedBox(width: 40),
              _buildMenuItem("Pages"),
            ],
          ),

          const SizedBox(width: 80),

          // Search Bar
          SizedBox(
            width: 250,
            height: 35,
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
                const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(width: 5),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Account",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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

          // Order Icon (Right End)
          const Icon(
            Icons.receipt_long,
            color: Colors.white,
            size: 30,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAuthLink(String title) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
        ),
      ),
    );
  }
}