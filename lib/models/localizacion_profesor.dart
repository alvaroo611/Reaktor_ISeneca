import 'package:iseneca/models/classroom.dart';
import 'package:iseneca/models/asignatura.dart';

class LocalizacionProfesor {
  Classroom classroom;
  Asignatura asignatura;

  LocalizacionProfesor({required this.classroom, required this.asignatura});
  factory LocalizacionProfesor.fromMap(Map<String, dynamic> mapa) {
    return LocalizacionProfesor(
      classroom: Classroom.fromJson(mapa['classroom']),
      asignatura: mapa['subject'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'classroom': classroom.toJson(), 'subject': asignatura.toJson()};
  }

  String toFormattedString() {
    return 'Detalles del Aula:\n${classroom.toFormattedString()}\n\nDetalles de la Asignatura:\n${asignatura.toFormattedString()}';
  }
}
