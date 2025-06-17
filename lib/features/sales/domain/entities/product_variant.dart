import 'package:komercia_app/features/sales/domain/entities/product_color.dart';
import 'package:komercia_app/features/sales/domain/entities/product_size.dart';

class ProductVariant {
  int idProducto;
  String? nombreProducto;
  int? idProductoVariante;
  String? codigoProductoVariante;
  int idTalla;
  ProductSize? talla;
  int idColor;
  ProductColor? color;
  int cantidad;
  bool? esActivo;
  double? precioVenta;
  double? precioCompra;

  ProductVariant(
      {this.idProductoVariante,
      this.codigoProductoVariante,
      required this.idProducto,
      this.nombreProducto,
      required this.idTalla,
      this.talla,
      required this.idColor,
      this.color,
      required this.cantidad,
      this.esActivo = true,
      this.precioCompra,
      this.precioVenta});

  Map<String, dynamic> toJson() => {
        "id_producto_variante": idProductoVariante,
        "codigo_producto_variante": codigoProductoVariante,
        "id_producto": idProducto,
        "id_talla": idTalla,
        "id_color": idColor,
        "es_activo": esActivo,
        "cantidad": cantidad,
        "precio_compra": precioCompra,
        "precio_venta": precioVenta
      };
}
