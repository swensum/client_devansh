import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:web/web.dart' as web;

/// Drop-in replacements for `context.go()` / `context.push()` that fix the
/// "tapping a link to the page you're already on does nothing (or, with
/// push, stacks a duplicate page)" problem — used by the header dropdowns,
/// footer links, mobile sidebar, and search.
///
/// Usage: everywhere you'd write `context.go(route)` or `context.push(route)`,
/// write `context.goSmart(route)` or `context.pushSmart(route)` instead.
extension SmartNavigation on BuildContext {
  /// Use for *lateral* navigation — menu items, category/company links,
  /// footer links, search results, "Pages" links. These conceptually
  /// replace what's on screen rather than drilling into it.
  ///
  /// If [route] is already the current location, `go()` is normally a
  /// no-op (GoRouter sees no location change, so nothing rebuilds) — this
  /// forces a real reload instead, so the tap always visibly does
  /// something.
  void goSmart(String route) {
    if (_isCurrentLocation(route)) {
      web.window.location.reload();
    } else {
      go(route);
    }
  }

  /// Use for *drill-down* navigation — e.g. clicking a search result to
  /// open a product detail page, where "back" should return to the page
  /// you came from (list, search results, etc).
  ///
  /// If [route] is already the current location, `push()` would normally
  /// stack a second identical page on top of itself — this forces a real
  /// reload instead of stacking a duplicate.
  void pushSmart(String route) {
    if (_isCurrentLocation(route)) {
      web.window.location.reload();
    } else {
      push(route);
    }
  }

  bool _isCurrentLocation(String route) {
    // NOTE: `GoRouterState.of(context)` was used here originally, but it
    // only reliably resolves when called from a context that sits inside
    // the *current route's own builder subtree*. Header/dropdown/overlay
    // widgets don't always satisfy that — the lookup can throw, which
    // silently kills the tap before go()/push() ever runs (looks like
    // "nothing happens" when you click a menu item).
    //
    // GoRouter.of(context).routerDelegate.currentConfiguration is safe to
    // call from anywhere the router itself is reachable (i.e. anywhere in
    // the app), so we use that instead.
    try {
      final current = GoRouter.of(
        this,
      ).routerDelegate.currentConfiguration.uri.toString();
      return current == route;
    } catch (_) {
      // If we can't determine the current location for any reason, fail
      // open: treat it as "not the current page" so the tap still
      // navigates instead of doing nothing.
      return false;
    }
  }
}
