import 'package:flutter/material.dart';
import 'package:iseneca/models/alumno_servcio.dart';
import 'package:iseneca/models/datos_visita.dart';

import 'package:provider/provider.dart';
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
  AlumnoServcio? alumno;
  List<DatosVisita> datosVisitas = [];

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

    List<AlumnoServcio> listaAlumnos = [];

    try {
      listaAlumnos = servicioProvider.getAlumnoFromMap();
      // Buscar el alumno con el nombre proporcionado
      alumno = listaAlumnos
          .firstWhere((alumno) => alumno.nombreCompleto == nombreParametro);

      if (alumno != null) {
        // Si se encuentra el alumno, obtener sus datos de visita
        datosVisitas =
            servicioProvider.getDatosVisitasFromMap(alumno!.alumnoId);
      }
    } catch (e) {
      print('Error loading students: $e');
    }

    setState(() {
      // Actualiza fechas con los datos de visita específicos del alumno
      datosVisitas = datosVisitas;
    });
  }

  @override
  Widget build(BuildContext context) {
    final nombreParametro =
        ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          nombreParametro.toString().toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView.builder(
              itemCount: datosVisitas.length,
              padding: const EdgeInsets.all(10),
              itemBuilder: (BuildContext context, int index) {
                final visita = datosVisitas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.date_range, color: Colors.blueAccent),
                    title: Text(
                      'Fecha: ${visita.dia}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.blueAccent),
                        SizedBox(width: 5),
                        Text(
                          'Hora: ${visita.horas}',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (alumno != null)
              Container(
                padding: const EdgeInsets.only(right: 20, bottom: 20),
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () => _mostrarAlert(context, alumno!),
                  child: const Icon(Icons.person),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _mostrarAlert(BuildContext context, AlumnoServcio alumno) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(alumno.nombreCompleto),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Divider(
                color: Colors.black,
                thickness: 1,
              ),
              Text(
                'Historial de Visitas:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 8,
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: datosVisitas.length,
                itemBuilder: (context, index) {
                  final visita = datosVisitas[index];
                  return ListTile(
                    title: Text(visita.horas),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }
}
