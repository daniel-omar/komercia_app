import 'package:komercia_app/features/sales/domain/entities/discount_type.dart';

class DiscountTypeMapper {
  static DiscountTypeEntity discountTypeJsonToEntity(
          Map<String, dynamic> json) =>
      DiscountTypeEntity(
          idTipoDescuento: json["id_tipo_descuento"],
          nombre: json["nombre_tipo_descuento"],
          descripcion: json["descripcion_tipo_descuento"]);
}
