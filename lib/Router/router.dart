import 'dart:async';

import 'package:devansh/models/catalogmodels.dart';
import 'package:devansh/productwidgets/productdetail.dart';
import 'package:devansh/screen/aboutscreen.dart';
import 'package:devansh/screen/authscreen.dart';
import 'package:devansh/screen/contactscreen.dart';
import 'package:devansh/screen/homescreen.dart';
import 'package:devansh/screen/orderscreen.dart';
import 'package:devansh/screen/productscreen.dart'; // ProductsPage

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final List<Product> kProducts = [];

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final GoRouterRefreshStream _authRefresh =
    GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges());

const List<String> _protectedPaths = ['/orders'];

CustomTransitionPage<void> _slideFromRightPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: Curves.easeOutCubic),
      );
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: _authRefresh,
  redirect: (context, state) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final goingToAuth = state.matchedLocation == '/auth';
    final goingToProtected = _protectedPaths.contains(state.matchedLocation);

    if (!loggedIn && goingToProtected) {
      return '/auth?redirect=${Uri.encodeComponent(state.matchedLocation)}';
    }

    if (loggedIn && goingToAuth) {
      final redirectTo = state.uri.queryParameters['redirect'];
      return (redirectTo != null && redirectTo.isNotEmpty) ? redirectTo : '/';
    }

    return null; // no redirect needed
  },
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/products',
      name: 'products',
      pageBuilder: (context, state) {
        final categoryId = state.uri.queryParameters['category'];
        final companyId = state.uri.queryParameters['company'];
        final typeId = state.uri.queryParameters['type'];
        return _slideFromRightPage(
          key: state.pageKey,
          child: ProductsPage(
            initialCategoryId: categoryId,
            initialCompanyId: companyId,
            initialTypeId: typeId,
          ),
        );
      },
    ),
    GoRoute(
      path: '/orders',
      name: 'orders',
      builder: (context, state) => const OrdersPage(),
    ),
    GoRoute(
      path: '/auth',
      name: 'auth',
      pageBuilder: (context, state) {
        return _slideFromRightPage(
          key: state.pageKey,
          child: const AuthScreen(),
        );
      },
    ),
    GoRoute(
  path: '/about',
  name: 'about',
  pageBuilder: (context, state) {
    return _slideFromRightPage(key: state.pageKey, child: const AboutPage());
  },
),
    GoRoute(
  path: '/contact',
  name: 'contact',
  pageBuilder: (context, state) {
    return _slideFromRightPage(
      key: state.pageKey,
      child: const ContactPage(),
    );
  },
),
    GoRoute(
      path: '/product/:id',
      name: 'productDetail',
      pageBuilder: (context, state) {
        final productId = state.pathParameters['id'];
        final extraProduct = state.extra;
        if (extraProduct is Product) {
          return _slideFromRightPage(
            key: state.pageKey,
            child: ProductDetailPage(product: extraProduct),
          );
        }
        Product? product;
        for (final p in kProducts) {
          if (p.id == productId) {
            product = p;
            break;
          }
        }
        if (product == null) {
          return _slideFromRightPage(
            key: state.pageKey,
            child: const _ProductNotFoundPage(),
          );
        }
        return _slideFromRightPage(
          key: state.pageKey,
          child: ProductDetailPage(product: product),
        );
      },
    ),
  ],
  errorBuilder: (context, state) => const _ProductNotFoundPage(),
);

class _ProductNotFoundPage extends StatelessWidget {
  const _ProductNotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white54, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Product not found',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}