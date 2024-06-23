import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:core';
import 'package:convert/convert.dart';
// To parse this JSON data, do
//
//     final student = studentFromJson(jsonString);

Student studentFromJson(String str) => Student.fromJson(json.decode(str));

String studentToJson(Student data) => json.encode(data.toJson());
class Student {
  final String name;
  final String course;
  final String email;
  final String phoneStudent;
  final String phoneFather;
  final String phoneMother;

  Student({
    required this.name,
    required this.course,
    required this.email,
    required this.phoneStudent,
    required this.phoneFather,
    required this.phoneMother,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      name: json['nombre'],
      course: json['curso'],
      email: json['email'],
      phoneStudent: json['telefonoAlumno'],
      phoneFather: json['telefonoPadre'],
      phoneMother: json['telefonoMadre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': name,
      'curso': course,
      'email': email,
      'telefonoAlumno': phoneStudent,
      'telefonoPadre': phoneFather,
      'telefonoMadre': phoneMother,
    };
  }
}
