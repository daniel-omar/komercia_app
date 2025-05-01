import 'package:komercia_app/features/sales/domain/entities/product_size.dart';

class ProductSizeMapper {
  static ProductSize productSizeJsonToEntity(Map<String, dynamic> json) =>
      ProductSize(
        idTalla: json["id_talla"],
        nombreTalla: json["nombre_talla"],
      );
}
