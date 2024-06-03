import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:iseneca/loggers/log.dart';

class ProviderAlumno extends ChangeNotifier {
  List<Student> _students = [];
  final Dio _dio = Dio();
  List<Student> get students => _students;
  Future<void> loadCsvDataFromFile(http.Client client) async {
    try {
      // Leer el archivo CSV desde los activos
      ByteData csvBytes = await rootBundle.load('assets/CsvStudent.csv');
      List<int> csvList = csvBytes.buffer.asUint8List();

      // Crear un objeto FormData con el archivo CSV
      FormData formData = FormData.fromMap({
        'csvFile': MultipartFile.fromBytes(
          csvList,
          filename: 'CsvStudent.csv',
          contentType: MediaType('text', 'csv'),
        ),
      });

      // Crear una instancia de Dio
      Dio _dio = Dio();

      // Enviar la solicitud HTTP con Dio
      Response response = await _dio.post(
        'https://microservices-iesjandula.duckdns.org:8088/send/csv-alumnos',
        data: formData,
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        print("Datos cargados correctamente");
        // Reemplazar con tu servicio de log si es necesario
        LogService.logInfo("Datos cargados correctamente ");
        // Notificar a los oyentes si estás utilizando algún mecanismo de notificación
        notifyListeners();
      } else {
        print("Error al cargar los datos");
      }
    } catch (error) {
      print('Error al cargar el archivo CSV: $error');
    }
  }

  Future<void> fetchStudents(http.Client client) async {
    try {
      final response = await client.get(
        Uri.parse(
            'https://microservices-iesjandula.duckdns.org:8088/horarios/get/sortstudents'), // Reemplaza con tu URL correcta
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _students = jsonData
            .map((studentJson) => Student.fromJson(studentJson))
            .toList();
        notifyListeners();
      } else {
        //
        print('Error en la solicitud: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching alumnos: $error');
    }
  }

  List<String> getStudentNames() {
    List<String> nombresYApellidos = [];
    for (var student in students) {
      nombresYApellidos.add('${student.name} ');
    }
    return nombresYApellidos;
  }
}

List<Student> studentFromJson(String str) =>
    List<Student>.from(json.decode(str).map((x) => Student.fromJson(x)));

String studentToJson(List<Student> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Student {
  String name;

  Course course;

  Student({
    required this.name,
    required this.course,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        name: json["name"],
        course: Course.fromJson(json["course"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "course": course.toJson(),
      };
}

class Course {
  String name;

  Course({
    required this.name,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
      };
}
