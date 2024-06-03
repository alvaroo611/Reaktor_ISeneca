import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProviderAlumno extends ChangeNotifier {
  List<Student> _students = [];

  List<Student> get students => _students;

  Future<void> fetchStudents(http.Client client) async {
    const url =
        'https://microservices-iesjandula.duckdns.org:8088/horarios/get/sortstudents';

    try {
      final response = await http.get(Uri.parse(url));

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
      print('Error de red: $error');
    }
  }

  List<String> getStudentNames() {
    return _students.map((student) => student.name).toList();
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
