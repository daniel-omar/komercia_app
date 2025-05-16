import 'package:komercia_app/config/config.dart';
import 'package:komercia_app/features/auth/domain/entities/permission.dart';
import 'package:komercia_app/features/auth/infrastructure/infrastructure.dart';
import 'package:komercia_app/features/home/domain/domain.dart';

class PermissionMapper {
  static jsonToEntity(Map<String, dynamic> json) => Permission(
        idMenu: json["id_menu"],
        nombreMenu: json["nombre_menu"],
        descripcionMenu: json["descripcion_menu"],
        rutaMenu: json["ruta_menu"],
        icono: json["icono_menu"],
        acciones: List<String>.from(json['acciones'] ?? []),
      );
}
