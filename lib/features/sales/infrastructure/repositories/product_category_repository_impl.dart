import 'package:komercia_app/features/sales/domain/domain.dart';

class ProductCategoryRepositoryImpl extends ProductCategoryRepository {
  final ProductCategoryDatasource datasource;

  ProductCategoryRepositoryImpl(this.datasource);

  @override
  Future<ProductCategory> getById(int idCategoriaProducto) {
    return datasource.getById(idCategoriaProducto);
  }

  @override
  Future<List<ProductCategory>> getAll() {
    return datasource.getAll();
  }

  @override
  Future<List<ProductCategory>> getList(Map<String, dynamic> body) {
    return datasource.getList(body);
  }
}
