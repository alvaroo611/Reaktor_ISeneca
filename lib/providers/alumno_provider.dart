import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:core';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:iseneca/config/constantas.dart';
import 'package:iseneca/loggers/log.dart';

class ProviderAlumno extends ChangeNotifier {
  List<Student> _students = [];
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
        WEB_URL + '/send/csv-alumnos',
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

  Future<void> fetchStudents(http.Client client) async {
    try {
      final response = await client.get(
        Uri.parse(WEB_URL +
            '/horarios/get/sortstudents'), // Reemplaza con tu URL correcta
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
      nombresYApellidos
          .add('${student.name} ${student.lastName} ${student.course}');
    }
    return nombresYApellidos;
  }
}

// To parse this JSON data, do
//
//     final student = studentFromJson(jsonString);

Student studentFromJson(String str) => Student.fromJson(json.decode(str));

String studentToJson(Student data) => json.encode(data.toJson());

class Student {
  String name;
  String lastName;
  String course;
  String matriculationYear;
  String firstTutorLastName;
  String secondTutorLastName;
  String tutorName;
  String tutorPhone;
  String tutorEmail;

  Student({
    required this.name,
    required this.lastName,
    required this.course,
    required this.matriculationYear,
    required this.firstTutorLastName,
    required this.secondTutorLastName,
    required this.tutorName,
    required this.tutorPhone,
    required this.tutorEmail,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        name: json["name"],
        lastName: json["lastName"],
        course: json["course"],
        matriculationYear: json["matriculationYear"],
        firstTutorLastName: json["firstTutorLastName"],
        secondTutorLastName: json["secondTutorLastName"],
        tutorName: json["tutorName"],
        tutorPhone: json["tutorPhone"],
        tutorEmail: json["tutorEmail"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "lastName": lastName,
        "course": course,
        "matriculationYear": matriculationYear,
        "firstTutorLastName": firstTutorLastName,
        "secondTutorLastName": secondTutorLastName,
        "tutorName": tutorName,
        "tutorPhone": tutorPhone,
        "tutorEmail": tutorEmail,
      };
}
