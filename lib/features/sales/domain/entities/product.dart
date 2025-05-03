class Product {
  int idProducto;
  String codigoProducto;
  String nombreProducto;
  String? descripcionProducto;
  double? precio;
  double? precioVenta;
  double? precioCompra;
  int? idCategoria;
  int? idMarca;

  Product(
      {required this.idProducto,
      required this.codigoProducto,
      required this.nombreProducto,
      this.descripcionProducto,
      this.precio,
      this.precioVenta,
      this.precioCompra,
      this.idCategoria,
      this.idMarca});

  Map<String, dynamic> toJson() => {
        "id_producto": idProducto,
        "codigo_producto": codigoProducto,
        "nombre_producto": nombreProducto,
        "descripcion_producto": descripcionProducto,
        "precio": precio,
        "precio_venta": precioVenta,
        "precio_compra": precioCompra,
        "id_categoria": idCategoria,
        "id_marca": idMarca
      };
}
