class ProductVariant {
  int idProducto;
  int idTalla;
  int idColor;
  int cantidad;

  ProductVariant(
      {required this.idProducto,
      required this.idTalla,
      required this.idColor,
      required this.cantidad});

  Map<String, dynamic> toJson() =>
      {"id_producto": idProducto, "id_talla": idTalla, "id_color": idColor};
}
