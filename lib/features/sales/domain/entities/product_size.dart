class ProductSize {
  int idTalla;
  String codigoTalla;
  String nombreTalla;
  String? descripcionTalla;

  ProductSize({
    required this.codigoTalla,
    required this.idTalla,
    required this.nombreTalla,
    this.descripcionTalla,
  });

  Map<String, dynamic> toJson() => {
        "codigo_talla": codigoTalla,
        "id_talla": idTalla,
        "nombre_talla": nombreTalla,
        "descripcion_talla": descripcionTalla
      };
}
