import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:iseneca/models/servicio_response.dart';

class ServicioProvider extends ChangeNotifier {
  List<Servicio> listadoAlumnosServicio = [];
  List<String> nombresAlumnosOrdenados = [];
  final baseUrl =
      'https://script.google.com/macros/s/AKfycbww17NqHZU5opz9SkMtUASKZOg1Hg6KsExRSvlqAMyrx4i0Ax9P5I7IQtKRcnsMKVivdw/exec';
  final spreadsheetId = '1u79XugcalPc4aPcymy9OsWu1qdg8aKCBvaPWQOH187I';
  final sheet = 'Servicio';

  ServicioProvider() {
    debugPrint("Servicio Provider inicializado");
  }
  Future<List<Servicio>> getServiciosPorAlumno(String nombreAlumno) async {
    List<Servicio> serviciosAlumno = listadoAlumnosServicio
        .where((servicio) => servicio.nombreAlumno == nombreAlumno)
        .toList();

    return serviciosAlumno;
  }

  Future<void> getAlumnosServicio(BuildContext context) async {
    final url = Uri.parse(
        "https://script.google.com/macros/s/AKfycbyPsB_koj3MwkmRFn8IJU-k4sOP8nRfnHHKNNt9xov9INZ1VEsQbu96gDR8Seiz0oDGOQ/exec?spreadsheetId=1u79XugcalPc4aPcymy9OsWu1qdg8aKCBvaPWQOH187I&sheet=Servicio");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final servicioResponse = ServicioResponse.fromMap({'results': data});
        listadoAlumnosServicio = servicioResponse.result;
        notifyListeners();
      } else {
        print('Error en la solicitud: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error en la solicitud: ${response.statusCode}')));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<List<Servicio>> getServiciosPorFecha(
      DateTime fechaInicio, DateTime fechaFin) async {
    List<Servicio> serviciosEnRango = listadoAlumnosServicio.where((servicio) {
      DateTime fechaEntrada =
          DateFormat("dd/MM/yyyy").parse(servicio.fechaEntrada);
      return (fechaEntrada.isAfter(fechaInicio) &&
              fechaEntrada.isBefore(fechaFin)) ||
          fechaEntrada.isAtSameMomentAs(fechaInicio) ||
          fechaEntrada.isAtSameMomentAs(fechaFin);
    }).toList();

    return serviciosEnRango;
  }

  Future<void> sendData(
      String nombreAlumno,
      String fechaEntrada,
      String horaEntrada,
      String fechaSalida,
      String horaSalida,
      BuildContext context) async {
    final Uri url = Uri.parse(
        'https://script.google.com/macros/s/AKfycbzj0UpLfXpp9tza9njVytvs9Ovi77oV7GRN1lSfmljf_bS6PkqUgAwGGdOYlPXe9zXd/exec'
        '?spreadsheetId=1u79XugcalPc4aPcymy9OsWu1qdg8aKCBvaPWQOH187I'
        '&sheet=Servicio'
        '&nombreAlumno=$nombreAlumno'
        '&fechaEntrada=$fechaEntrada'
        '&horaEntrada=$horaEntrada'
        '&fechaSalida=$fechaSalida'
        '&horaSalida=$horaSalida');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        final String message = data['message'] as String;
        print('Respuesta: $message');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      } else {
        print('Error en la solicitud: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error en la solicitud: ${response.statusCode}')));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void showSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _setAlumnos(
      String baseurl,
      String api,
      String pagina,
      String hoja,
      String nombre,
      String fechaEntrada,
      String fechaSalida) async {
    final url = Uri.https(baseurl, api, {
      "spreadsheetId": pagina,
      "sheet": hoja,
      "nombreAlumno": nombre,
      "fechaEntrada": fechaEntrada,
      "fechaSalida": fechaSalida
    });

    await http.get(url);
  }
}
