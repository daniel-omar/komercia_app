import 'package:komercia_app/features/auth/domain/entities/user.dart';

import '../entities/menu.dart';

abstract class MenuDatasource {
  Future<List<Menu>> getMenusByUser(int idUsuario);
  Future<List<Menu>> getMenusTabBarByUser(User user);
  Future<List<Menu>> getMenusSideBarByUser(User user);
  Future<Menu> getMenuById(int idMenu);
}
