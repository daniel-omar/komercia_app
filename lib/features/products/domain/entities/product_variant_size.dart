import 'package:komercia_app/features/products/domain/entities/product_variant_size_detail.dart';

class ProductVariantSize {
  int idTalla;
  String nombreTalla;
  final List<ProductVariantSizeDetail> detalles;

  ProductVariantSize(
      {required this.idTalla,
      required this.nombreTalla,
      required this.detalles});

  Map<String, dynamic> toJson() =>
      {"id_talla": idTalla, "nombre_talla": nombreTalla};
}
