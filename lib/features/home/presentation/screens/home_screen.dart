import 'package:go_router/go_router.dart';
import 'package:komercia_app/config/router/app_router.dart';
import 'package:komercia_app/features/home/presentation/providers/providers.dart';
import 'package:komercia_app/features/home/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:komercia_app/features/shared/shared.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MenuHome();
  }
}

class _MenuHome extends ConsumerStatefulWidget {
  const _MenuHome();

  @override
  _MenuHomeState createState() => _MenuHomeState();
}

class _MenuHomeState extends ConsumerState<_MenuHome>
    with SingleTickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuState = ref.watch(menusProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: MasonryGridView.count(
        // controller: scrollController,
        physics: const BouncingScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 25,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        itemCount: menuState.menus.length,
        itemBuilder: (context, index) {
          final menu = menuState.menus[index];
          return GestureDetector(
              onTap: () {
                ref.read(menusProvider.notifier).setMenu(menu);
                context.push(menu.rutaMenu);
              },
              child: MenuCard(menu: menu));
        },
      ),
    );
  }
}
