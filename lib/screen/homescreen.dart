import 'package:devansh/components/header.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            const Header(),

            // Top Image Section — AspectRatio keeps the image intact,
            // no cropping, and scales cleanly across screen sizes.
            AspectRatio(
              aspectRatio: 16 / 7, // adjust to match your image's real ratio
              child: Image.asset(
                'assets/port.jpg',
                width: double.infinity,
                fit: BoxFit.cover, // cover now works correctly since the
                                   // box ratio matches the image ratio
              ),
            ),

            // About Section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 60,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "About Us",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Write a short description of your business here. "
                    "This is where you tell visitors what you do, what "
                    "makes you different, and why they should trust you.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // Rest of homepage content will go here
          ],
        ),
      ),
    );
  }
}