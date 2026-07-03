import 'package:devansh/components/header.dart';
import 'package:flutter/material.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            const Header(),

            // Top Image Section with overlay text
            AspectRatio(
              aspectRatio: 16 / 8,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  Image.asset(
                    'assets/port.jpg',
                    fit: BoxFit.cover,
                  ),

                 
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withOpacity(0.55),
                          Colors.black.withOpacity(0.0),
                        ],
                        stops: const [0.0, 0.7],
                      ),
                    ),
                  ),

                  
                  Positioned(
                    left: 60,
                    right: 60,
                    top: 0,
                    bottom: 0,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Elevate Every Space with Premium Cabinet Handles",
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Discover modern, durable, and elegant cabinet "
                              "& door handles crafted to complement every interior.",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.5,
                              ),
                            ),
                        const SizedBox(height: 35),
                            
// Hover animation wrapper
MouseRegion(
  onEnter: (_) {
    setState(() {
      _isHovered = true;
    });
  },
  onExit: (_) {
    setState(() {
      _isHovered = false;
    });
  },
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    transform: Matrix4.identity()
      ..scale(_isHovered ? 1.05 : 1.0),
    child: ElevatedButton(
      onPressed: () {
        // Add your navigation logic here
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _isHovered 
            ? const Color.fromRGBO(255, 181, 40, 1)
            : const Color.fromRGBO(245, 171, 30, 1),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(
          horizontal: 28,
          vertical: 18,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        elevation: _isHovered ? 8 : 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Explore Collection",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          AnimatedRotation(
            duration: const Duration(milliseconds: 300),
            turns: _isHovered ? 0.125 : 0.0, // Rotates ~45 degrees clockwise
            child: const Icon(
              Icons.arrow_forward, // Changed to arrow pointing right
              size: 18,
              color: Colors.black,
            ),
          ),
        ],
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
            ),

            // About Section
            

            // Rest of homepage content will go here
          ],
        ),
      ),
    );
  }
}