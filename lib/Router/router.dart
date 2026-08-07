import 'dart:async';

import 'package:devansh/dialog/privacypolicies.dart';
import 'package:devansh/dialog/termsscreen.dart';
import 'package:devansh/models/catalogmodels.dart';
import 'package:devansh/productwidgets/productdetail.dart';
import 'package:devansh/screen/aboutscreen.dart';
import 'package:devansh/screen/authscreen.dart';
import 'package:devansh/screen/blogscreen.dart';
import 'package:devansh/screen/blogsdetailpage.dart';
import 'package:devansh/screen/contactscreen.dart';
import 'package:devansh/screen/homescreen.dart';
import 'package:devansh/screen/orderscreen.dart';
import 'package:devansh/screen/productscreen.dart'; // ProductsPage
import 'package:devansh/services/catalogservice.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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

final GoRouterRefreshStream _authRefresh = GoRouterRefreshStream(
  FirebaseAuth.instance.authStateChanges(),
);

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
      final tween = Tween(
        begin: begin,
        end: end,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

final GoRouter appRouter = GoRouter(
  debugLogDiagnostics: kDebugMode,
  initialLocation: '/',
  refreshListenable: _authRefresh,
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final loggedIn = user != null && user.emailVerified;
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
        final searchQuery = state.uri.queryParameters['search'];
        return _slideFromRightPage(
          key: state.pageKey,
          child: ProductsPage(
            initialCategoryId: categoryId,
            initialCompanyId: companyId,
            initialTypeId: typeId,
            initialSearchQuery: searchQuery,
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
        return _slideFromRightPage(
          key: state.pageKey,
          child: const AboutPage(),
        );
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
      path: '/privacy',
      name: 'privacy',
      pageBuilder: (context, state) {
        return _slideFromRightPage(
          key: state.pageKey,
          child: const PrivacyPolicyPage(),
        );
      },
    ),
    GoRoute(
      path: '/terms',
      name: 'terms',
      pageBuilder: (context, state) {
        return _slideFromRightPage(
          key: state.pageKey,
          child: const TermsOfServicePage(),
        );
      },
    ),
    GoRoute(
      path: '/blog',
      name: 'blog',
      builder: (context, state) => const BlogsListPage(),
    ),
    GoRoute(
      path: '/blog/:slug',
      name: 'blogDetail',
      builder: (context, state) =>
          BlogDetailPage(slug: state.pathParameters['slug']!),
    ),
    GoRoute(
      path: '/product/:id',
      name: 'productDetail',
      pageBuilder: (context, state) {
        final productId = state.pathParameters['id'];
        final extraProduct = state.extra;

        // Fast path: we arrived via an in-app tap (search suggestion,
        // product card, etc.) that attached the full Product as `extra`.
        if (extraProduct is Product) {
          return _slideFromRightPage(
            key: state.pageKey,
            child: ProductDetailPage(product: extraProduct),
          );
        }

        // Slow path: `extra` is never part of the URL, so it's null on
        // browser back/forward, refresh, or a direct/shared link. Look the
        // product up live from the catalog instead of the old kProducts
        // list (which is never populated) so those cases work too.
        if (productId == null) {
          return _slideFromRightPage(
            key: state.pageKey,
            child: const _ProductNotFoundPage(),
          );
        }
        return _slideFromRightPage(
          key: state.pageKey,
          child: _ProductDetailLoader(productId: productId),
        );
      },
    ),
  ],
  errorBuilder: (context, state) => const _ProductNotFoundPage(),
);

/// Looks a product up from the live catalog by id. Used whenever the
/// product-detail route is reached without `extra` already attached —
/// browser back/forward, a page refresh, or someone opening a shared link
/// directly.
class _ProductDetailLoader extends StatelessWidget {
  final String productId;

  const _ProductDetailLoader({required this.productId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: CatalogService().watchProducts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(245, 171, 30, 1),
              ),
            ),
          );
        }

        Product? product;
        for (final p in snapshot.data!) {
          if (p.id == productId) {
            product = p;
            break;
          }
        }

        if (product == null) {
          return const _ProductNotFoundPage();
        }
        return ProductDetailPage(product: product);
      },
    );
  }
}

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
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
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
