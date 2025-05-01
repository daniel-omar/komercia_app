import 'package:komercia_app/features/sales/domain/domain.dart';

class ProductSizeRepositoryImpl extends ProductSizeRepository {
  final ProductSizeDatasource datasource;

  ProductSizeRepositoryImpl(this.datasource);

  @override
  Future<ProductSize> getById(int idTalla) {
    return datasource.getById(idTalla);
  }

  @override
  Future<List<ProductSize>> getAll() {
    return datasource.getAll();
  }

  @override
  Future<List<ProductSize>> getList(Map<String, dynamic> body) {
    return datasource.getList(body);
  }
}
