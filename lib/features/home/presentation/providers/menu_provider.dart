import 'package:komercia_app/config/router/app_router_notifier.dart';
import 'package:komercia_app/features/auth/domain/domain.dart';
import 'package:komercia_app/features/auth/domain/entities/permission.dart';
import 'package:komercia_app/features/home/domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:komercia_app/features/shared/infrastructure/maps/general.map.dart';

import 'menu_repository_provider.dart';

final menusProvider =
    StateNotifierProvider.autoDispose<MenusNotifier, MenusState>((ref) {
  final menuRepository = ref.watch(menuRepositoryProvider);
  final goRouterNotifier = ref.read(goRouterNotifierProvider);

  return MenusNotifier(
      menuRepository: menuRepository, user: goRouterNotifier.user);
});

class MenusNotifier extends StateNotifier<MenusState> {
  final MenuRepository menuRepository;
  final User user;

  MenusNotifier({
    required this.menuRepository,
    required this.user,
  }) : super(MenusState()) {
    loadMenus();
  }

  Future loadMenus() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    final permisos = await menuRepository.permissions();

    if (permisos.isEmpty) {
      state = state.copyWith(isLoading: false);
      return;
    }

    final menus = toMenus(permisos);
    final menusHome_ = menus
        .where((menu) =>
            !["/balance", "/sale_detail", "/home","/products"].contains(menu.rutaMenu))
        .toList();
    final menusTab_ = menus
        .where((menu) => !["/new_sale", "/sale_detail"].contains(menu.rutaMenu))
        .toList();

    state = state.copyWith(
        isLoading: false,
        menus: [...state.menus, ...menus],
        menusHome: [...state.menus, ...menusHome_],
        menusTabBar: [...state.menusTabBar, ...menusTab_],
        menusSideBar: [...state.menusSideBar, ...menusTab_]);
  }

  Future setMenu(Menu menu) async {
    state =
        state.copyWith(isLoading: false, menus: [...state.menus], menu: menu);
  }

  void updateIndex(int newIndex) {
    state = state.copyWith(indexMenu: newIndex);
  }

  List<Menu> toMenus(List<Permission> permisos) {
    List<Menu> menus = [];
    for (var i = 0; i < permisos.length; i++) {
      final permiso = permisos[i];
      menus.add(Menu(
          idMenu: permiso.idMenu,
          nombreMenu: permiso.nombreMenu,
          descripcionMenu: permiso.descripcionMenu ?? "",
          rutaMenu: permiso.rutaMenu,
          icono: permiso.icono,
          acciones: permiso.acciones));
    }
    return menus.reversed.toList();
  }

  bool tienePermisoEdicion(String rutaMenu, String accion) {
    final permiso = state.menus.firstWhere((p) => p.rutaMenu == rutaMenu);
    final tieneAccion = permiso.acciones!.contains(menuActionsMap[accion]);

    return tieneAccion;
  }
}

class MenusState {
  final bool isLoading;
  final List<Menu> menus;
  final List<Menu> menusHome;
  final List<Menu> menusSideBar;
  final List<Menu> menusTabBar;
  final Menu? menu;
  final int indexMenu;

  MenusState(
      {this.isLoading = false,
      this.menusHome = const [],
      this.menus = const [],
      this.menusSideBar = const [],
      this.menusTabBar = const [],
      this.menu,
      this.indexMenu = 0});

  MenusState copyWith(
          {bool? isLoading,
          List<Menu>? menusHome,
          List<Menu>? menus,
          List<Menu>? menusSideBar,
          List<Menu>? menusTabBar,
          Menu? menu,
          int? indexMenu}) =>
      MenusState(
        isLoading: isLoading ?? this.isLoading,
        menusHome: menusHome ?? this.menusHome,
        menus: menus ?? this.menus,
        menusSideBar: menusSideBar ?? this.menusSideBar,
        menusTabBar: menusTabBar ?? this.menusTabBar,
        menu: menu ?? this.menu,
        indexMenu: indexMenu ?? this.indexMenu,
      );
}
