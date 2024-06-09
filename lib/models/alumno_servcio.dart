class AlumnoServcio {
  int alumnoId;
  String nombre;
  String apellidos;

  AlumnoServcio({
    required this.alumnoId,
    required this.nombre,
    required this.apellidos,
  });

  // Crear una instancia de Alumno a partir de un mapa (JSON)
  factory AlumnoServcio.fromJson(Map<String, dynamic> json) {
    return AlumnoServcio(
      alumnoId: json['alumnoId'],
      nombre: json['nombre'],
      apellidos: json['apellidos'],
    );
  }

  // Convertir una instancia de Alumno a un mapa (JSON)
  Map<String, dynamic> toJson() {
    return {
      'alumnoId': alumnoId,
      'nombre': nombre,
      'apellidos': apellidos,
    };
  }

  // Obtener el nombre completo del alumno
  String get nombreCompleto => '$nombre $apellidos';
}
