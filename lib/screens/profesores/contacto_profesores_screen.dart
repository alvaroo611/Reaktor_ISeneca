import 'dart:math';
import 'package:flutter/material.dart';
import 'package:iseneca/models/profesor.dart';
import 'package:iseneca/providers/profesores_provider.dart';
import 'package:provider/provider.dart';

import 'package:iseneca/providers/providers.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:http/http.dart' as http;

class ContactoProfesoresScreen extends StatefulWidget {
  const ContactoProfesoresScreen({super.key});

  @override
  _ContactoProfesoresScreenState createState() =>
      _ContactoProfesoresScreenState();
}

class _ContactoProfesoresScreenState extends State<ContactoProfesoresScreen> {
  List<Profesor> listaOrdenadaProfesores = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfesores();
  }

  Future<void> _fetchProfesores() async {
    final centroProvider =
        Provider.of<ProfesoresProvider>(context, listen: false);
    final listadoProfesores =
        await centroProvider.fetchProfesores(http.Client());

    // Conjunto para almacenar nombres y apellidos únicos
    Set<String> nombresApellidosSet = Set();

    // Lista para almacenar los profesores sin nombres y apellidos repetidos
    List<Profesor> listaProfesoresSinRepetidos = [];

    for (Profesor profesor in listadoProfesores) {
      // Concatenar nombre y apellido del profesor
      String nombreCompleto = profesor.nombreCompleto;

      // Verificar si el nombre y apellido ya están en el conjunto
      if (!nombresApellidosSet.contains(nombreCompleto)) {
        // Agregar el nombre y apellido al conjunto y a la lista
        nombresApellidosSet.add(nombreCompleto);
        listaProfesoresSinRepetidos.add(profesor);
      }
    }

    // Ordenar la lista por nombre
    listaProfesoresSinRepetidos.sort((a, b) => a.nombre.compareTo(b.nombre));

    setState(() {
      listaOrdenadaProfesores = listaProfesoresSinRepetidos;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("CONTACTO"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: listaOrdenadaProfesores.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    _mostrarAlert(context, index, listaOrdenadaProfesores);
                  },
                  child: ListTile(
                    title: Text(listaOrdenadaProfesores[index].nombreCompleto),
                  ),
                );
              },
            ),
    );
  }
}

void _mostrarAlert(
    BuildContext context, int index, List<Profesor> listadoProfesores) {
  final int numeroTlf = (Random().nextInt(99999999) + 600000000);
  const String mailProfesor = "Correo@gmail.com";

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      TextStyle textStyle = const TextStyle(fontWeight: FontWeight.bold);

      return AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text(listadoProfesores[index].nombre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Divider(
              color: Colors.black,
              thickness: 1,
            ),
            Row(
              children: [
                Text(
                  "Correo: ",
                  style: textStyle,
                ),
                const Text(mailProfesor),
                IconButton(
                  onPressed: () {
                    launchUrlString("mailto:$mailProfesor");
                  },
                  icon: const Icon(Icons.mail),
                  color: Colors.blue,
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  "Teléfono: ",
                  style: textStyle,
                ),
                Text("$numeroTlf"),
                IconButton(
                  onPressed: () {
                    launchUrlString("tel:$numeroTlf");
                  },
                  icon: const Icon(Icons.phone),
                  color: Colors.blue,
                )
              ],
            )
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar")),
        ],
      );
    },
  );
}


/*List<String> _averiguarHorario(BuildContext context, int tramo, int id_prof) {
  final centroProvider = Provider.of<CentroProvider>(context, listen: false);
  final listadoHorariosProfesores = centroProvider.listaHorariosProfesores;
  List<String> horario = [];

  for (int i = 0; i < listadoHorariosProfesores.length; i++) {
    if (int.parse(listadoHorariosProfesores[i].horNumIntPr) == id_prof) {
      debugPrint("id iguales");
      for (int j = 0; j < listadoHorariosProfesores[i].actividad.length; j++) {
        debugPrint("Tramo JSON: ${listadoHorariosProfesores[i].actividad[j].tramo}");
        debugPrint("Tramo: $tramo");

        if (int.parse(listadoHorariosProfesores[i].actividad[j].tramo) ==
            tramo) {
          debugPrint("bruh");
          horario.add(listadoHorariosProfesores[i].actividad[j].asignatura);

          horario.add(listadoHorariosProfesores[i].actividad[j].aula);

          debugPrint("Asignatura: " + horario[0]);
          debugPrint("Aula: " + horario[1]);
        }
      }
    }
  }

  return horario;
}*/
