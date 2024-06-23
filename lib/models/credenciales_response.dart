// To parse this JSON data, do
//
//     final welcome = welcomeFromMap(jsonString);

import 'dart:convert';

class CredencialesResponse {
  CredencialesResponse({
    required this.results,
  });

  List<Credenciales> results;

  factory CredencialesResponse.fromJson(String str) =>
      CredencialesResponse.fromMap(json.decode(str));

  factory CredencialesResponse.fromMap(Map<String, dynamic> json) =>
      CredencialesResponse(
        results: List<Credenciales>.from(
            json["results"].map((x) => Credenciales.fromMap(x))),
      );
}

class Credenciales {
  Credenciales({
    required this.id,
    required this.usuario,
    required this.rol,
    required this.nombre,
    required this.apellidos,
    required this.telefono,
  });

  String id;
  String usuario;
  String rol;
  String nombre;
  String apellidos;
  String telefono;
  String get nombreCompleto => '$nombre $apellidos';

  factory Credenciales.fromJson(String str) =>
      Credenciales.fromMap(json.decode(str));

  factory Credenciales.fromMap(Map<String, dynamic> json) => Credenciales(
        id: json["ID"],
        usuario: json["Usuario"],
        rol: json["Rol"],
        nombre: json["Nombre"],
        apellidos: json["Apellidos"],
        telefono: json["Teléfono"],
      );
}
