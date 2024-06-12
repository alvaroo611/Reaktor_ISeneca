import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iseneca/config/constantas.dart';

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
  String get nombreCompleto {
    return '$primerApellido $segundoApellido $nombre';
  }
}
