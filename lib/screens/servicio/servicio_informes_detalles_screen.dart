import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iseneca/models/Student.dart';
import 'package:iseneca/providers/alumno_provider.dart';
import 'package:iseneca/providers/servicio_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:http/http.dart' as http;

class ServicioInformesDetallesScreen extends StatefulWidget {
  const ServicioInformesDetallesScreen({Key? key}) : super(key: key);

  @override
  _ServicioInformesDetallesScreenState createState() =>
      _ServicioInformesDetallesScreenState();
}

class _ServicioInformesDetallesScreenState
    extends State<ServicioInformesDetallesScreen> {
  List<Student> alumno = [];
  List<String> fechas = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final nombreParametro =
        ModalRoute.of(context)!.settings.arguments as String;
    final servicioProvider =
        Provider.of<ServicioProvider>(context, listen: false);
    final alumnadoProvider =
        Provider.of<ProviderAlumno>(context, listen: false);
    final httpClient = http.Client();

    List<Student> listaAlumnos = [];

    try {
      listaAlumnos = await alumnadoProvider.fetchStudents(httpClient);
    } catch (e) {
      print('Error loading students: $e');
    }

    List<Student> tempAlumno = [];
    for (int i = 0; i < listaAlumnos.length; i++) {
      if (listaAlumnos[i].name == nombreParametro) {
        tempAlumno.add(listaAlumnos[i]);
      }
    }

    final listadoAlumnosDetalles = servicioProvider.listadoAlumnosServicio;
    List<String> tempFechas = [];

    for (int i = 0; i < listadoAlumnosDetalles.length; i++) {
      if (listadoAlumnosDetalles[i].nombreAlumno == nombreParametro) {
        tempFechas.add(
            "${listadoAlumnosDetalles[i].fechaEntrada} - ${listadoAlumnosDetalles[i].fechaSalida}");
      }
    }

    setState(() {
      alumno = tempAlumno;
      fechas = tempFechas;
    });
  }

  @override
  Widget build(BuildContext context) {
    final nombreParametro =
        ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text(nombreParametro.toString().toUpperCase()),
      ),
      body: SafeArea(
        child: Stack(children: [
          ListView.builder(
            itemCount: fechas.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(fechas[index]),
              );
            },
          ),
          Container(
              padding: const EdgeInsets.only(right: 20, bottom: 20),
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                  onPressed: () => _mostrarAlert(context, alumno),
                  child: const Icon(Icons.person)))
        ]),
      ),
    );
  }

  void _mostrarAlert(BuildContext context, List<Student> alumno) {
    if (alumno.isEmpty) return;

    int numeroTlfAlumno = int.parse(alumno[0].tutorPhone);

    String mailAlumno = alumno[0].tutorEmail;

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          TextStyle textStyle = const TextStyle(fontWeight: FontWeight.bold);

          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: Text(alumno[0].name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                ),
                Row(
                  children: [
                    Text("Correo: ", style: textStyle),
                    Text(mailAlumno),
                    IconButton(
                        onPressed: () {
                          launchUrlString("mailto: $mailAlumno");
                        },
                        icon: const Icon(Icons.mail),
                        color: Colors.blue),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Teléfono Alumno: ",
                      style: textStyle,
                    ),
                    Text("$numeroTlfAlumno"),
                    IconButton(
                        onPressed: () {
                          launchUrlString("tel:$numeroTlfAlumno");
                        },
                        icon: const Icon(Icons.phone),
                        color: Colors.blue),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cerrar")),
            ],
          );
        });
  }
}
