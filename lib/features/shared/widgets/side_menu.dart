import 'package:komercia_app/config/router/app_router_notifier.dart';
import 'package:komercia_app/features/auth/domain/domain.dart';
import 'package:komercia_app/features/auth/presentation/providers/biometric_provider.dart';
import 'package:komercia_app/features/home/presentation/providers/menu_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/auth/presentation/providers/auth_provider.dart';
// import 'package:go_router/go_router.dart';
import 'package:komercia_app/features/shared/shared.dart';

class SideMenu extends ConsumerStatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const SideMenu({super.key, required this.scaffoldKey});
  @override
  SideMenuState createState() => SideMenuState();
}

class SideMenuState extends ConsumerState<SideMenu> {
  int navDrawerIndex = 0;
  late User userData;

  Future<void> activarHuella(BuildContext context, WidgetRef ref) async {
    final disponible =
        await ref.read(biometricProvider.notifier).canCheckFingerprint();

    if (!disponible) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El dispositivo no soporta huella')),
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      return;
    }

    try {
      final exito = await ref
          .read(biometricProvider.notifier)
          .authenticateWithFingerprint();

      if (exito) {
        // Guardar que la huella está habilitada
        await ref.read(biometricProvider.notifier).saveFingerprint();
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Autenticación dactilar satisfactoria.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3), // Duración del SnackBar
              behavior: SnackBarBehavior.floating),
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Autenticación fallida')),
        );
      }
    } catch (e) {
      // print('Error al activar huella: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hubo un error al activar la huella')),
      );
    }
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  Future<void> desactivarHuella(BuildContext context, WidgetRef ref) async {
    try {
      final exito =
          await ref.read(biometricProvider.notifier).clearFingerprint();

      if (exito) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Desactivación dactilar satisfactoria.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3), // Duración del SnackBar
              behavior: SnackBarBehavior.floating),
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Desactivación dactilar fallida')),
        );
      }
    } catch (e) {
      // print('Error al activar huella: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hubo un error al desactivar la huella')),
      );
    }
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    ref.read(biometricProvider.notifier).checkFingerprint();
  }

  @override
  Widget build(BuildContext context) {
    final hasNotch = MediaQuery.of(context).viewPadding.top > 35;
    final textStyles = Theme.of(context).textTheme;
    final goRouterNotifier = ref.read(goRouterNotifierProvider);
    final menuState = ref.watch(menusProvider);
    final biometricState = ref.watch(biometricProvider);

    return NavigationDrawer(
        elevation: 1,
        selectedIndex: menuState.indexMenu,
        onDestinationSelected: (value) {
          setState(() {
            navDrawerIndex = value;
          });

          ref.read(menusProvider.notifier).updateIndex(navDrawerIndex);
          ref
              .read(menusProvider.notifier)
              .setMenu(menuState.menusSideBar[navDrawerIndex]);

          widget.scaffoldKey.currentState?.closeDrawer();
          // Navigator.pop(context);
        },
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, hasNotch ? 0 : 20, 16, 0),
            child: Text('Saludos', style: textStyles.titleMedium),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 16, 10),
            child: Text(goRouterNotifier.user.nombre,
                style: textStyles.titleSmall),
          ),
          for (var menuSideBar in menuState.menusSideBar)
            NavigationDrawerDestination(
              icon: Icon(menuSideBar.iconData),
              label: Text(menuSideBar.nombreMenu),
            ),
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
            child: Divider(),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 10, 16, 10),
            child: Text('Otras opciones'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomFilledButton(
                onPressed: () async {
                  // await ref.read(biometricProvider.notifier).clearFingerprint();
                  ref.read(authProvider.notifier).logout();
                },
                text: 'Cerrar sesión'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: CustomFilledButton(
              onPressed: () async {
                biometricState.isFingerprintEnabled
                    ? desactivarHuella(context, ref)
                    : activarHuella(context, ref);
              },
              text: biometricState.isFingerprintEnabled
                  ? 'Desactivar huella'
                  : 'Activar huella',
              buttonColor: biometricState.isFingerprintEnabled
                  ? Colors.red
                  : Colors.green,
            ),
          ),
        ]);
  }
}
