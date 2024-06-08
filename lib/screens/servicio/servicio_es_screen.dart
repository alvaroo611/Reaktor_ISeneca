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
  late List<String> cursosUnicos = [];

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
      cursosUnicos =
          listadoAlumnos.map((student) => student.course).toSet().toList();
    });
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
                itemCount: cursosUnicos.length,
                itemBuilder: (BuildContext context, int index) {
                  final curso = cursosUnicos[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        "servicio_es_alumnos_screen",
                        arguments: curso,
                      );
                    },
                    child: ListTile(
                      title: Text(curso),
                      trailing:
                          IconButton(icon: Icon(Icons.check), onPressed: () {}),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
