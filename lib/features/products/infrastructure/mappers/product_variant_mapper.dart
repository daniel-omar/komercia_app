import 'package:komercia_app/features/products/domain/entities/product_variant_size.dart';
import 'package:komercia_app/features/products/domain/entities/product_variant_size_detail.dart';

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
        idColor: json['id_color'],
        nombreColor: json['nombre_color'],
        cantidad: json['cantidad'],
      );
}
