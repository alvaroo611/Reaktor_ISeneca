import 'package:flutter/material.dart';
import 'package:iseneca/models/localizacion_profesor.dart';

import 'package:provider/provider.dart';
import 'package:iseneca/models/profesor.dart';
import 'package:iseneca/providers/profesores_provider.dart';
import 'package:http/http.dart' as http;

class ListadoProfesores extends StatefulWidget {
  const ListadoProfesores({Key? key}) : super(key: key);

  @override
  _ListadoProfesoresState createState() => _ListadoProfesoresState();
}

class _ListadoProfesoresState extends State<ListadoProfesores> {
  List<Profesor> listaOrdenadaProfesores = [];
  List<Profesor> profesoresFiltrados = [];
  bool isLoading = true;
  final TextEditingController _controller = TextEditingController();
  late ProfesoresProvider centroProvider = new ProfesoresProvider();
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
      profesoresFiltrados =
          listaOrdenadaProfesores; // Inicialmente muestra todos los profesores
      isLoading = false;
    });
  }

  void filterSearchResults(String query) {
    setState(() {
      if (query.isEmpty) {
        profesoresFiltrados = List.from(listaOrdenadaProfesores);
      } else {
        profesoresFiltrados = listaOrdenadaProfesores
            .where((profesor) => profesor.nombreCompleto
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void showDetailsDialog(
      BuildContext context, String nombre, String apellido) async {
    setState(() {
      isLoading = true;
    });

    try {
      LocalizacionProfesor localizacionProfesor =
          await centroProvider.getClassroomTeacher(nombre, apellido, context);

      setState(() {
        isLoading = false;
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Detalles de Profesor'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Detalles del Aula:\n${localizacionProfesor.classroom.toFormattedString()}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Detalles de la Asignatura:\n${localizacionProfesor.asignatura.toFormattedString()}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Manejar errores aquí
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('No se pudieron cargar los detalles del profesor.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'LISTA PROFESORES',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              width: screenWidth * 0.3,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.search, color: Colors.white),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: (value) {
                        filterSearchResults(value);
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Buscar',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: profesoresFiltrados.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    showDetailsDialog(
                      context,
                      profesoresFiltrados[index].nombre,
                      '${profesoresFiltrados[index].primerApellido} ${profesoresFiltrados[index].segundoApellido} '
                          .toLowerCase(),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.blueAccent, width: 2),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          profesoresFiltrados[index].nombreCompleto[0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        profesoresFiltrados[index].nombreCompleto,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 8, 8, 8),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
/*
List<String> _averiguarHorario(BuildContext context, int idProf, int tramo) {
  final centroProvider = Provider.of<CentroProvider>(context, listen: false);
  final listadoHorariosProfesores = centroProvider.listaHorariosProfesores;
  List<String> horario = List.filled(2, "0");

  for (int i = 0; i < listadoHorariosProfesores.length; i++) {
    if (int.parse(listadoHorariosProfesores[i].horNumIntPr) == idProf + 1) {
      for (int j = 0; j < listadoHorariosProfesores[i].actividad.length; j++) {
        if (int.parse(listadoHorariosProfesores[i].actividad[j].tramo) ==
            tramo) {
          horario[0] = listadoHorariosProfesores[i].actividad[j].asignatura;

          horario[1] = listadoHorariosProfesores[i].actividad[j].aula;

          debugPrint("Asignatura: ${horario[0]}");
          debugPrint("Aula: ${horario[1]}");
        }
      }
    }
  }

  return horario;
}

int _averiguarTramo(
    BuildContext context, List<Tramo> listadoTramos, int index) {
  DateTime now = DateTime.now();
  debugPrint(now.weekday.toString());

  List<String> splitHoraInicio = [];
  List<String> splitHoraFinal = [];
  List<int> tramosProhibidos = [5, 10, 25, 30, 45, 50, 65, 70, 85, 90];
  int tramo = 0;
  int tramoCorrecto = 0;

  for (int i = 0; i < listadoTramos.length; i++) {
    splitHoraInicio = (listadoTramos[i].horaInicio.split(":"));
    splitHoraFinal = (listadoTramos[i].horaFinal.split(":"));

    if (int.parse(splitHoraInicio[0]) * 60 + int.parse(splitHoraInicio[1]) <=
            (now.minute + now.hour * 60) &&
        (now.minute + now.hour * 60) <
            int.parse(splitHoraFinal[0]) * 60 + int.parse(splitHoraFinal[1]) &&
        int.parse(listadoTramos[i].numeroDia) == now.weekday) {
      tramo = int.parse(listadoTramos[i].numTr);
      debugPrint("Número de tramo: $tramo");
      if (tramosProhibidos.contains(tramo)) {
        return tramo - 1;
      } else {
        if (comprobarTramo(context, tramo, index)) {
          tramoCorrecto = tramo;
          debugPrint("Tramo correcto: $tramoCorrecto");
          return tramoCorrecto;
        }
      }
    }
  }
  return tramo;
}

bool comprobarTramo(BuildContext context, int tramo, int index) {
  final centroProvider = Provider.of<CentroProvider>(context, listen: false);
  final listadoHorarioProfesores = centroProvider.listaHorariosProfesores;
  bool tramoCorrecto = false;

  for (int i = 0;
      i < listadoHorarioProfesores[index - 1].actividad.length;
      i++) {
    if (int.parse(listadoHorarioProfesores[index - 1].actividad[i].tramo) ==
        tramo) {
      tramoCorrecto = true;
    }
  }

  return tramoCorrecto;
}

void _mostrarLocalizacion(BuildContext context, int index) {
  final centroProvider = Provider.of<CentroProvider>(context, listen: false);
  final listadoProfesores = centroProvider.listaProfesores;
  final listadoTramos = centroProvider.listaTramos;
  final listadoAsignaturas = centroProvider.listaAsignaturas;
  final listadoAulas = centroProvider.listaAulas;

  int tramo = _averiguarTramo(context, listadoTramos, index);

  debugPrint(" Tramo obtenido del método: $tramo");
  List<String> horario = _averiguarHorario(context, index, tramo);
  String horaInicio = "";
  String horaFinal = "";
  DateTime now = DateTime.now();
  String asignatura = "";
  String aula = "";

  for (int i = 0; i < listadoAsignaturas.length; i++) {
    if (int.parse(listadoAsignaturas[i].numIntAs) == int.parse(horario[0])) {
      asignatura = listadoAsignaturas[i].nombre;
    }
  }

  for (int i = 0; i < listadoAulas.length; i++) {
    if (int.parse(listadoAulas[i].numIntAu) == int.parse(horario[1])) {
      aula = listadoAulas[i].nombre;
    }
  }
  for (int i = 0; i < listadoTramos.length; i++) {
    if (int.parse(listadoTramos[i].numTr) == tramo &&
        int.parse(listadoTramos[i].numeroDia) == now.weekday) {
      horaInicio = listadoTramos[i].horaInicio;
      horaFinal = listadoTramos[i].horaFinal;
    }
  }

  if (horario.isNotEmpty) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: Text(listadoProfesores[index].nombre),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                mostrarHorario(aula, asignatura, horaInicio, horaFinal)
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK")),
            ],
          );
        });
  } else {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: Text(listadoProfesores[index].nombre),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("No se encuentra en clase actualmente"),
                Text(" "),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK")),
            ],
          );
        });
  }
}

Widget mostrarHorario(aula, asignatura, horaInicio, horaFinal) {
  if (aula == "" && asignatura == "") {
    return const Text("No se encuentra disponible");
  }

  return Text(
      "Se encuentra en el aula $aula impartiendo la asignatura $asignatura, de $horaInicio a $horaFinal");
}
*/