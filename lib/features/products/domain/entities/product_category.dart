import 'package:komercia_app/features/products/domain/domain.dart';

class ProductCategory {
  int idCategoria;
  String nombreCategoria;
  List<Product>? productos;

  ProductCategory(
      {required this.idCategoria,
      required this.nombreCategoria,
      this.productos});

  Map<String, dynamic> toJson() => {
        "id_categoria_producto": idCategoria,
        "nombre_categoria": nombreCategoria,
      };
}
