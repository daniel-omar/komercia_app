import 'package:komercia_app/features/products/domain/domain.dart';
import 'package:komercia_app/features/products/infrastructure/mappers/product_category_mapper.dart';

class ProductMapper {
  static Product productJsonToEntity(Map<String, dynamic> json) => Product(
        idProducto: json["id_producto"],
        codigoProducto: json["codigo_producto"],
        nombreProducto: json["nombre_producto"],
        descripcionProducto: json["descripcion_producto"],
        precio: json["precio"] == null ? null : double.parse(json["precio"]),
        precioVenta: json["precio_venta"] == null
            ? null
            : double.parse(json["precio_venta"]),
        precioCompra: json["precio_compra"] == null
            ? null
            : double.parse(json["precio_compra"]),
        idCategoria: json["id_categoria_producto"],
        categoria: json["categoria"] == null
            ? null
            : ProductCategoryMapper.productCategoryJsonToEntity(
                json["categoria"]),
        idMarca: json["id_marca"],
        cantidadDisponible: json["cantidad_disponible"] == null
            ? null
            : int.parse(json["cantidad_disponible"]),
        esActivo: json["es_activo"] ?? false,
      );

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
