import 'package:komercia_app/features/products/domain/domain.dart';

class ProductRepositoryImpl extends ProductRepository {
  final ProductDatasource datasource;

  ProductRepositoryImpl(this.datasource);

  @override
  Future<Product> getById(int idProducto) {
    return datasource.getById(idProducto);
  }

  @override
  Future<List<Product>> getByFilters({List<int>? idsCategoriaProducto}) {
    return datasource.getByFilters(idsCategoriaProducto: idsCategoriaProducto);
  }

  @override
  Future<Product> find({int? idProducto, String? codigoProducto}) {
    return datasource.find(
        idProducto: idProducto, codigoProducto: codigoProducto);
  }
}
