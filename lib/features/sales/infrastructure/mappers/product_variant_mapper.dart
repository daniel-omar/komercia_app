import 'package:komercia_app/features/sales/domain/entities/product_variant.dart';
import 'package:komercia_app/features/sales/infrastructure/infrastructure.dart';

class ProductVariantMapper {
  static ProductVariant productVariantJsonToEntity(Map<String, dynamic> json) =>
      ProductVariant(
        idProducto: json['id_producto'],
        nombreProducto: json['nombre_producto'],
        idProductoVariante: json['id_producto_variante'],
        codigoProductoVariante: json['codigo_producto_variante'],
        idTalla: json['id_talla'],
        talla: json["talla"] != null
            ? ProductSizeMapper.productSizeJsonToEntity(json["talla"])
            : null,
        idColor: json['id_color'],
        color: json["color"] != null
            ? ProductColorMapper.productColorJsonToEntity(json["color"])
            : null,
        esActivo: json['es_activo'],
        cantidad: json['cantidad'] ?? 0,
        precioVenta: json["precio_venta"] == null
            ? null
            : double.parse(json["precio_venta"]),
        precioCompra: json["precio_compra"] == null
            ? null
            : double.parse(json["precio_compra"].toString()),
      );
}
