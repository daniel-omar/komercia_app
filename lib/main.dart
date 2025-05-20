import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/config/constants/environment.dart';
import 'package:komercia_app/config/router/app_router.dart';
import 'package:komercia_app/config/theme/app_theme.dart';
import 'package:komercia_app/features/shared/infrastructure/providers/connectivity_provider.dart';
import 'package:komercia_app/features/shared/widgets/not_internet.dart';
import 'package:logger/logger.dart';

void main() async {
  var logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
    level: Level.info, //Personaliza el formato de los mensajes
  );

  await Environment.initEnvironment();

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<ConnectivityState>(connectionProvider, (previous, next) {
      if (next == ConnectivityState.disconnected) {
        // Navigate to the No Internet page
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const NoInternetScreen()),
        );
      } else if (previous == ConnectivityState.disconnected &&
          next == ConnectivityState.connected) {
        // Navigate back only if previously disconnected
        Navigator.of(context).pop();
      }
    });

    final appRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      routerConfig: appRouter,
      theme: AppTheme().getTheme(),
      debugShowCheckedModeBanner: false,
    );
  }
}
