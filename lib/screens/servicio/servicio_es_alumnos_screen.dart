import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final listadoAlumnos = listadoAlumnos2;
    final nombreCurso = ModalRoute.of(context)!.settings.arguments;

    List<Student> listaAlumnos = [];

    for (int i = 0; i < listadoAlumnos.length; i++) {
      if (listadoAlumnos[i].course == nombreCurso) {
        listaAlumnos.add(listadoAlumnos[i]);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("$nombreCurso"),
      ),
      body: Center(
        child: ListView.builder(
            itemCount: listaAlumnos.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  controllerTextoNombreAlumno.text = "";
                  controllerTextoFechaEntrada.text = "";
                  controllerTextoFechaSalida.text = "";

                  showGeneralDialog(
                      context: context,
                      barrierDismissible: false,
                      transitionDuration: const Duration(milliseconds: 300),
                      pageBuilder: (context, animation, secondaryAnimation) {
                        controllerTextoNombreAlumno.text =
                            listaAlumnos[index].name;

                        controllerTextoFechaEntrada.text =
                            DateFormat("dd-MM-yyyy hh:mm")
                                .format(DateTime.now());
                        return dialogoBotones(
                            fechaCompleta,
                            servicioProvider,
                            controllerTextoNombreAlumno,
                            controllerTextoFechaEntrada,
                            controllerTextoFechaSalida);
                      });
                },
                child: ListTile(
                  title: Text(listaAlumnos[index].name,
                      style: const TextStyle(fontSize: 20)),
                ),
              );
            }),
      ),
    );
  }

  Widget dialogoBotones(
      bool fechaCompleta,
      ServicioProvider servicio,
      TextEditingController controllerTextoNombreAlumno,
      TextEditingController controllerTextoFechaEntrada,
      TextEditingController controllerTextoFechaSalida) {
    return Scaffold(
      appBar: AppBar(
          leading: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "CANCELAR",
                style: TextStyle(color: Color.fromARGB(255, 255, 0, 0)),
              )),
          leadingWidth: 90,
          actions: [
            TextButton(
                onPressed: () {
                  if (!fechaCompleta) {
                    null;
                  } else {
                    servicio.setAlumnosServicio(
                        controllerTextoNombreAlumno.text,
                        controllerTextoFechaEntrada.text,
                        controllerTextoFechaSalida.text);
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  "CONFIRMAR",
                  style: TextStyle(color: Color.fromARGB(255, 95, 168, 0)),
                ))
          ]),
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
                        labelStyle:
                            const TextStyle(fontWeight: FontWeight.bold)),
                    enabled: false,
                  ),
                  const Divider(color: Colors.transparent),
                  TextField(
                    controller: controllerTextoFechaEntrada,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        labelText: "FECHA ENTRADA",
                        labelStyle:
                            const TextStyle(fontWeight: FontWeight.bold)),
                    enabled: true,
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
                            icon: const Icon(
                              Icons.add_box_outlined,
                              size: 30,
                            )),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        labelText: "FECHA SALIDA",
                        labelStyle:
                            const TextStyle(fontWeight: FontWeight.bold)),
                    enabled: true,
                  )
                ],
              ))),
    );
  }
}
