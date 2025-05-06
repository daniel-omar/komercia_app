import '../entities/sale.dart';

abstract class SaleDatasource {
  Future<List<Sale>> getSalesByUser(int idUsuario,
      {int limit = 10, int offset = 0, List<int>? idsCategoriaProducto});
  Future<Sale> getSaleById(int idOrden);
  Future<bool> createSale(Map<String, dynamic> data);
  Future<List<Sale>> getSalesByFilter(
      {int? idTipoPago,
      bool? tieneDescuento,
      String? fechaInicio,
      String? fechaFin});
}
