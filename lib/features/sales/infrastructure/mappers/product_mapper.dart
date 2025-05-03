import 'package:komercia_app/features/sales/domain/domain.dart';

class ProductMapper {
  static Product productJsonToEntity(Map<String, dynamic> json) => Product(
      idProducto: json["id_producto"],
      codigoProducto: json["codigo_producto"],
      nombreProducto: json["nombre_producto"],
      descripcionProducto: json["descripcion_producto"],
      precio: double.parse(json["precio"].toString()),
      precioVenta: double.parse(json["precio_venta"].toString()),
      precioCompra: json["precio_compra"] == null
          ? null
          : double.parse(json["precio_compra"].toString()),
      idCategoria: json["id_categoria_producto"],
      idMarca: json["id_marca"]);

  static productGroupJsonToEntity(Map<String, dynamic> json) {
    var list = json['productos'] as List;
    List<Product> itemsList =
        list.map((i) => ProductMapper.productJsonToEntity(i)).toList();

    return ProductCategory(
        idCategoria: json["id_categoria_producto"],
        nombreCategoria: json["nombre_categoria_producto"],
        productos: itemsList);
  }
}
