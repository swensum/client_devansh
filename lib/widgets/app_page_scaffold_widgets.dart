// lib/components/app_page_scaffold.dart
import 'package:devansh/components/header.dart';
import 'package:flutter/material.dart';

/// Shared page shell used by every screen except HomePage (which has its
/// own scroll-driven reveal already). Wires up the same fixed
/// TopBar + Header (via SiteHeader) and scroll controller so every page
/// behaves consistently, without repeating the boilerplate.
class AppPageScaffold extends StatefulWidget {
  final Widget body; // your page's scrollable content (without the header)
  final Color? backgroundColor;
  final Widget? endDrawer;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const AppPageScaffold({
    super.key,
    required this.body,
    this.backgroundColor,
    this.endDrawer,
    this.scaffoldKey,
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
      key: widget.scaffoldKey,
      backgroundColor: widget.backgroundColor,
      endDrawer: widget.endDrawer,
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