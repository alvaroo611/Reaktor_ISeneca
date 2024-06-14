import 'package:iseneca/models/centro_response.dart';

class Asignatura {
  String numIntAs;
  String abreviatura;
  String nombre;

  // Constructor
  Asignatura({
    required this.numIntAs,
    required this.abreviatura,
    required this.nombre,
  });

  factory Asignatura.fromJson(Map<String, dynamic> json) {
    return Asignatura(
      numIntAs: json['numIntAs'],
      abreviatura: json['abreviatura'],
      nombre: json['nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numIntAs': numIntAs,
      'abreviatura': abreviatura,
      'nombre': nombre,
    };
  }

  String toFormattedString() {
    return 'Número Interno: $numIntAs\n'
        'Abreviatura: $abreviatura\n'
        'Nombre: $nombre';
  }
}
