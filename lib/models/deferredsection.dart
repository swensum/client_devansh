import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class DeferredSection extends StatefulWidget {
  final Widget child;

  const DeferredSection({super.key, required this.child});

  @override
  State<DeferredSection> createState() => _DeferredSectionState();
}

class _DeferredSectionState extends State<DeferredSection> {
  bool _loaded = false;

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!_loaded && info.visibleFraction > 0.05) {
      setState(() {
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loaded) {
      return widget.child;
    }

    return VisibilityDetector(
      key: Key(widget.hashCode.toString()),
      onVisibilityChanged: _onVisibilityChanged,
      child: const SizedBox(
        height: 500, // placeholder
      ),
    );
  }
}
