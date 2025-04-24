import '../entities/menu.dart';

abstract class MenuDatasource {
  Future<List<Menu>> getMenusByUser(int idUsuario);
  Future<Menu> getMenuById(int idMenu);
}
