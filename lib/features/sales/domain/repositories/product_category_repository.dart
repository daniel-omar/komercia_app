import 'package:komercia_app/features/sales/domain/entities/product_category.dart';

abstract class ProductCategoryRepository {
  Future<List<ProductCategory>> getAll();
  Future<List<ProductCategory>> getList(Map<String, dynamic> body);
  Future<ProductCategory> getById(int idCategoriaProducto);
}
