import 'package:flutter/material.dart';
import 'package:komercia_app/features/shared/infrastructure/maps/general.map.dart';

class Permission {
  int idMenu;
  String nombreMenu;
  String? descripcionMenu;
  String rutaMenu;
  String? icono;
  IconData get iconData => iconMap[icono] ?? Icons.help_outline;
  List<String> acciones;
  int? idPadre;
  List<Permission>? hijos;

  Permission(
      {required this.idMenu,
      required this.nombreMenu,
      this.descripcionMenu,
      this.icono,
      required this.rutaMenu,
      required this.acciones,
      this.idPadre,
      this.hijos});

  factory Permission.fromJson(Map<String, dynamic> json) => Permission(
        idMenu: json["id_menu"],
        nombreMenu: json["nombre_menu"],
        descripcionMenu: json["descripcion_menu"],
        rutaMenu: json["ruta_menu"],
        icono: json["icono_menu"],
        acciones: List<String>.from(json["acciones"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id_menu": idMenu,
        "nombre_menu": nombreMenu,
        "descripcion_menu": descripcionMenu,
        "ruta_menu": rutaMenu,
        "icono_menu": icono,
        "acciones": List<dynamic>.from(acciones.map((x) => x)),
      };
}
