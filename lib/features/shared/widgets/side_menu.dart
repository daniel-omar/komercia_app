import 'package:komercia_app/config/router/app_router_notifier.dart';
import 'package:komercia_app/features/auth/domain/domain.dart';
import 'package:komercia_app/features/auth/infrastructure/mappers/user_mapper.dart';
import 'package:komercia_app/features/home/domain/domain.dart';
import 'package:komercia_app/features/home/presentation/providers/menu_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/auth/presentation/providers/auth_provider.dart';
// import 'package:go_router/go_router.dart';
import 'package:komercia_app/features/shared/shared.dart';
import 'package:go_router/go_router.dart';

class SideMenu extends ConsumerStatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const SideMenu({super.key, required this.scaffoldKey});
  @override
  SideMenuState createState() => SideMenuState();
}

class SideMenuState extends ConsumerState<SideMenu> {
  int navDrawerIndex = 0;

  late User userData;

  @override
  Widget build(BuildContext context) {
    final hasNotch = MediaQuery.of(context).viewPadding.top > 35;
    final textStyles = Theme.of(context).textTheme;
    final goRouterNotifier = ref.read(goRouterNotifierProvider);
    final menuState = ref.watch(menuProvider);

    return NavigationDrawer(
        elevation: 1,
        selectedIndex: menuState.menu == null ? 0 : menuState.menu!.idMenu,
        onDestinationSelected: (value) {
          setState(() {
            navDrawerIndex = value;
          });

          if (navDrawerIndex == 0) {
            ref.read(menuProvider.notifier).setMenu(Menu(
                idMenu: 0,
                codigoMenu: "",
                nombreMenu: "",
                descripcionMenu: "",
                icono: Icons.home,
                rutaMenu: "/"));
            context.push("/");
          } else {
            final menuItem = menuState.menus[navDrawerIndex - 1];
            ref.read(menuProvider.notifier).setMenu(menuItem);
            context.push(menuItem.rutaMenu);
          }
          widget.scaffoldKey.currentState?.closeDrawer();
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
          const NavigationDrawerDestination(
            icon: Icon(Icons.home_mini_rounded),
            label: Text('Home'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.image_search_rounded),
            label: Text('Productos'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.warehouse_rounded),
            label: Text('Ordenes'),
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
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                },
                text: 'Cerrar sesión'),
          ),
        ]);
  }
}
