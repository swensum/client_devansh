// lib/components/app_page_scaffold.dart
import 'package:devansh/components/header.dart';
import 'package:flutter/material.dart';

class AppPageScaffold extends StatefulWidget {
  final Widget body;
  final bool addTopSpacing;

  const AppPageScaffold({
    super.key,
    required this.body,
    this.addTopSpacing = true,
  });

  @override
  State<AppPageScaffold> createState() => _AppPageScaffoldState();
}

class _AppPageScaffoldState extends State<AppPageScaffold> {
  bool _headerRevealed = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) setState(() => _headerRevealed = true);
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: widget.body,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              offset: _headerRevealed ? Offset.zero : const Offset(0, -1),
              child: SiteHeader(scrollController: _scrollController),
            ),
          ),
        ],
      ),
    );
  }
}