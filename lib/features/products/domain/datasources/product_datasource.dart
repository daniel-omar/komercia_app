import 'package:komercia_app/features/products/domain/entities/product.dart';

abstract class ProductDatasource {
  Future<List<Product>> getByFilters({List<int>? idsCategoriaProducto});
  Future<Product> getById(int idProducto);
  Future<Product> find({int? idProducto, String? codigoProducto});
}
