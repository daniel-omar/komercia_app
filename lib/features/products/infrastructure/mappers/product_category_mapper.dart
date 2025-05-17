import 'package:komercia_app/features/products/domain/domain.dart';

class ProductCategoryMapper {
  static ProductCategory productCategoryJsonToEntity(
          Map<String, dynamic> json) =>
      ProductCategory(
        idCategoria: json["id_categoria_producto"],
        nombreCategoria: json["nombre_categoria"],
      );
}
