import 'package:iseneca/models/alumno_servcio.dart';

class DatosVisita {
  AlumnoServcio alumno;
  String horas;

  DatosVisita({
    required this.alumno,
    required this.horas,
  });

  factory DatosVisita.fromMap(Map<String, dynamic> mapa) {
    return DatosVisita(
      alumno: AlumnoServcio.fromJson(mapa['alumno']),
      horas: mapa['horas'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'alumno': alumno.toJson(),
      'horas': horas,
    };
  }
}
