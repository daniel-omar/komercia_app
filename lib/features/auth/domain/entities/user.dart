class User {
  int? idUsuario;
  String nombre;
  String apellidoPaterno;
  String apellidoMaterno;
  int idTipoDocumento;
  String numeroDocumento;
  String? numeroTelefono;
  String correo;
  String? fechaNacimiento;
  int idPerfil;
  DateTime? fechaHoraRegistro;
  DateTime? fechaHoraActualizacion;
  int? idUsuarioRegistro;
  int? idUsuarioActualizacion;
  bool esActivo;
  String nombrePerfil;
  String? token;

  User(
      {this.idUsuario,
      required this.nombre,
      required this.apellidoPaterno,
      required this.apellidoMaterno,
      required this.idTipoDocumento,
      required this.numeroDocumento,
      this.numeroTelefono,
      required this.correo,
      this.fechaNacimiento,
      required this.idPerfil,
      this.fechaHoraRegistro,
      this.fechaHoraActualizacion,
      this.idUsuarioRegistro,
      this.idUsuarioActualizacion,
      required this.esActivo,
      required this.nombrePerfil,
      this.token});

  bool get isTechnical {
    return nombrePerfil.toLowerCase().contains('técnico');
  }

  Map<String, dynamic> toJson() => {
        "id_usuario": idUsuario,
        "nombre": nombre,
        "apellido_paterno": apellidoPaterno,
        "apellido_materno": apellidoMaterno,
        "id_tipo_documento": idTipoDocumento,
        "numero_documento": numeroDocumento,
        "numero_telefono": numeroTelefono,
        "correo": correo,
        "fecha_nacimiento": fechaNacimiento,
        "id_perfil": idPerfil,
        "fecha_hora_registro": fechaHoraRegistro?.toIso8601String(),
        "fecha_hora_actualizacion": fechaHoraActualizacion,
        "id_usuario_registro": idUsuarioRegistro,
        "id_usuario_actualizacion": idUsuarioActualizacion,
        "es_activo": esActivo,
        "nombre_perfil": nombrePerfil
      };
}
