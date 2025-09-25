import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ecommerce_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:ecommerce_flutter/features/auth/presentation/pages/register_page.dart';
import 'package:ecommerce_flutter/features/auth/presentation/viewmodels/auth_controller.dart';
import 'package:ecommerce_flutter/features/catalog/presentation/pages/catalog_page.dart';
import 'package:ecommerce_flutter/features/catalog/presentation/pages/product_page.dart';
import 'package:ecommerce_flutter/features/cart/presentation/pages/cart_page.dart';
import 'package:ecommerce_flutter/features/checkout/presentation/pages/checkout_page.dart';
import 'package:ecommerce_flutter/features/checkout/presentation/pages/orders_page.dart';
import 'package:ecommerce_flutter/features/checkout/presentation/pages/order_detail_page.dart';
import 'package:ecommerce_flutter/features/profile/presentation/pages/profile_page.dart';

/// Router principal exposé via Riverpod
final routerProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authStateProvider);

  //  Notifier qui force GoRouter à se rafraîchir quand l'état change
  final notifier = ValueNotifier(0);

  //  On écoute les changements d'état d'auth
  ref.listen(authStateProvider, (_, __) {
    notifier.value++;
  });

  return GoRouter(
    initialLocation: '/catalog',
    refreshListenable: notifier,
    redirect: (context, state) {
      final isLoggedIn = authAsync.value != null;
      final loggingIn =
          state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!isLoggedIn && !loggingIn) return '/login';
      if (isLoggedIn && loggingIn) return '/catalog';

      return null;
    },
    routes: [
      // Auth
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),

      // Catalogue
      GoRoute(path: '/catalog', builder: (_, __) => const CatalogPage()),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) =>
            ProductPage(productId: state.pathParameters['id']!),
      ),

      // Panier & Commandes
      GoRoute(path: '/cart', builder: (_, __) => const CartPage()),
      GoRoute(path: '/checkout', builder: (_, __) => const CheckoutPage()),
      GoRoute(path: '/orders', builder: (_, __) => const OrdersPage()),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) =>
            OrderDetailPage(orderId: state.pathParameters['id']!),
      ),

      // Profil
      GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
    ],
  );
});

/// Page d'accueil temporaire pour tester le login/logout
class CatalogPlaceholder extends ConsumerWidget {
  const CatalogPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog'),
        actions: [
          IconButton(
            tooltip: 'Déconnexion',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Connecté — Page Catalog temporaire',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

/// Page temporaire générique utilisée pour /cart, /checkout, etc.
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title page',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
