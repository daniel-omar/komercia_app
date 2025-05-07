import 'package:flutter/material.dart';
import 'package:komercia_app/features/sales/domain/domain.dart';

class SaleDetail {
  int? idVentaDetalle;
  int idVenta;
  int idProducto;
  Product producto;
  double? precio;
  int cantidad;
  // int? idProductoVariable;
  int? idTalla;
  ProductSize? talla;
  int? idColor;
  ProductColor? color;
  double? subTotalSugerido;
  double? subTotal;

  SaleDetail({
    this.idVentaDetalle,
    required this.idVenta,
    required this.idProducto,
    required this.producto,
    this.precio,
    required this.cantidad,
    // this.idProductoVariable,
    this.idTalla,
    this.talla,
    this.idColor,
    this.color,
    this.subTotalSugerido,
    this.subTotal,
  });

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
