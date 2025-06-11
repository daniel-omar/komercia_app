import 'package:flutter/material.dart';
import 'package:komercia_app/features/shared/infrastructure/maps/general.map.dart';

class ProductColor {
  int idColor;
  String codigoColor;
  String nombreColor;
  String? descripcionColor;
  Color get color => colorMap[nombreColor] ?? Colors.grey;
  int? cantidad;

  ProductColor(
      {required this.codigoColor,
      required this.idColor,
      required this.nombreColor,
      this.descripcionColor,
      this.cantidad = 1});

  Map<String, dynamic> toJson() => {
        "id_color": idColor,
        "nombre_color": nombreColor,
        "descripcion_color": descripcionColor
      };
}
