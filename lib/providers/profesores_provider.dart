import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfesoresProvider extends ChangeNotifier {
  List<Profesor> _profesores = [];

  List<Profesor> get profesores => _profesores;

  Future<void> fetchProfesores(http.Client client) async {
    try {
      // Se hace la petición al endpoint
      final response = await client.get(
        Uri.parse(
            'http://microservices-iesjandula.duckdns.org:8088/horarios/get/teachers'), // Reemplaza con tu URL correcta
        headers: {'Content-Type': 'application/json'},
      );

      // Se verifica si la petición fue exitosa
      if (response.statusCode == 200) {
        // Se decodifica la respuesta JSON
        final List<dynamic> responseData = json.decode(response.body);

        // Imprime la respuesta para verificar su estructura

        // Se mapea la lista de profesores
        _profesores = responseData
            .map((profesorData) => Profesor.fromJson(profesorData))
            .toList();
        print(_profesores);

        // Se notifica a los listeners del cambio en la lista de profesores
        notifyListeners();
      } else {
        // Imprime el código de estado en caso de error
        print('Failed to load profesores. Status code: ${response.statusCode}');

        // Lanza una excepción para manejar el error
        throw Exception('Failed to load profesores');
      }
    } catch (error) {
      // En caso de error, se maneja apropiadamente
      print('Error fetching profesores: $error');
      throw error;
    }
  }

  // Método para obtener nombres y apellidos de todos los profesores
  List<String> obtenerNombresYApellidos() {
    List<String> nombresYApellidos = [];
    for (var profesor in _profesores) {
      nombresYApellidos.add('${profesor.nombre} ${profesor.primerApellido}');
    }
    return nombresYApellidos;
  }
}

Profesor profesorFromJson(String str) => Profesor.fromJson(json.decode(str));

String profesorToJson(Profesor data) => json.encode(data.toJson());

class Profesor {
  String numIntPr;
  String abreviatura;
  String nombre;
  String primerApellido;
  String segundoApellido;

  Profesor({
    required this.numIntPr,
    required this.abreviatura,
    required this.nombre,
    required this.primerApellido,
    required this.segundoApellido,
  });

  factory Profesor.fromJson(Map<String, dynamic> json) => Profesor(
        numIntPr: json["numIntPR"],
        abreviatura: json["abreviatura"],
        nombre: json["nombre"],
        primerApellido: json["primerApellido"],
        segundoApellido: json["segundoApellido"],
      );

  Map<String, dynamic> toJson() => {
        "numIntPR": numIntPr,
        "abreviatura": abreviatura,
        "nombre": nombre,
        "primerApellido": primerApellido,
        "segundoApellido": segundoApellido,
      };
}
