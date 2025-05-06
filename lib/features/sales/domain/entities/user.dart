class User {
  int idUsuario;
  String nombre;
  String apellidoPaterno;
  String apellidoMaterno;

  User(
      {required this.idUsuario,
      required this.nombre,
      required this.apellidoPaterno,
      required this.apellidoMaterno});

  Map<String, dynamic> toJson() => {
        "id_usuario": idUsuario,
        "nombre": nombre,
        "apellido_paterno": apellidoPaterno,
        "apellido_materno": apellidoMaterno
      };
}
