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
    final menuState = ref.watch(menusProvider);

    return NavigationDrawer(
        elevation: 1,
        selectedIndex: menuState.indexMenu,
        onDestinationSelected: (value) {
          setState(() {
            navDrawerIndex = value;
          });

          ref.read(menusProvider.notifier).updateIndex(navDrawerIndex);

          widget.scaffoldKey.currentState?.closeDrawer();
          Navigator.pop(context);
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
              icon: Icon(menuSideBar.icono),
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
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                },
                text: 'Cerrar sesión'),
          ),
        ]);
  }
}
