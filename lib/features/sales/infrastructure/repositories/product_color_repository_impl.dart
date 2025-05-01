import 'package:komercia_app/features/sales/domain/domain.dart';

class ProductColorRepositoryImpl extends ProductColorRepository {
  final ProductColorDatasource datasource;

  ProductColorRepositoryImpl(this.datasource);

  @override
  Future<ProductColor> getById(int idColor) {
    return datasource.getById(idColor);
  }

  @override
  Future<List<ProductColor>> getAll() {
    return datasource.getAll();
  }

  @override
  Future<List<ProductColor>> getList(Map<String, dynamic> body) {
    return datasource.getList(body);
  }
}
