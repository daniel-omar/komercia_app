import 'package:komercia_app/features/sales/domain/domain.dart';

class Sale {
  int? idVenta;
  int idUsuarioRegistro;
  List<SaleDetail>? saleDetail;
  double total;

  Sale(
      {this.idVenta,
      required this.idUsuarioRegistro,
      this.saleDetail,
      required this.total});

  Map<String, dynamic> toJson() => {
        "id_venta": idVenta,
        "id_usuario_registro": idUsuarioRegistro,
        "total": total
      };
}
