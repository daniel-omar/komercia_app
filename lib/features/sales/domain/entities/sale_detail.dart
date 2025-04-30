import 'package:flutter/material.dart';

class SaleDetail {
  int? idVentaDetalle;
  int? idVenta;
  int idProducto;
  int cantidad;
  double? precio;
  int? idProductoVariable;
  int? idTalla;
  int? idColor;

  SaleDetail(
      {required this.idVentaDetalle,
      required this.idVenta,
      required this.idProducto,
      required this.cantidad,
      this.precio,
      this.idProductoVariable,
      this.idTalla,
      this.idColor});

  Map<String, dynamic> toJson() => {
        "id_venta_detalle": idVentaDetalle,
        "id_venta": idVenta,
        "id_producto": idProducto,
        "cantidad": cantidad,
        "precio": precio,
        "id_talla": idTalla,
        "id_color": idColor
      };
}
