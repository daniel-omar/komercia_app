import 'package:komercia_app/features/sales/domain/entities/sale_detail.dart';
import '../entities/sale.dart';

abstract class SaleDatasource {
  Future<List<Sale>> getSalesByUser(int idUsuario,
      {int limit = 10, int offset = 0, List<int>? idsCategoriaProducto});
  Future<Sale> getSaleById(int idVenta);
  Future<bool> createSale(Map<String, dynamic> data);
  Future<List<Sale>> getSalesByFilter(
      {List<int>? idsTipoPago,
      List<int>? idsUsuarioRegistro,
      bool? tieneDescuento,
      String? fechaInicio,
      String? fechaFin});
  Future<List<SaleDetail>> getSaleDetails(int idVenta);
  Future<bool> updateActive(Map<String, dynamic> data);
}
