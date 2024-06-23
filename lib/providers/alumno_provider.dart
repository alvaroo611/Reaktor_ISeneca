import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:core';
import 'package:convert/convert.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:iseneca/config/constantas.dart';
import 'package:iseneca/loggers/log.dart';
import 'package:iseneca/models/Student.dart';

class ProviderAlumno extends ChangeNotifier {
  List<Student> _students = [];
  final String baseUrl =
      'https://script.google.com/macros/s/AKfycbww17NqHZU5opz9SkMtUASKZOg1Hg6KsExRSvlqAMyrx4i0Ax9P5I7IQtKRcnsMKVivdw/exec';
  final Dio _dio = Dio();
  List<Student> get students => _students;

  Future<void> loadCsvDataFromFile(http.Client client) async {
    try {
      // Leer el archivo CSV desde los activos
      ByteData csvBytes =
          await rootBundle.load('assets/AlumnadoCentroUnidad.csv');
      List<int> csvList = csvBytes.buffer.asUint8List();

      // Crear un objeto FormData con el archivo CSV
      FormData formData = FormData.fromMap({
        'csvFile': MultipartFile.fromBytes(
          csvList,
          filename: 'AlumnadoCentroUnidad.csv',
          contentType: MediaType('text', 'csv'),
        ),
      });

      // Crear una instancia de Dio
      Dio _dio = Dio();

      // Enviar la solicitud HTTP con Dio
      Response response = await _dio.post(
        WEB_URL + '/horarios/send/csv-alumnos',
        data: formData,
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        print("Datos cargados correctamente de  csv");
        // Reemplazar con tu servicio de log si es necesario
        LogService.logInfo("Datos cargados correctamente");
        // Notificar a los oyentes si estás utilizando algún mecanismo de notificación
        notifyListeners();
      } else {
        print("Error al cargar los datos del csv");
      }
    } catch (error) {
      print('Error al cargar el archivo CSV: $error');
    }
  }

  Future<List<Student>> fetchStudents(http.Client client) async {
    try {
      final response = await client.get(
        Uri.parse(WEB_URL +
            '/horarios/get/sortstudents'), // Reemplaza con tu URL correcta
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _students =
            List<Student>.from(data.map((item) => Student.fromJson(item)));
        notifyListeners();
        return _students;
      } else {
        throw Exception('Failed to load students');
      }
    } catch (error) {
      print('Error fetching alumnos: $error');
    }
    return _students;
  }

  List<String> getStudentNames() {
    List<String> nombresYApellidos = [];
    for (var student in students) {
      // Construir la cadena completa
      String fullName = '${student.name}  ${student.course}';
      // Convertir la cadena de ISO-8859-1 a UTF-8
      String utf8 = _convertIsoToUtf8(fullName);
      // Añadir la cadena convertida a la lista
      nombresYApellidos.add(utf8);
    }
    return nombresYApellidos;
  }

  Future<void> fetchData(BuildContext context) async {
    final Uri url = Uri.parse(
        'https://script.google.com/macros/s/AKfycbyPsB_koj3MwkmRFn8IJU-k4sOP8nRfnHHKNNt9xov9INZ1VEsQbu96gDR8Seiz0oDGOQ/exec?spreadsheetId=11Y4M52bYFMCIa5uU52vKll2-OY0VtFiGK2PhMWShngg&sheet=Datos_Alumnado');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        _students = data.map((json) => Student.fromJson(json)).toList();
        _showSnackbar(context, 'Datos cargados correctamente');
      } else {
        print('Error en la solicitud: ${response.statusCode}');
        throw Exception('Error en la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      _showSnackbar(context, 'Error al cargar datos: $e');
      throw Exception('Error: $e');
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _convertIsoToUtf8(String isoString) {
    // Convertir la cadena a bytes en ISO-8859-1
    List<int> isoBytes = latin1.encode(isoString);
    // Decodificar los bytes a UTF-8
    return utf8.decode(isoBytes);
  }
}
