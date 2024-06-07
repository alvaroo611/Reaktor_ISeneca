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
