import 'package:komercia_app/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:komercia_app/features/auth/auth.dart';
import 'package:komercia_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:komercia_app/features/home/presentation/screens/layout_screen.dart';
import 'package:komercia_app/features/products/presentation/screens/inventory_screen.dart';
import 'package:komercia_app/features/sales/presentation/screens/balance_screen.dart';
import 'package:komercia_app/features/sales/presentation/screens/new_sale_screen.dart';
import 'package:komercia_app/features/sales/presentation/screens/sale_detail_screen.dart';

import 'app_router_notifier.dart';

final goRouterProvider = Provider((ref) {
  final goRouterNotifier = ref.read(goRouterNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: goRouterNotifier,
    routes: [
      ///* Primera pantalla
      GoRoute(
        path: '/splash',
        builder: (context, state) => const CheckAuthStatusScreen(),
      ),

      ///* Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      ///*  sales
      GoRoute(
        path: '/new_sale',
        builder: (context, state) => const NewSaleScreen(),
      ),

      GoRoute(
        path: '/balance',
        builder: (context, state) => const BalanceScreen(),
      ),

      GoRoute(
        path: '/sale_detail/:id_sale',
        builder: (context, state) => SaleDetailScreen(
            idSale: int.parse(state.pathParameters['id_sale']!)),
      ),

      ///* Product Routes
      GoRoute(
        path: '/',
        builder: (context, state) => const LayoutScreen(),
      ),

      GoRoute(
        path: '/products',
        builder: (context, state) => const InventoryScreen(),
      ),
    ],
    redirect: (context, state) {
      final isGoingTo = state.matchedLocation;
      final authStatus = goRouterNotifier.authStatus;

      if (isGoingTo == '/splash' && authStatus == AuthStatus.checking)
        return null;

      if (authStatus == AuthStatus.notAuthenticated) {
        if (isGoingTo == '/login' || isGoingTo == '/register') return null;

        return '/login';
      }

      if (authStatus == AuthStatus.authenticated) {
        if (isGoingTo == '/login' ||
            isGoingTo == '/register' ||
            isGoingTo == '/splash') {
          return '/';
        }
      }

      return null;
    },
  );
});
