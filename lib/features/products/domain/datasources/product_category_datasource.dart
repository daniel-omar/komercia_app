import 'package:komercia_app/features/products/domain/entities/product_category.dart';

abstract class ProductCategoryDatasource {
  Future<List<ProductCategory>> getAll();
  Future<List<ProductCategory>> getList(Map<String, dynamic> body);
  Future<ProductCategory> getById(int idCategoriaProducto);
}
