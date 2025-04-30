import 'package:komercia_app/features/sales/domain/domain.dart';

class SaleMapper {
  static Sale saleJsonToEntity(Map<String, dynamic> json) => Sale(
      idVenta: json["idVenta"],
      idUsuarioRegistro: json["idUsuarioRegistro"],
      total: json["total"]);
}
