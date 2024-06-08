import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iseneca/config/constantas.dart';
import 'package:iseneca/models/profesor.dart';

class ProfesoresProvider extends ChangeNotifier {
  List<Profesor> _profesores = [];

  List<Profesor> get profesores => _profesores;

  Future<List<Profesor>> fetchProfesores(http.Client client) async {
    try {
      // Se hace la petición al endpoint
      final response = await client.get(
        Uri.parse(WEB_URL +
            '/horarios/get/teachers'), // Reemplaza con tu URL correcta
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
    return _profesores;
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
