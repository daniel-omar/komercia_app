class ProductColor {
  int idColor;
  String nombreColor;
  String? descripcionColor;

  ProductColor({
    required this.idColor,
    required this.nombreColor,
    this.descripcionColor,
  });

  Map<String, dynamic> toJson() => {
        "id_color": idColor,
        "nombre_color": nombreColor,
        "descripcion_color": descripcionColor
      };
}
