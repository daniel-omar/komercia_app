import 'package:komercia_app/features/products/domain/entities/product_category.dart';

class Product {
  int idProducto;
  String codigoProducto;
  String nombreProducto;
  String? descripcionProducto;
  double? precio;
  double? precioVenta;
  double? precioCompra;
  int? idCategoria;
  ProductCategory? categoria;
  int? idMarca;
  int? cantidadDisponible;

  Product(
      {required this.idProducto,
      required this.codigoProducto,
      required this.nombreProducto,
      this.descripcionProducto,
      this.precio,
      this.precioVenta,
      this.precioCompra,
      this.idCategoria,
      this.categoria,
      this.idMarca,
      this.cantidadDisponible});

  Map<String, dynamic> toJson() => {
        "id_producto": idProducto,
        "codigo_producto": codigoProducto,
        "nombre_producto": nombreProducto,
        "descripcion_producto": descripcionProducto,
        "precio": precio,
        "precio_venta": precioVenta,
        "precio_compra": precioCompra,
        "id_categoria_producto": idCategoria,
        "id_marca": idMarca
      };
}
