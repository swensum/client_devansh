import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:web/web.dart' as web;

extension SmartNavigation on BuildContext {
  void goSmart(String route) {
    if (_isCurrentLocation(route)) {
      web.window.location.reload();
    } else {
      go(route);
    }
  }

  void pushSmart(String route) {
    if (_isCurrentLocation(route)) {
      web.window.location.reload();
    } else {
      push(route);
    }
  }

  bool _isCurrentLocation(String route) {
    try {
      final current = GoRouter.of(
        this,
      ).routeInformationProvider.value.uri.toString();
      return _normalize(current) == _normalize(route);
    } catch (_) {
      return false;
    }
  }

  String _normalize(String uri) {
    final parsed = Uri.parse(uri);
    final sortedQuery = Map.fromEntries(
      parsed.queryParameters.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key)),
    );
    return Uri(
      path: parsed.path,
      queryParameters: sortedQuery.isEmpty ? null : sortedQuery,
    ).toString();
  }
}
