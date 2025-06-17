import 'package:komercia_app/features/sales/domain/entities/product_category.dart';

class SaleProduct {
  int idProductoVariante;
  int idProducto;
  int? idColor;
  int? idTalla;
  int cantidad;
  double precio;
  bool? esSeleccionado;
  double? sub_total;

  SaleProduct(
      {required this.idProductoVariante,
      required this.idProducto,
      this.idColor,
      this.idTalla,
      required this.cantidad,
      required this.precio,
      this.esSeleccionado = false,
      this.sub_total});

  Map<String, dynamic> toJson() => {
        "id_producto_variante": idProductoVariante,
        "id_producto": idProducto,
        "id_color": idColor,
        "id_talla": idTalla,
        "cantidad": cantidad,
        "precio": precio,
        "sub_total": sub_total
      };
}

class SaleProductGroup {
  int idCategoria;
  ProductCategory? categoria;
  List<SaleProduct>? productos;

  SaleProductGroup({required this.idCategoria, this.categoria, this.productos});
}
