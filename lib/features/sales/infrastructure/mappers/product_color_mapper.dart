import 'package:komercia_app/features/sales/domain/entities/product_color.dart';

class ProductColorMapper {
  static ProductColor productColorJsonToEntity(Map<String, dynamic> json) =>
      ProductColor(
        idColor: json["id_color"],
        nombreColor: json["nombre_color"],
        cantidad: json["cantidad"],
      );
}
