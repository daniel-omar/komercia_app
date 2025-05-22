import 'package:komercia_app/features/sales/domain/domain.dart';

class UserMapper {
  static User userJsonToEntity(Map<String, dynamic> json) => User(
      idUsuario: json["id_usuario"],
      nombre: json["nombre"],
      apellidoPaterno: json["apellido_paterno"],
      apellidoMaterno: json["apellido_materno"],
      correo: json["correo"]);
}
