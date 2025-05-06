import 'package:komercia_app/features/sales/domain/entities/period.dart';

class PeriodMapper {
  static Period periodJsonToEntity(Map<String, dynamic> json) => Period(
        anio: json["anio"],
        mes: json["mes"],
        semana: json["semana"],
        etiqueta: json["etiqueta"],
        fechaInicio: json["fecha_inicio"],
        fechaFin: json["fecha_fin"],
      );

  static periodGroupJsonToEntity(Map<String, dynamic> json) {
    var listDias = json['dias'] as List;
    var listSemanas = json['semanas'] as List;
    var listMeses = json['meses'] as List;
    var listAnios = json['anios'] as List;
    List<Period> dias =
        listDias.map((i) => PeriodMapper.periodJsonToEntity(i)).toList();
    List<Period> semanas =
        listSemanas.map((i) => PeriodMapper.periodJsonToEntity(i)).toList();
    List<Period> meses =
        listMeses.map((i) => PeriodMapper.periodJsonToEntity(i)).toList();
    List<Period> anios =
        listAnios.map((i) => PeriodMapper.periodJsonToEntity(i)).toList();
    return PeriodGroup(
        dias: dias, semanas: semanas, meses: meses, anios: anios);
  }
}
