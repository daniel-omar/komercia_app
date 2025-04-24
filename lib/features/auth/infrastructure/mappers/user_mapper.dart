import 'package:komercia_app/features/auth/domain/domain.dart';
import 'package:intl/intl.dart';

class UserMapper {
  static User userJsonToEntity(Map<String, dynamic> json) => User(
      idUsuario: json["id_usuario"],
      nombre: json["nombre"],
      apellidoPaterno: json["apellido_paterno"],
      apellidoMaterno: json["apellido_materno"],
      idTipoDocumento: json["id_tipo_documento"],
      numeroDocumento: json["numero_documento"],
      numeroTelefono: json["numero_telefono"],
      correo: json["correo"],
      fechaNacimiento: json["fecha_nacimiento"],
      idPerfil: json["id_perfil"],
      fechaHoraRegistro: DateTime.parse(json["fecha_hora_registro"]),
      fechaHoraActualizacion: json["fecha_hora_actualizacion"],
      idUsuarioRegistro: json["id_usuario_registro"],
      idUsuarioActualizacion: json["id_usuario_actualizacion"],
      esActivo: json["es_activo"],
      nombrePerfil: json["nombre_perfil"]);

  static User userLoginJsonToEntity(Map<String, dynamic> json) => User(
      idUsuario: json["usuario"]["id_usuario"],
      nombre: json["usuario"]["nombre"],
      apellidoPaterno: json["usuario"]["apellido_paterno"],
      apellidoMaterno: json["usuario"]["apellido_materno"],
      idTipoDocumento: json["usuario"]["id_tipo_documento"],
      numeroDocumento: json["usuario"]["numero_documento"],
      numeroTelefono: json["usuario"]["numero_telefono"],
      correo: json["usuario"]["correo"],
      //fechaNacimiento: json["usuario"]["fecha_nacimiento"],
      idPerfil: json["usuario"]["id_perfil"],
      fechaHoraRegistro: DateFormat("yyyy-MM-ddTHH:mm:ssZ")
          .parseUTC(json["usuario"]["fecha_hora_registro"])
          .toLocal(),
      //fechaHoraActualizacion: json["usuario"]["fecha_hora_actualizacion"],
      //idUsuarioRegistro: json["usuario"]["id_usuario_registro"],
      //idUsuarioActualizacion: json["usuario"]["id_usuario_actualizacion"],
      esActivo: json["usuario"]["es_activo"],
      nombrePerfil: json["usuario"]["nombre_perfil"],
      //roles: List<String>.from(json["roles"].map((role) => role)),
      token: json['token'] ?? '');
}
