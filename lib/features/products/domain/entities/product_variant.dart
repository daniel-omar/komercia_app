import 'package:komercia_app/features/sales/domain/entities/product_color.dart';
import 'package:komercia_app/features/sales/domain/entities/product_size.dart';

class ProductVariant {
  int idProducto;
  int? idProductoVariante;
  String? codigoProductoVariante;
  int idTalla;
  ProductSize? talla;
  int idColor;
  ProductColor? color;
  int cantidad;
  bool? esActivo;

  ProductVariant(
      {this.idProductoVariante,
      this.codigoProductoVariante,
      required this.idProducto,
      required this.idTalla,
      this.talla,
      required this.idColor,
      this.color,
      required this.cantidad,
      this.esActivo = true});

  Map<String, dynamic> toJson() => {
        "codigo_producto_variante": codigoProductoVariante,
        "id_producto": idProducto,
        "id_talla": idTalla,
        "id_color": idColor,
        "es_activo": esActivo
      };
}
