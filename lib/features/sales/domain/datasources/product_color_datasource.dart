import 'package:komercia_app/features/sales/domain/entities/product_color.dart';

abstract class ProductColorDatasource {
  Future<List<ProductColor>> getAll();
  Future<List<ProductColor>> getByProduct(int idProducto);
  Future<List<ProductColor>> getList({int? idProducto, int? idTalla});
  Future<ProductColor> getById(int idColor);
}
