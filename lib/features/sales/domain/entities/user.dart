class User {
  int idUsuario;
  String nombre;
  String apellidoPaterno;
  String apellidoMaterno;
  String? correo;

  User(
      {required this.idUsuario,
      required this.nombre,
      required this.apellidoPaterno,
      required this.apellidoMaterno,
      this.correo});

  Map<String, dynamic> toJson() => {
        "id_usuario": idUsuario,
        "nombre": nombre,
        "apellido_paterno": apellidoPaterno,
        "apellido_materno": apellidoMaterno
      };
}
