import 'package:flutter/material.dart';
import 'package:iseneca/config/constantas.dart';
import 'package:iseneca/models/Student.dart';
import 'package:iseneca/providers/alumno_provider.dart';
import 'package:iseneca/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class ServicioESAlumnosScreen extends StatefulWidget {
  const ServicioESAlumnosScreen({Key? key}) : super(key: key);

  @override
  State<ServicioESAlumnosScreen> createState() =>
      _ServicioESAlumnosScreenState();
}

class _ServicioESAlumnosScreenState extends State<ServicioESAlumnosScreen> {
  bool isLoading = false;
  bool isIdaPressed = false;
  bool isVueltaPressed = false;
  final servicioProvider = ServicioProvider();

  final controllerTextoNombreAlumno = TextEditingController();
  late ProviderAlumno _providerAlumno;
  late List<Student> listadoAlumnos2 = [];

  @override
  void initState() {
    super.initState();
    _providerAlumno = Provider.of<ProviderAlumno>(context, listen: false);
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final httpClient = http.Client();
    Future.delayed(const Duration(seconds: 2));
    await _providerAlumno.fetchStudents(httpClient);
    setState(() {
      listadoAlumnos2 = _providerAlumno.students;
    });
  }

  Future<void> _postVisit(String name, String lastName, String course) async {
    final httpClient = http.Client();
    try {
      final response = await httpClient.post(
        Uri.parse(WEB_URL +
            '/horarios/student/visita/bathroom?name=$name&lastName=$lastName&course=$course'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Visita registrada correctamente')),
        );
      } else if (response.statusCode == 500) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error servidor')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar la visita')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar la visita')),
      );
    }
  }

  Future<void> _postReturnBathroom(
      String name, String lastName, String course) async {
    final httpClient = http.Client();
    try {
      final response = await httpClient.post(
        Uri.parse(WEB_URL +
            '/horarios/student/regreso/bathroom?name=$name&lastName=$lastName&course=$course'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Regreso registrado correctamente')),
        );
      } else if (response.statusCode == 500) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error servidor')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar el regreso')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar el regreso')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombreCurso = ModalRoute.of(context)!.settings.arguments as String;
    final listadoAlumnos = listadoAlumnos2
        .where((alumno) => alumno.course == nombreCurso)
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          nombreCurso,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ListView.builder(
                itemCount: listadoAlumnos.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      controllerTextoNombreAlumno.clear();
                      controllerTextoNombreAlumno.text =
                          listadoAlumnos[index].name;

                      showGeneralDialog(
                        context: context,
                        barrierDismissible: false,
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return dialogoBotones(
                            servicioProvider,
                            controllerTextoNombreAlumno,
                            listadoAlumnos[index],
                          );
                        },
                      );
                    },
                    child: ListTile(
                      title: Text(
                        '${listadoAlumnos[index].name} ${listadoAlumnos[index].lastName}',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget dialogoBotones(
    ServicioProvider servicio,
    TextEditingController controllerTextoNombreAlumno,
    Student student,
  ) {
    final double maxWidth = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(10),
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                controller: controllerTextoNombreAlumno,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: "NOMBRE ALUMNO",
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                enabled: false,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: maxWidth), // Ancho máximo del botón
                      child: RawMaterialButton(
                        onPressed: () async {
                          if (!isIdaPressed) {
                            await _postVisit(
                                student.name, student.lastName, student.course);
                            setState(() {
                              isIdaPressed = true;
                            });
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              50), // Haciendo el botón completamente circular
                        ),
                        fillColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20),
                        child: const Text(
                          "IDA",
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: maxWidth), // Ancho máximo del botón
                      child: RawMaterialButton(
                        onPressed: () async {
                          if (!isVueltaPressed) {
                            await _postReturnBathroom(
                                student.name, student.lastName, student.course);
                            setState(() {
                              isVueltaPressed = true;
                            });
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              50), // Haciendo el botón completamente circular
                        ),
                        fillColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20),
                        child: const Text(
                          "VUELTA",
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
