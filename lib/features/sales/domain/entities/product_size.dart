class ProductSize {
  int idTalla;
  String nombreTalla;
  String? descripcionTalla;

  ProductSize({
    required this.idTalla,
    required this.nombreTalla,
    this.descripcionTalla,
  });

  Map<String, dynamic> toJson() => {
        "id_talla": idTalla,
        "nombre_talla": nombreTalla,
        "descripcion_talla": descripcionTalla
      };
}
