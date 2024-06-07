import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iseneca/providers/alumno_provider.dart';
import 'package:iseneca/models/Student.dart';
import 'package:http/http.dart' as http;
import 'package:iseneca/config/constantas.dart';

class ServicioESScreen extends StatefulWidget {
  const ServicioESScreen({Key? key}) : super(key: key);

  @override
  _ServicioESScreenState createState() => _ServicioESScreenState();
}

class _ServicioESScreenState extends State<ServicioESScreen> {
  late ProviderAlumno _providerAlumno;
  late List<Student> listadoAlumnos = [];

  @override
  void initState() {
    super.initState();
    _providerAlumno = Provider.of<ProviderAlumno>(context, listen: false);
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final httpClient = http.Client();
    await _providerAlumno.fetchStudents(httpClient);
    setState(() {
      listadoAlumnos = _providerAlumno.students;
    });
  }

  Future<void> _postVisit(String name, String lastName, String course) async {
    final httpClient = http.Client();
    final response = await httpClient.post(
      Uri.parse(WEB_URL + '/horarios/student/visita/bathroom'),
      body: {
        'name': name,
        'lastName': lastName,
        'course': course,
      },
    );

    if (response.statusCode == 200) {
      print('Visita registrada correctamente');
    } else {
      print('Error al registrar la visita: ${response.statusCode}');
    }
  }

  Future<void> _postReturnBathroom(
      String name, String lastName, String course) async {
    final httpClient = http.Client();
    final response = await httpClient.post(
      Uri.parse(WEB_URL + '/horarios/student/regreso/bathroom'),
      body: {
        'name': name,
        'lastName': lastName,
        'course': course,
      },
    );

    if (response.statusCode == 200) {
      print('Regreso registrado correctamente');
    } else {
      print('Error al registrar el regreso: ${response.statusCode}');
    }
  }

  Future<void> _confirmAction(Student student) async {
    await _postVisit(student.name, student.lastName, student.course);
    await _postReturnBathroom(student.name, student.lastName, student.course);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CURSOS"),
      ),
      body: Center(
        child: listadoAlumnos.isEmpty
            ? CircularProgressIndicator()
            : ListView.builder(
                itemCount: listadoAlumnos.length,
                itemBuilder: (BuildContext context, int index) {
                  final student = listadoAlumnos[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        "servicio_es_alumnos_screen",
                        arguments: student.course,
                      );
                    },
                    child: ListTile(
                      title: Text(student.course),
                      trailing: IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () {
                          _confirmAction(student);
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
