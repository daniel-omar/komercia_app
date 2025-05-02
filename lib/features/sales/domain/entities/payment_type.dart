import 'package:flutter/material.dart';
import 'package:komercia_app/features/shared/infrastructure/maps/general.map.dart';

class PaymentType {
  int idTipoPago;
  String nombreTipoPago;
  String? descripcionTipoPago;
  String? icono;
  IconData get iconData => iconMap[icono] ?? Icons.help_outline;

  PaymentType(
      {required this.idTipoPago,
      required this.nombreTipoPago,
      this.descripcionTipoPago,
      this.icono});

  Map<String, dynamic> toJson() => {
        "id_tipo_pago": idTipoPago,
        "nombre_tipo_pago": nombreTipoPago,
        "descripcion_tipo_pago": descripcionTipoPago,
        "icono": icono
      };
}
