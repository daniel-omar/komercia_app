
class DiscountTypeEntity {
  final int idTipoDescuento;
  final String nombre;
  final String? descripcion;

  DiscountTypeEntity(
      {required this.idTipoDescuento, required this.nombre, this.descripcion});

  Map<String, dynamic> toJson() => {
        "id_tipo_descuento": idTipoDescuento,
        "nombre_tipo_descuento": nombre,
        "descripcion_tipo_descuento": descripcion
      };
}
