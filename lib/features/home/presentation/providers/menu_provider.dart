import 'package:komercia_app/config/router/app_router_notifier.dart';
import 'package:komercia_app/features/auth/domain/domain.dart';
import 'package:komercia_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:komercia_app/features/home/domain/domain.dart';
import 'package:komercia_app/features/home/domain/repositories/menu_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'menu_repository_provider.dart';

final menusProvider = StateNotifierProvider<MenusNotifier, MenusState>((ref) {
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

  Future getMenus() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    final menus = await menuRepository.getMenusByUser(1);
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
}

class MenusState {
  final bool isLoading;
  final List<Menu> menus;
  final List<Menu> menusSideBar;
  final List<Menu> menusTabBar;
  final Menu? menu;

  MenusState(
      {this.isLoading = false,
      this.menus = const [],
      this.menusSideBar = const [],
      this.menusTabBar = const [],
      this.menu});

  MenusState copyWith(
          {bool? isLoading,
          List<Menu>? menus,
          List<Menu>? menusSideBar,
          List<Menu>? menusTabBar,
          Menu? menu}) =>
      MenusState(
        isLoading: isLoading ?? this.isLoading,
        menus: menus ?? this.menus,
        menusSideBar: menusSideBar ?? this.menusSideBar,
        menusTabBar: menusTabBar ?? this.menusTabBar,
        menu: menu ?? this.menu,
      );
}
