import 'dart:async';
import 'package:devansh/components/topbar.dart';
import 'package:devansh/models/blogmodel.dart';
import 'package:devansh/widgets/app_page_scaffold_widgets.dart';
import 'package:devansh/widgets/blogwidgets.dart';
import 'package:flutter/material.dart';

import 'package:devansh/services/blogservice.dart';

import 'package:devansh/components/header.dart';
import 'package:devansh/components/footer.dart';


class BlogsListPage extends StatefulWidget {
  const BlogsListPage({super.key});

  @override
  State<BlogsListPage> createState() => _BlogsListPageState();
}

class _BlogsListPageState extends State<BlogsListPage> {
  bool _isDisposed = false;
  final BlogService _blogService = BlogService();
  List<BlogPost> _posts = [];
  bool _loading = true;
  StreamSubscription<List<BlogPost>>? _postsSub;

  @override
  void initState() {
    super.initState();
    _postsSub = _blogService.watchPublishedPosts().listen((data) {
      if (!_isDisposed) {
        setState(() {
          _posts = data;
          _loading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _postsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      body: Column(
        children: [
          SizedBox(height: Header.height + TopBar.height),
          Container(
            width: double.infinity,
            color: const Color(0xFF0F0F0F),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 70),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Our Blog",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(height: 3, width: 60, color: kBlogAccent),
                    const SizedBox(height: 14),
                    Text(
                      "Tips, trends, and stories from the world of premium hardware.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 44),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: CircularProgressIndicator(color: kBlogAccent),
                      )
                    else if (_posts.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          "No posts published yet — check back soon.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      )
                    else
                      BlogGrid(posts: _posts),
                  ],
                ),
              ),
            ),
          ),
          const Footer(),
        ],
      ),
    );
  }
}