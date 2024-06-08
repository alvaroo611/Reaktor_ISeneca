import 'package:flutter/material.dart';
import 'package:iseneca/config/constantas.dart';
import 'package:iseneca/models/Student.dart';
import 'package:iseneca/providers/alumno_provider.dart';
import 'package:provider/provider.dart';
import 'package:iseneca/models/models.dart';
import 'package:iseneca/providers/providers.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class ServicioESAlumnosScreen extends StatefulWidget {
  const ServicioESAlumnosScreen({Key? key}) : super(key: key);

  @override
  State<ServicioESAlumnosScreen> createState() =>
      _ServicioESAlumnosScreenState();
}

class _ServicioESAlumnosScreenState extends State<ServicioESAlumnosScreen> {
  bool botonPulsado = true;
  bool fechaCompleta = false;
  String fechaFormatoEntrada = "";
  String fechaFormatoSalida = "";
  String nombreAlumno = "";
  final servicioProvider = ServicioProvider();

  final controllerTextoNombreAlumno = TextEditingController();
  final controllerTextoFechaEntrada = TextEditingController();
  final controllerTextoFechaSalida = TextEditingController();

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
    await _providerAlumno.fetchStudents(httpClient);
    setState(() {
      listadoAlumnos2 = _providerAlumno.students;
    });
  }

  Future<void> _postVisit(String name, String lastName, String course) async {
    final httpClient = http.Client();

    while (true) {
      final response = await httpClient.post(
        Uri.parse(WEB_URL + '/horarios/student/visita/bathroom'),
        body: {
          'name': name,
          'lastName': lastName,
          'course': course,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Visita registrada correctamente')),
        );
        print('Visita registrada correctamente');
        break; // Sale del bucle while si la solicitud es exitosa
      } else {
        print('Error al registrar la visita: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Error al registrar la visita, intentando de nuevo...')),
        );
        await Future.delayed(
            const Duration(seconds: 2)); // Espera antes de intentar de nuevo
      }
    }
  }

  Future<void> _postReturnBathroom(
      String name, String lastName, String course) async {
    final httpClient = http.Client();

    while (true) {
      final response = await httpClient.post(
        Uri.parse(WEB_URL + '/horarios/student/regreso/bathroom'),
        body: {
          'name': name,
          'lastName': lastName,
          'course': course,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Regreso registrado correctamente')),
        );
        print('Regreso registrado correctamente');
        break; // Sale del bucle while si la solicitud es exitosa
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error al registrar el regreso, intentando de nuevo...')),
        );
        await Future.delayed(
            const Duration(seconds: 2)); // Espera antes de intentar de nuevo
        print('Error al registrar el regreso: ${response.statusCode}');
      }
    }
  }

  Future<void> _confirmAction(Student student) async {
    await _postVisit(student.name, student.lastName, student.course);
    await _postReturnBathroom(student.name, student.lastName, student.course);
  }

  @override
  Widget build(BuildContext context) {
    final nombreCurso = ModalRoute.of(context)!.settings.arguments as String;
    final listadoAlumnos = listadoAlumnos2
        .where((alumno) => alumno.course == nombreCurso)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(nombreCurso),
      ),
      body: Center(
        child: FutureBuilder(
          future: _loadStudents(), // Aquí puedes cargar los estudiantes
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Error al registrar el regreso o la visita')),
              );
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              // Muestra un mensaje de error si ocurre un error
              return Text('Error: ${snapshot.error}');
            } else {
              // Muestra el ListView.builder si la carga es exitosa
              return ListView.builder(
                itemCount: listadoAlumnos.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      controllerTextoNombreAlumno.clear();
                      controllerTextoFechaEntrada.clear();
                      controllerTextoFechaSalida.clear();

                      showGeneralDialog(
                        context: context,
                        barrierDismissible: false,
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder: (context, animation, secondaryAnimation) {
                          controllerTextoNombreAlumno.text =
                              listadoAlumnos[index].name;
                          controllerTextoFechaEntrada.text =
                              DateFormat("dd-MM-yyyy hh:mm")
                                  .format(DateTime.now());

                          return dialogoBotones(
                            fechaCompleta,
                            servicioProvider,
                            controllerTextoNombreAlumno,
                            controllerTextoFechaEntrada,
                            controllerTextoFechaSalida,
                            listadoAlumnos[index].course,
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
              );
            }
          },
        ),
      ),
    );
  }

  Widget dialogoBotones(
    bool fechaCompleta,
    ServicioProvider servicio,
    TextEditingController controllerTextoNombreAlumno,
    TextEditingController controllerTextoFechaEntrada,
    TextEditingController controllerTextoFechaSalida,
    String curso,
  ) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "CANCELAR",
            style: TextStyle(color: Color.fromARGB(255, 255, 0, 0)),
          ),
        ),
        leadingWidth: 90,
        actions: [
          TextButton(
            onPressed: () {
              if (fechaCompleta) {
                servicio.setAlumnosServicio(
                  controllerTextoNombreAlumno.text,
                  controllerTextoFechaEntrada.text,
                  controllerTextoFechaSalida.text,
                );
                final student = listadoAlumnos2
                    .firstWhere((student) => student.course == curso);
                _confirmAction(student);
                Navigator.pop(context);
              }
            },
            child: const Text(
              "CONFIRMAR",
              style: TextStyle(color: Color.fromARGB(255, 95, 168, 0)),
            ),
          ),
        ],
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
                      borderRadius: BorderRadius.circular(10)),
                  labelText: "NOMBRE ALUMNO",
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                enabled: false,
              ),
              const Divider(color: Colors.transparent),
              TextField(
                controller: controllerTextoFechaEntrada,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  labelText: "FECHA ENTRADA",
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(color: Colors.transparent),
              TextField(
                controller: controllerTextoFechaSalida,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        fechaCompleta = true;
                        debugPrint("fechaCompleta: $fechaCompleta");
                        controllerTextoFechaSalida.text =
                            DateFormat("dd-MM-yyyy hh:mm")
                                .format(DateTime.now());
                      });
                    },
                    icon: const Icon(Icons.add_box_outlined, size: 30),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  labelText: "FECHA SALIDA",
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
