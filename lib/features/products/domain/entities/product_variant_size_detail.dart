import 'package:flutter/material.dart';
import 'package:komercia_app/features/shared/infrastructure/maps/general.map.dart';

class ProductVariantSizeDetail {
  final int idColor;
  final String nombreColor;
  Color get color => colorMap[nombreColor] ?? Colors.grey;
  final int cantidad;

  ProductVariantSizeDetail({
    required this.idColor,
    required this.nombreColor,
    required this.cantidad,
  });

  factory ProductVariantSizeDetail.fromJson(Map<String, dynamic> json) {
    return ProductVariantSizeDetail(
      idColor: json['id_color'],
      nombreColor: json['nombre_color'],
      cantidad: json['cantidad'],
    );
  }
}
