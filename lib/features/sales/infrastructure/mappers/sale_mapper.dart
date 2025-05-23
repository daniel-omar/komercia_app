import 'package:komercia_app/features/sales/domain/domain.dart';
import 'package:komercia_app/features/sales/infrastructure/infrastructure.dart';
import 'package:komercia_app/features/sales/infrastructure/mappers/discount_type_mapper.dart';
import 'package:komercia_app/features/sales/infrastructure/mappers/user_mapper.dart';

class SaleMapper {
  static Sale saleJsonToEntity(Map<String, dynamic> json) => Sale(
      idVenta: json["id_venta"],
      concepto: json["concepto"] ?? "",
      idTipoPago: json["id_tipo_pago"],
      tipoPago: json["tipo_pago"] == null
          ? null
          : PaymentTypeMapper.paymentTypeJsonToEntity(json["tipo_pago"]),
      tieneDescuento: json["tiene_descuento"],
      idTipoDescuento: json["id_tipo_descuento"],
      tipoDescuento: json["tipo_descuento"] == null
          ? null
          : DiscountTypeMapper.discountTypeJsonToEntity(json["tipo_descuento"]),
      descuento:
          json["descuento"] == null ? null : double.parse(json["descuento"]),
      totalSugerido: double.parse(json["total_sugerido"]),
      total: double.parse(json["total"]),
      totalFinal: double.parse(json["total_final"]),
      idUsuarioRegistro: json["id_usuario_registro"],
      usuarioRegistro: UserMapper.userJsonToEntity(json["usuario_registro"]),
      idUsuarioActualizacion: json["id_usuario_actualizacion"],
      usuarioActualizacion: json["usuario_actualizacion"] == null
          ? null
          : UserMapper.userJsonToEntity(json["usuario_actualizacion"]),
      horaRegistro: json["hora_registro"],
      fechaRegistro: json["fecha_registro"],
      horaActualizacion: json["hora_actualizacion"],
      fechaActualizacion: json["fecha_actualizacion"]);
}

class SaleDetailMapper {
  static SaleDetail saleDetailJsonToEntity(Map<String, dynamic> json) =>
      SaleDetail(
        idVenta: int.parse(json["id_venta"]),
        idProducto: json["id_producto"],
        producto: ProductMapper.productJsonToEntity(json["producto"]),
        precio: json["precio"] == null ? null : double.parse(json["precio"]),
        cantidad: json["cantidad"],
        idTalla: json["id_talla"],
        talla: json["talla"] == null
            ? null
            : ProductSizeMapper.productSizeJsonToEntity(json["talla"]),
        idColor: json["id_color"],
        color: json["color"] == null
            ? null
            : ProductColorMapper.productColorJsonToEntity(json["color"]),
        subTotal:
            json["sub_total"] == null ? null : double.parse(json["sub_total"]),
        subTotalSugerido: json["sub_total_sugerido"] == null
            ? null
            : double.parse(json["sub_total_sugerido"]),
      );
}
