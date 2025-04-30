import 'package:image_picker/image_picker.dart';

import '../entities/sale.dart';

abstract class SaleRepository {
  Future<List<Sale>> getSalesByUser(int idUsuario,
      {int limit = 10, int offset = 0, List<int>? idsCategoriaProducto});
  Future<Sale> getSaleById(int idOrden);
  Future<bool> sell(
      Map<String, dynamic> data);
}
