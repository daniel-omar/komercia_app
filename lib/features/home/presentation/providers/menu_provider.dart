import 'package:komercia_app/config/router/app_router_notifier.dart';
import 'package:komercia_app/features/auth/domain/domain.dart';
import 'package:komercia_app/features/home/domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    final menus = await menuRepository.getMenusByUser(user.idUsuario!);
    final menusTabBar = await menuRepository.getMenusTabBarByUser(user);
    final menusSideBar = await menuRepository.getMenusSideBarByUser(user);

    if (menus.isEmpty) {
      state = state.copyWith(isLoading: false);
      return;
    }
    state = state.copyWith(
        isLoading: false,
        menus: [...state.menus, ...menus],
        menusTabBar: [...state.menusTabBar, ...menusTabBar],
        menusSideBar: [...state.menusSideBar, ...menusSideBar]);
  }

  Future setMenu(Menu menu) async {
    state =
        state.copyWith(isLoading: false, menus: [...state.menus], menu: menu);
  }

  void updateIndex(int newIndex) {
    state = state.copyWith(indexMenu: newIndex);
  }
}

class MenusState {
  final bool isLoading;
  final List<Menu> menus;
  final List<Menu> menusSideBar;
  final List<Menu> menusTabBar;
  final Menu? menu;
  final int indexMenu;

  MenusState(
      {this.isLoading = false,
      this.menus = const [],
      this.menusSideBar = const [],
      this.menusTabBar = const [],
      this.menu,
      this.indexMenu = 0});

  MenusState copyWith(
          {bool? isLoading,
          List<Menu>? menus,
          List<Menu>? menusSideBar,
          List<Menu>? menusTabBar,
          Menu? menu,
          int? indexMenu}) =>
      MenusState(
        isLoading: isLoading ?? this.isLoading,
        menus: menus ?? this.menus,
        menusSideBar: menusSideBar ?? this.menusSideBar,
        menusTabBar: menusTabBar ?? this.menusTabBar,
        menu: menu ?? this.menu,
        indexMenu: indexMenu ?? this.indexMenu,
      );
}
