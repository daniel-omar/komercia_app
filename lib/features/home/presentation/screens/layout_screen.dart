import 'package:komercia_app/features/home/presentation/providers/providers.dart';
import 'package:komercia_app/features/home/presentation/screens/home_screen.dart';
import 'package:komercia_app/features/home/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:komercia_app/features/sales/presentation/screens/balance_screen.dart';

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

  bool _isInit = false;
  String _title = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final menuState = ref.read(menusProvider);
      _tabController = TabController(
        vsync: this,
        length: 3,
      );
      _isInit = true;
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuState = ref.watch(menusProvider);

    return !menuState.isLoading
        ? Scaffold(
            drawer: SideMenu(scaffoldKey: widget.scaffoldKey),
            appBar: AppBar(
              title: Text(_title),
              backgroundColor: Colors.yellow[700],
              foregroundColor: Colors.black,
            ),
            body: IndexedStack(
              index: menuState.indexMenu,
              children: menuState.menusTabBar.map((item) {
                if (item.nombreMenu == 'Inicio') {
                  return const HomeScreen();
                } else if (item.nombreMenu == 'Inventario') {
                  return const Center(child: Text('Inventario'));
                } else if (item.nombreMenu == 'Balance') {
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
                _tabController.animateTo(_currentIndex);
              },
              items: menuState.menusTabBar.map((item) {
                return BottomNavigationBarItem(
                  icon: Icon(item.icono),
                  label: item.nombreMenu,
                );
              }).toList(),
            ),
          )
        : const FullScreenLoader();
  }
}
