import 'package:komercia_app/features/sales/domain/domain.dart';
import 'package:image_picker/image_picker.dart';

class SaleRepositoryImpl extends SaleRepository {
  final SaleDatasource datasource;

  SaleRepositoryImpl(this.datasource);

  @override
  Future<List<Sale>> getSalesByUser(int idUsuario,
      {int limit = 10, int offset = 0, List<int>? idsCategoriaProducto}) {
    return datasource.getSalesByUser(idUsuario,
        limit: limit,
        offset: offset,
        idsCategoriaProducto: idsCategoriaProducto);
  }

  @override
  Future<Sale> getSaleById(int idOrden) {
    return datasource.getSaleById(idOrden);
  }

  @override
  Future<bool> createSale(Map<String, dynamic> data) {
    return datasource.createSale(data);
  }
}
