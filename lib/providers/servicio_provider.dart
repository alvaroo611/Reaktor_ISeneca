import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iseneca/models/Student.dart';
import 'package:iseneca/models/servicio_response.dart';
import 'package:iseneca/utils/utilidades.dart';
import 'package:iseneca/config/constantas.dart';
import 'dart:convert';

class ServicioProvider extends ChangeNotifier {
  List<Servicio> listadoAlumnosServicio = [];
  late List<Map<String, dynamic>> visitas;

  List<Student> getAlumnoFromMap() {
    // Crear una lista para almacenar los estudiantes
    List<Student> alumnos = [];

    // Iterar sobre cada mapa en la lista
    visitas.forEach((mapa) {
      // Iterar sobre las entradas del mapa
      mapa.forEach((clave, valor) {
        // Verificar si la clave es "alumno" y si el valor es una instancia de Student
        if (clave == "alumno" && valor is Student) {
          // Agregar el estudiante a la lista
          alumnos.add(valor);
        }
      });
    });

    // Devolver la lista de estudiantes
    return alumnos;
  }

  List<String> getNombresAlumnosFromMap() {
    // Crear una lista para almacenar los nombres de los estudiantes
    List<String> nombresAlumnos = [];

    // Iterar sobre cada mapa en la lista
    visitas.forEach((mapa) {
      // Obtener el nombre del estudiante del mapa y agregarlo a la lista
      if (mapa.containsKey("alumno")) {
        nombresAlumnos
            .add('${mapa["alumno"].name} ,${mapa["alumno"].lastName}');
      }
    });

    // Devolver la lista de nombres de los estudiantes
    return nombresAlumnos;
  }

  Future<void> fetchStudentVisits(
      String fechaInicio, String fechaFin, BuildContext context) async {
    String formattedFechaInicio = fechaInicio.replaceAll('-', '/');
    String formattedFechaFin = fechaFin.replaceAll('-', '/');

    final url = Uri.parse(WEB_URL +
        '/horarios/get/students/visitas/bathroom?fechaInicio=$formattedFechaInicio&fechaFin=$formattedFechaFin');

    try {
      print('URL: $url'); // Imprime la URL para verificar que es correcta
      final response = await http.get(url);

      if (response.statusCode == 200) {
        try {
          // Convertir el cuerpo de la respuesta JSON en un mapa
          print(
              'Response Body: ${response.body}'); // Imprime el cuerpo de la respuesta
          visitas = List<Map<String, dynamic>>.from(json.decode(response.body));
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Datos cargados correctamente')));
        } catch (e) {
          print('Error al decodificar la respuesta JSON: $e');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error al procesar los datos del servidor.')));
        }
      } else {
        // Manejar el caso en que la solicitud no sea exitosa
        print('Error al obtener la lista de visitas: ${response.statusCode}');
        print(
            'Response Body: ${response.body}'); // Imprime el cuerpo de la respuesta si hay un error
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Error al cargar las visitas de los estudiantes al baño.')));
      }
    } catch (e) {
      // Manejar errores de red u otras excepciones
      print('Error en la solicitud HTTP: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error de red al intentar obtener los datos.')));
    }
  }

  //Google Script Lectura ejecutado
  //https://script.google.com/macros/s/AKfycbyPsB_koj3MwkmRFn8IJU-k4sOP8nRfnHHKNNt9xov9INZ1VEsQbu96gDR8Seiz0oDGOQ/exec?spreadsheetId=1u79XugcalPc4aPcymy9OsWu1qdg8aKCBvaPWQOH187I&sheet=Servicio

  //Google Script Escritura
  //https://script.google.com/macros/s/AKfycbz7ZwCTn2XXpXuPO2-m9tyR1sIC9lOMgvPPOsbDehda2NRoko871PvZvzF1jQnaq8Du/exec?spreadsheetId=1Jq4ihUzE5r4fqK9HHZQv1dg4AAgzdjPbGkpJRByu-Ds&sheet=Servicio&nombreAlumno=Alumno2&fechaEntrada=fecha2&fechaSalida=fecha2

  //Google Docs Baño
  //https://docs.google.com/spreadsheets/d/1u79XugcalPc4aPcymy9OsWu1qdg8aKCBvaPWQOH187I/edit#gid=0

  final _url = "script.google.com";
  final _apiEscritura =
      "macros/s/AKfycbz7ZwCTn2XXpXuPO2-m9tyR1sIC9lOMgvPPOsbDehda2NRoko871PvZvzF1jQnaq8Du/exec";
  final _idHoja = "1Jq4ihUzE5r4fqK9HHZQv1dg4AAgzdjPbGkpJRByu-Ds";
  final _hojaServicio = "Servicio";

  ServicioProvider() {
    debugPrint("Servicio Provider inicializado");
    getAlumnosServicio();

    notifyListeners();
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

  _setAlumnos(String baseurl, String api, String pagina, String hoja,
      String nombre, String fechaEntrada, String fechaSalida) async {
    final url = Uri.https(baseurl, api, {
      "spreadsheetId": pagina,
      "sheet": hoja,
      "nombreAlumno": nombre,
      "fechaEntrada": fechaEntrada,
      "fechaSalida": fechaSalida
    });

    await http.get(url);
  }

  setAlumnosServicio(
      String nombreAlumno, String fechaEntrada, String fechaSalida) {
    _setAlumnos(_url, _apiEscritura, _idHoja, _hojaServicio, nombreAlumno,
        fechaEntrada, fechaSalida);

    notifyListeners();
  }
}

final servicio = ServicioProvider();
