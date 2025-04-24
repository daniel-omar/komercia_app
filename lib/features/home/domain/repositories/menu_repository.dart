import '../entities/menu.dart';

abstract class MenuRepository {
  Future<List<Menu>> getMenusByUser(int idUsuario);
  Future<Menu> getMenuById(int idMenu);
}
