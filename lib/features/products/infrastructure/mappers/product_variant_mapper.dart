import 'package:komercia_app/features/products/domain/entities/product_variant.dart';
import 'package:komercia_app/features/products/domain/entities/product_variant_size.dart';
import 'package:komercia_app/features/products/domain/entities/product_variant_size_detail.dart';
import 'package:komercia_app/features/sales/infrastructure/infrastructure.dart';

class ProductVariantSizeMapper {
  static ProductVariantSize productVariantJsonToEntity(
          Map<String, dynamic> json) =>
      ProductVariantSize(
        idTalla: json['id_talla'],
        nombreTalla: json['nombre_talla'],
        detalles: (json['detalles'] as List)
            .map((e) =>
                ProductVariantSizeDetailMapper.productVariantDetailJsonToEntity(
                    e))
            .toList(),
      );
}

class ProductVariantSizeDetailMapper {
  static ProductVariantSizeDetail productVariantDetailJsonToEntity(
          Map<String, dynamic> json) =>
      ProductVariantSizeDetail(
        codigoProductoVariante: json['codigo_producto_variante'],
        idColor: json['id_color'],
        nombreColor: json['nombre_color'],
        cantidad: json['cantidad'],
      );
}

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
      );
}
