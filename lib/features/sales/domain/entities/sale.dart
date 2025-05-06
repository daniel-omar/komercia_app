import 'package:komercia_app/features/sales/domain/domain.dart';
import 'package:komercia_app/features/sales/domain/entities/discount_type.dart';

class Sale {
  int idVenta;
  int idTipoPago;
  PaymentType? tipoPago;
  bool tieneDescuento;
  int? idTipoDescuento;
  DiscountTypeEntity? tipoDescuento;
  double? descuento;
  double total;
  double totalSugerido;
  double totalFinal;
  int idUsuarioRegistro;
  User usuarioRegistro;
  int? idUsuarioActualizacion;
  User? usuarioActualizacion;
  String horaRegistro;
  String fechaRegistro;
  String? horaActualizacion;
  String? fechaActualizacion;
  List<SaleDetail>? saleDetail;

  Sale(
      {required this.idVenta,
      required this.idTipoPago,
      this.tipoPago,
      required this.tieneDescuento,
      this.idTipoDescuento,
      this.tipoDescuento,
      required this.descuento,
      required this.total,
      required this.totalSugerido,
      required this.totalFinal,
      required this.idUsuarioRegistro,
      required this.usuarioRegistro,
      this.idUsuarioActualizacion,
      this.usuarioActualizacion,
      required this.horaRegistro,
      required this.fechaRegistro,
      required this.horaActualizacion,
      required this.fechaActualizacion,
      this.saleDetail});

  Map<String, dynamic> toJson() => {
        "id_venta": idVenta,
        "id_tipo_pago": idTipoPago,
        "tiene_descuento": tieneDescuento,
        "id_tipo_descuento": idTipoDescuento,
        "descuento": descuento,
        "total": total,
        "total_sugerido": totalSugerido,
        "total_final": totalFinal,
        "id_usuario_registro": idUsuarioRegistro,
        "id_usuario_actualizacion": idUsuarioActualizacion,
        "hora_registro": horaRegistro,
        "fecha_registro": fechaRegistro,
        "hora_actualizacion": horaActualizacion,
        "fecha_actualizacion": fechaActualizacion
      };
}
