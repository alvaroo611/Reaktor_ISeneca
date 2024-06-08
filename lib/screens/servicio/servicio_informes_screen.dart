import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:iseneca/models/servicio_response.dart';
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
  List<Servicio> listaAlumnosFechas = [];
  List<String> listaAlumnosNombres = [];
  DateTime dateTimeInicio = DateTime.now();
  DateTime dateTimeFin = DateTime.now();
  int size = 0;
  int repeticiones = 0;
  
  Future<void> _loadStudentsPorFecha(BuildContext context) async {
    try {
      final servicioProvider = Provider.of<ServicioProvider>(context, listen: false);
      await servicioProvider.fetchAlumnosPorFecha(selectedDateInicio, selectedDateFin);
      setState(() {
        listaAlumnosFechas = servicioProvider.listadoAlumnosServicio;
        listaAlumnosNombres = listaAlumnosFechas.map((e) => e.nombreAlumno).toSet().toList();
        listaAlumnosNombres.sort((a, b) => a.compareTo(b));
        size = listaAlumnosNombres.length;
      });
    } catch (e) {
      print('Failed to load students: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double anchura = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("INFORMES"),
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
                        controller: TextEditingController(text: selectedDateInicio),
                        decoration: InputDecoration(
                          labelText: "FECHA INICIO",
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today_rounded),
                            onPressed: () {
                              fechaInicioEscogida = true;
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
                        controller: TextEditingController(text: selectedDateFin),
                        decoration: InputDecoration(
                          labelText: "FECHA FIN",
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today_rounded),
                            onPressed: () => mostrarFecha("Fin", context),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    _loadStudentsPorFecha(context);
                  },
                  child: const Text("MOSTRAR")
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: size,
              itemBuilder: (context, index) {
                repeticiones = _calcularRepeticiones(listaAlumnosNombres[index]);

                return GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context, "servicio_informes_detalles_screen",
                    arguments: listaAlumnosNombres[index]
                  ),
                  child: ListTile(
                    title: Text(listaAlumnosNombres[index]),
                    subtitle: Text("Cantidad $repeticiones"),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void mostrarFecha(String modo, BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          color: Colors.white,
          height: MediaQuery.of(context).copyWith().size.height * 0.25,
          child: CupertinoDatePicker(
            initialDateTime: DateTime.now(),
            minimumYear: DateTime.now().year - 1,
            maximumYear: DateTime.now().year,
            mode: CupertinoDatePickerMode.date,
            onDateTimeChanged: (value) {
              String valueFormat = DateFormat("dd-MM-yyyy").format(value);

              if (modo == "Inicio") {
                setState(() {
                  selectedDateInicio = valueFormat;
                  dateTimeInicio = value;
                });
              }

              if (modo == "Fin") {
                setState(() {
                  selectedDateFin = valueFormat;
                  dateTimeFin = value;
                });
              }
            }
          ),
        );
      }
    );
  }

  int _calcularRepeticiones(String nombreAlumno) {
    int num = 0;
    for (int i = 0; i < listaAlumnosFechas.length; i++) {
      if (nombreAlumno == listaAlumnosFechas[i].nombreAlumno) {
        num++;
      }
    }
    return num;
  }
}
