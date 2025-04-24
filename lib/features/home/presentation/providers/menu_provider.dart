import 'package:komercia_app/config/router/app_router_notifier.dart';
import 'package:komercia_app/features/auth/domain/domain.dart';
import 'package:komercia_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:komercia_app/features/home/domain/domain.dart';
import 'package:komercia_app/features/home/domain/repositories/menu_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'menu_repository_provider.dart';

final menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  final menuRepository = ref.watch(menuRepositoryProvider);
  final goRouterNotifier = ref.read(goRouterNotifierProvider);

  return MenuNotifier(
      menuRepository: menuRepository, user: goRouterNotifier.user);
});

class MenuNotifier extends StateNotifier<MenuState> {
  final MenuRepository menuRepository;
  final User user;

  MenuNotifier({
    required this.menuRepository,
    required this.user,
  }) : super(MenuState()) {
    loadNextPage();
  }

  Future loadNextPage() async {
    if (state.isLoading || state.isLastPage) return;

    state = state.copyWith(isLoading: true);

    final menus = await menuRepository.getMenusByUser(user.idUsuario!);

    if (menus.isEmpty) {
      state = state.copyWith(isLoading: false, isLastPage: true);
      return;
    }

    state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: state.offset + 10,
        menus: [...state.menus, ...menus]);
  }

  Future getMenus() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    final menus = await menuRepository.getMenusByUser(1);

    if (menus.isEmpty) {
      state = state.copyWith(isLoading: false, isLastPage: true);
      return;
    }

    state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: state.offset + 10,
        menus: [...state.menus, ...menus]);
  }

  Future setMenu(Menu menu) async {
    state = state.copyWith(
        isLastPage: false,
        isLoading: false,
        offset: state.offset,
        menus: [...state.menus],
        menu: menu);
  }
}

class MenuState {
  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Menu> menus;
  final Menu? menu;

  MenuState(
      {this.isLastPage = false,
      this.limit = 10,
      this.offset = 0,
      this.isLoading = false,
      this.menus = const [],
      this.menu});

  MenuState copyWith(
          {bool? isLastPage,
          int? limit,
          int? offset,
          bool? isLoading,
          List<Menu>? menus,
          Menu? menu}) =>
      MenuState(
        isLastPage: isLastPage ?? this.isLastPage,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        isLoading: isLoading ?? this.isLoading,
        menus: menus ?? this.menus,
        menu: menu ?? this.menu,
      );
}
