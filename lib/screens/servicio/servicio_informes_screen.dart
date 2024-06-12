import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:iseneca/models/alumno_servcio.dart';
import 'package:provider/provider.dart';
import 'package:iseneca/providers/servicio_provider.dart';

class ServicioInformesScreen extends StatefulWidget {
  const ServicioInformesScreen({Key? key}) : super(key: key);

  @override
  State<ServicioInformesScreen> createState() => _ServicioInformesScreenState();
}

class _ServicioInformesScreenState extends State<ServicioInformesScreen> {
  String selectedDateInicio = "";
  String selectedDateFin = "";
  bool fechaInicioEscogida = false;
  bool isLoading = false;
  List<AlumnoServcio> listaAlumnosFechas = [];
  List<String> listaAlumnosNombres = [];
  DateTime dateTimeInicio = DateTime.now();
  DateTime dateTimeFin = DateTime.now();
  int size = 0;
  int repeticiones = 0;

  int _calcularRepeticiones(String nombreAlumno) {
    int num = 0;
    for (int i = 0; i < listaAlumnosFechas.length; i++) {
      if (nombreAlumno == listaAlumnosFechas[i].nombreCompleto) {
        num++;
      }
    }
    return num;
  }

  Future<void> mostrarFecha(String modo, BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      String valueFormat = DateFormat("dd-MM-yyyy").format(pickedDate);

      setState(() {
        if (modo == "Inicio") {
          selectedDateInicio = valueFormat;
          dateTimeInicio = pickedDate;
          fechaInicioEscogida = true;
        } else if (modo == "Fin") {
          selectedDateFin = valueFormat;
          dateTimeFin = pickedDate;
        }
      });
    }
  }

  Future<void> _loadNombresAlumnos(
      BuildContext context, DateTime fechaInicio, DateTime fechaFin) async {
    setState(() {
      isLoading = true;
    });
    try {
      final servicioProvider =
          Provider.of<ServicioProvider>(context, listen: false);
      Future.delayed(const Duration(seconds: 2));
      await servicioProvider.fetchStudentVisits(
          DateFormat("dd-MM-yyyy").format(fechaInicio),
          DateFormat("dd-MM-yyyy").format(fechaFin),
          context);
      setState(() {
        listaAlumnosNombres = servicioProvider.getNombresAlumnosFromMap();
        listaAlumnosFechas = servicioProvider.getAlumnoFromMap();
        size = listaAlumnosNombres.length;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar estudiantes por fecha.')));
      print('Failed to load students: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double anchura = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "INFORMES",
          style: TextStyle(
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
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 15),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: anchura * 0.5,
                      child: TextField(
                        readOnly: true,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        controller:
                            TextEditingController(text: selectedDateInicio),
                        decoration: InputDecoration(
                          labelText: "FECHA INICIO",
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today_rounded),
                            onPressed: () {
                              mostrarFecha("Inicio", context);
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: anchura * 0.5,
                      child: TextField(
                        enabled: fechaInicioEscogida,
                        readOnly: true,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        controller:
                            TextEditingController(text: selectedDateFin),
                        decoration: InputDecoration(
                          labelText: "FECHA FIN",
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today_rounded),
                            onPressed: () => mostrarFecha("Fin", context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    if (selectedDateInicio.isNotEmpty &&
                        selectedDateFin.isNotEmpty) {
                      DateTime fechaInicio =
                          DateFormat("dd-MM-yyyy").parse(selectedDateInicio);
                      DateTime fechaFin =
                          DateFormat("dd-MM-yyyy").parse(selectedDateFin);
                      _loadNombresAlumnos(context, fechaInicio, fechaFin);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Seleccione ambas fechas.')));
                    }
                  },
                  child: const Text(
                    "MOSTRAR",
                    style: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 5.0),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: size,
                    itemBuilder: (context, index) {
                      repeticiones =
                          _calcularRepeticiones(listaAlumnosNombres[index]);
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          "servicio_informes_detalles_screen",
                          arguments: listaAlumnosNombres[index],
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            listaAlumnosNombres[index],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 8, 8, 8),
                            ),
                          ),
                          subtitle: Text(
                            "Veces visitado hoy:  $repeticiones",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(227, 112, 121, 131),
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward,
                            color: Colors.blueAccent,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
