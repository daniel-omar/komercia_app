class Period {
  final int anio;
  final int? mes;
  final int? semana;
  final String etiqueta;
  final String fechaInicio;
  final String fechaFin;

  Period(
      {required this.anio,
      this.mes,
      this.semana,
      required this.etiqueta,
      required this.fechaInicio,
      required this.fechaFin});

  Map<String, dynamic> toJson() => {
        "anio": anio,
        "mes": mes,
        "semana": semana,
        "etiqueta": etiqueta,
        "fecha_inicio": fechaInicio,
        "fecha_fin": fechaFin
      };
}

class PeriodGroup {
  final List<Period> dias;
  final List<Period> semanas;
  final List<Period> meses;
  final List<Period> anios;

  PeriodGroup(
      {required this.dias,
      required this.semanas,
      required this.meses,
      required this.anios});
}
