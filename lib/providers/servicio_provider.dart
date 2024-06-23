import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iseneca/models/Student.dart';
import 'package:iseneca/models/alumno_servcio.dart';
import 'package:iseneca/models/datos_visita.dart';
import 'package:iseneca/models/servicio_response.dart';
import 'package:iseneca/utils/utilidades.dart';
import 'package:iseneca/config/constantas.dart';
import 'dart:convert';

class ServicioProvider extends ChangeNotifier {
  List<Servicio> listadoAlumnosServicio = [];
  late List<Map<String, dynamic>> visitas;
  final baseUrl =
      'https://script.google.com/macros/s/AKfycbww17NqHZU5opz9SkMtUASKZOg1Hg6KsExRSvlqAMyrx4i0Ax9P5I7IQtKRcnsMKVivdw/exec';
  final spreadsheetId = '1u79XugcalPc4aPcymy9OsWu1qdg8aKCBvaPWQOH187I';
  final sheet = 'Servicio';

  List<AlumnoServcio> getAlumnoFromMap() {
    List<AlumnoServcio> alumnos = [];
    Set<int> alumnoIdsUnicos = Set<int>();

    visitas.forEach((mapa) {
      if (mapa.containsKey("alumno")) {
        AlumnoServcio alumno = AlumnoServcio.fromJson(mapa["alumno"]);

        if (!alumnoIdsUnicos.contains(alumno.alumnoId)) {
          alumnos.add(alumno);
          alumnoIdsUnicos.add(alumno.alumnoId);
        }
      }
    });

    return alumnos;
  }

  List<String> getNombresAlumnosFromMap() {
    Set<String> nombresAlumnos = {};

    visitas.forEach((mapa) {
      if (mapa.containsKey("alumno")) {
        AlumnoServcio alumno = AlumnoServcio.fromJson(mapa["alumno"]);
        nombresAlumnos.add(alumno.nombreCompleto);
      }
    });

    return nombresAlumnos.toList();
  }

  List<DatosVisita> getDatosVisitasFromMap(int alumnoId) {
    List<DatosVisita> datosVisitas = [];

    visitas.forEach((mapa) {
      if (mapa.containsKey("alumno") && mapa.containsKey("horas")) {
        AlumnoServcio alumno = AlumnoServcio.fromJson(mapa['alumno']);
        String horas = mapa['horas'];
        String dia = mapa['dia'];
        if (alumno.alumnoId == alumnoId) {
          datosVisitas.add(DatosVisita(alumno: alumno, horas: horas, dia: dia));
        }
      }
    });

    return datosVisitas;
  }

  Future<void> fetchStudentVisits(
      String fechaInicio, String fechaFin, BuildContext context) async {
    String formattedFechaInicio = fechaInicio.replaceAll('-', '/');
    String formattedFechaFin = fechaFin.replaceAll('-', '/');

    final url = Uri.parse(WEB_URL +
        '/horarios/get/students/visitas/bathroom?fechaInicio=$formattedFechaInicio&fechaFin=$formattedFechaFin');

    try {
      print('URL: $url');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        try {
          print('Response Body: ${response.body}');
          visitas = List<Map<String, dynamic>>.from(json.decode(response.body));
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Datos cargados correctamente')));
        } catch (e) {
          print('Error al decodificar la respuesta JSON: $e');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error al procesar los datos del servidor.')));
        }
      } else if (response.statusCode == 500) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error servidor')),
        );
      } else {
        print('Error al obtener la lista de visitas: ${response.statusCode}');
        print('Response Body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Error al cargar las visitas de los estudiantes al baño. ${response.body}')));
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error de red al intentar obtener los datos.')));
    }
  }

  final _url = "script.google.com";
  final _apiEscritura =
      "macros/s/AKfycbz7ZwCTn2XXpXuPO2-m9tyR1sIC9lOMgvPPOsbDehda2NRoko871PvZvzF1jQnaq8Du/exec";
  final _idHoja = "1Jq4ihUzE5r4fqK9HHZQv1dg4AAgzdjPbGkpJRByu-Ds";
  final _hojaServicio = "Servicio";

  ServicioProvider() {
    debugPrint("Servicio Provider inicializado");
    getAlumnosServicio();
  }

  getAlumnosServicio() async {
    const url =
        "https://script.google.com/macros/s/AKfycbyPsB_koj3MwkmRFn8IJU-k4sOP8nRfnHHKNNt9xov9INZ1VEsQbu96gDR8Seiz0oDGOQ/exec?spreadsheetId=1u79XugcalPc4aPcymy9OsWu1qdg8aKCBvaPWQOH187I&sheet=Servicio";
    String jsonData = await Utilidades.getJsonData(url);
    jsonData = '{"results":$jsonData}';
    final servicioResponse = ServicioResponse.fromJson(jsonData);
    listadoAlumnosServicio = servicioResponse.result;
    notifyListeners();
  }

  Future<void> sendData(
      String nombreAlumno,
      String fechaEntrada,
      String horaEntrada,
      String fechaSalida,
      String horaSalida,
      BuildContext context) async {
    final Uri url = Uri.parse(
        'https://script.google.com/macros/s/AKfycbww17NqHZU5opz9SkMtUASKZOg1Hg6KsExRSvlqAMyrx4i0Ax9P5I7IQtKRcnsMKVivdw/exec?spreadsheetId=1u79XugcalPc4aPcymy9OsWu1qdg8aKCBvaPWQOH187I&sheet=Servicio&nombreAlumno=$nombreAlumno&fechaEntrada=$fechaEntrada&horaEntrada=$horaEntrada&fechaSalida=$fechaSalida&horaSalida=$horaSalida');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final String data = json.decode(response.body) as String;
        print('Respuesta: $data');
        showSnackBar('$data', context);
      } else {
        print('Error en la solicitud: ${response.statusCode}');
        showSnackBar('Error en la solicitud: ${response.statusCode}', context);
      }
    } catch (e) {
      print('Error: $e');
      showSnackBar('Error: $e', context);
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

  void setAlumnosServicio(
      String nombreAlumno, String fechaEntrada, String fechaSalida) {
    _setAlumnos(_url, _apiEscritura, _idHoja, _hojaServicio, nombreAlumno,
        fechaEntrada, fechaSalida);

    notifyListeners();
  }
}
