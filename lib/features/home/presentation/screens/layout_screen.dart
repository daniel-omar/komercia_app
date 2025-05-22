import 'package:go_router/go_router.dart';
import 'package:komercia_app/features/home/presentation/providers/providers.dart';
import 'package:komercia_app/features/home/presentation/screens/home_screen.dart';
import 'package:komercia_app/features/home/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:komercia_app/features/products/presentation/screens/inventory_screen.dart';
import 'package:komercia_app/features/sales/presentation/screens/balance_screen.dart';
import 'package:komercia_app/features/sales/presentation/widgets/filter_options.dart';

import 'package:komercia_app/features/shared/shared.dart';

class LayoutScreen extends StatelessWidget {
  const LayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return _LayoutView(scaffoldKey: scaffoldKey);
  }
}

class _LayoutView extends ConsumerStatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const _LayoutView({super.key, required this.scaffoldKey});

  @override
  _LayoutViewState createState() => _LayoutViewState();
}

class _LayoutViewState extends ConsumerState<_LayoutView>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  final ScrollController scrollController = ScrollController();
  late TabController _tabController;

  String _title = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    final menuState = ref.watch(menusProvider);
    _title = menuState.menusTabBar.isNotEmpty
        ? menuState.menusTabBar[0].nombreMenu
        : "";

    // ref.listen<MenusState>(menusProvider, (previous, next) {
    //   if (!next.isLoading && previous!.menus.isEmpty) {
    //     _tabController = TabController(
    //       vsync: this,
    //       length: next.menusTabBar.length,
    //     );
    //   }
    // });

    return !menuState.isLoading
        ? Scaffold(
            key: widget.scaffoldKey,
            drawer: SideMenu(scaffoldKey: widget.scaffoldKey),
            appBar: AppBar(
              title: Text(_title),
              backgroundColor: Colors.yellow[700],
              foregroundColor: Colors.black,
              actions: [
                if (menuState.menu?.rutaMenu == "/balance") ...[
                  IconButton(
                    icon: const Icon(
                      Icons.filter_list,
                      color: Colors.black87,
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => FilterOptions()),
                      );
                    },
                  ),
                ]
              ],
            ),
            body: IndexedStack(
              index: menuState.indexMenu,
              children: menuState.menusTabBar.map((item) {
                if (item.rutaMenu == '/home') {
                  return const HomeScreen();
                } else if (item.rutaMenu == '/products') {
                  return const InventoryScreen();
                } else if (item.rutaMenu == '/balance') {
                  return const BalanceScreen();
                } else {
                  return Center(child: Text(item.nombreMenu)); // fallback
                }
              }).toList(),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: menuState.indexMenu,
              onTap: (currentIndex) {
                setState(() {
                  _currentIndex = currentIndex;
                  _title = menuState.menusTabBar[currentIndex].nombreMenu;
                });
                ref.read(menusProvider.notifier).updateIndex(currentIndex);
                ref
                    .read(menusProvider.notifier)
                    .setMenu(menuState.menusTabBar[currentIndex]);
                _tabController.animateTo(_currentIndex);
              },
              items: menuState.menusTabBar.map((item) {
                return BottomNavigationBarItem(
                  icon: Icon(item.iconData),
                  label: item.nombreMenu,
                );
              }).toList(),
            ),
          )
        : const FullScreenLoader();
  }
}
