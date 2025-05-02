import 'package:komercia_app/features/sales/domain/entities/payment_type.dart';

class PaymentTypeMapper {
  static PaymentType paymentTypeJsonToEntity(Map<String, dynamic> json) =>
      PaymentType(
        idTipoPago: json["id_tipo_pago"],
        nombreTipoPago: json["nombre_tipo_pago"],
        descripcionTipoPago: json["descripcion_tipo_pago"],
        icono: json["icono"],
      );
}
