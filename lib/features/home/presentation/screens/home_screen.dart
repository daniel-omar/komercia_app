import 'package:go_router/go_router.dart';
import 'package:komercia_app/features/home/presentation/providers/providers.dart';
import 'package:komercia_app/features/home/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Accesos directos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _MenuHome()
        ],
      ),
    );
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

    return SizedBox(
      height: 145, // Ajusta según el tamaño de tus MenuCard
      child: ListView.separated(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
        itemCount: menuState.menusHome.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final menu = menuState.menusHome[index];
          return SizedBox(
            width: 140, // ancho fijo del card
            child: GestureDetector(
              child: MenuCard(
                menu: menu,
                onTap: () {
                  ref.read(menusProvider.notifier).setMenu(menu);
                  context.push(menu.rutaMenu);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
