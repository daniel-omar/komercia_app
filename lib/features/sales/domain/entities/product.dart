class Product {
  int idProducto;
  String codigoProducto;
  String nombreProducto;
  String? descripcionProducto;
  double? precio;
  int? idCategoria;
  int? idMarca;

  Product(
      {required this.idProducto,
      required this.codigoProducto,
      required this.nombreProducto,
      this.descripcionProducto,
      this.precio,
      this.idCategoria,
      this.idMarca});

  Map<String, dynamic> toJson() => {
        "id_producto": idProducto,
        "codigo_producto": codigoProducto,
        "nombre_producto": nombreProducto,
        "descripcion_producto": descripcionProducto,
        "precio": precio,
        "id_categoria": idCategoria,
        "id_marca": idMarca
      };
}
