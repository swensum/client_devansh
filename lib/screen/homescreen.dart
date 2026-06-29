import 'package:devansh/components/header.dart';
import 'package:flutter/material.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          const Header(),

          // Top Image Section
          SizedBox(
            width: double.infinity,
            height: 250,
            child: Image.asset(
              'assets/port.jpg',  // Change this to your image name
              fit: BoxFit.cover,
            ),
          ),

          // Rest of homepage content will go here
        ],
      ),
    );
  }
}