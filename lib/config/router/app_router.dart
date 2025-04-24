import 'package:komercia_app/features/home/presentation/screens/home_screen.dart';
import 'package:komercia_app/features/orders/presentation/screens/customer_signature_screen.dart';
import 'package:komercia_app/features/orders/presentation/screens/order_customer_screen.dart';
import 'package:komercia_app/features/orders/presentation/screens/order_liquidation_screen.dart';
import 'package:komercia_app/features/orders/presentation/screens/order_material_screen.dart';
import 'package:komercia_app/features/orders/presentation/screens/order_material_used_screen.dart';
import 'package:komercia_app/features/orders/presentation/screens/screens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:komercia_app/features/auth/auth.dart';
import 'package:komercia_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:komercia_app/features/products/products.dart';

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
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      ///* Product Routes
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/materials',
        builder: (context, state) => const ProductsScreen(),
      ),
      GoRoute(
        path: '/material/:id', // /product/new
        builder: (context, state) => ProductScreen(
          productId: state.pathParameters['id'] ?? 'no-id',
        ),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/order/:idOrden', // /product/new
        builder: (context, state) => OrderScreen(
          idOrder: state.pathParameters['idOrden'] != null
              ? int.parse(state.pathParameters['idOrden']!)
              : 0,
        ),
      ),
      GoRoute(
        path: '/order_materials/:idOrden', // /product/new
        builder: (context, state) => OrderMaterialScreen(
          idOrder: state.pathParameters['idOrden'] != null
              ? int.parse(state.pathParameters['idOrden']!)
              : 0,
        ),
      ),
      GoRoute(
        path: '/order_customer/:idOrden', // /product/new
        builder: (context, state) => CustomerOrderScreen(
          idOrder: state.pathParameters['idOrden'] != null
              ? int.parse(state.pathParameters['idOrden']!)
              : 0,
        ),
      ),
      GoRoute(
        path: '/customer_signature/:idOrden', // /product/new
        builder: (context, state) => CustomerSignatureScreen(
          idOrder: state.pathParameters['idOrden'] != null
              ? int.parse(state.pathParameters['idOrden']!)
              : 0,
        ),
      ),
      GoRoute(
        path: '/order_materials_used/:idOrden', // /product/new
        builder: (context, state) => OrderMaterialUsedScreen(
          idOrder: state.pathParameters['idOrden'] != null
              ? int.parse(state.pathParameters['idOrden']!)
              : 0,
        ),
      ),
      GoRoute(
        path: '/order_liquidation/:idOrden', // /product/new
        builder: (context, state) => OrderLiquidationScreen(
          idOrder: state.pathParameters['idOrden'] != null
              ? int.parse(state.pathParameters['idOrden']!)
              : 0,
        ),
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
