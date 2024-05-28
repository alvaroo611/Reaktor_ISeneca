import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iseneca/providers/alumno_provider.dart';
import 'package:iseneca/providers/profesores_provider.dart';
import 'package:http/http.dart' as http;

class IncidenciaTelefonoScreen extends StatefulWidget {
  const IncidenciaTelefonoScreen({Key? key}) : super(key: key);

  @override
  _IncidenciaTelefonoScreenState createState() =>
      _IncidenciaTelefonoScreenState();
}

class _IncidenciaTelefonoScreenState extends State<IncidenciaTelefonoScreen> {
  DateTime? _fechaSeleccionada;
  String? _opcionHora;
  String? _profesorSeleccionado;
  String? _alumnoSeleccionado;
  TextEditingController _incidenciaController = TextEditingController();

  // Inicializa ProfesoresProvider
  final ProfesoresProvider _profesoresProvider = ProfesoresProvider();
  final ProviderAlumno _providerAlumno = ProviderAlumno();

  // Método para inicializar ProfesoresProvider en initState
  @override
  void initState() {
    super.initState();
    _fetchProfesores();
    _fetchStudent();
    // Llama al método para obtener los profesores
  }

  void _fetchProfesores() async {
    final httpClient = http.Client();
    await _profesoresProvider.fetchProfesores(httpClient);
    setState(() {}); // Actualiza el estado después de obtener los profesores
  }

  void _fetchStudent() async {
    final httpClient = http.Client();
    await _providerAlumno.fetchStudents(httpClient);
    setState(() {}); // Actualiza el estado después de obtener los estudiantes
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (fechaSeleccionada != null) {
      setState(() {
        _fechaSeleccionada = fechaSeleccionada;
      });
    }
  }

  void _borrarTodo() {
    setState(() {
      _fechaSeleccionada = null;
      _opcionHora = null;
      _profesorSeleccionado = null;
      _incidenciaController.clear();
    });
  }

  void _enviarDatos() {
    // Aquí puedes enviar los datos recolectados
    print('Fecha seleccionada: $_fechaSeleccionada');
    print('Hora seleccionada: $_opcionHora');
    print('Profesor seleccionado: $_profesorSeleccionado');
    print('Incidencia: ${_incidenciaController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Incidencia de Teléfono'),
          backgroundColor: Colors.blue,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Fecha: ",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _seleccionarFecha(context),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _fechaSeleccionada == null
                          ? 'Selecciona una fecha'
                          : 'Fecha seleccionada: ${DateFormat('yyyy-MM-dd').format(_fechaSeleccionada!)}',
                      style: TextStyle(
                          fontSize: 16,
                          color: _fechaSeleccionada == null
                              ? Colors.grey
                              : Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Hora: ",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
                const SizedBox(height: 10),
                IntrinsicWidth(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButton<String>(
                      value: _opcionHora,
                      onChanged: (String? newValue) {
                        setState(() {
                          _opcionHora = newValue;
                        });
                      },
                      items: <String>[
                        '  Primera',
                        '  Segunda',
                        '  Tercera',
                        '  Cuarta',
                        '  Quinta',
                        '  Sexta'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                          ),
                        );
                      }).toList(),
                      hint: const Text('  Selecciona la hora de la incidencia',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Incidencia: ",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _incidenciaController,
                      style: const TextStyle(
                          color: Colors.black), // Cambié el color a gris
                      decoration: const InputDecoration(
                        hintText: 'Escribe aquí el motivo de la incidencia',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                            color: Colors.grey), // Cambié el color a gris
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Resto del código...
                // Reemplaza el DropdownButton de profesores con el siguiente código
                const Text(
                  "Profesor que pone la incidencia: ",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
                const SizedBox(height: 10),
                IntrinsicWidth(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButton<String>(
                      key: Key('profesorDropdown'),
                      value: _profesorSeleccionado,
                      onChanged: (String? newValue) {
                        setState(() {
                          _profesorSeleccionado = newValue;
                        });
                      },
                      items: _profesoresProvider
                          .obtenerNombresYApellidos()
                          .map<DropdownMenuItem<String>>(
                              (String nombreCompleto) {
                        return DropdownMenuItem<String>(
                          value: nombreCompleto,
                          child: Text(
                            nombreCompleto,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                          ),
                        );
                      }).toList(),
                      hint: const Text('  Profesor que ha puesto la incidencia',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Alumno que comete la incidencia: ",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
                const SizedBox(height: 10),
                IntrinsicWidth(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButton<String>(
                      value: _alumnoSeleccionado,
                      onChanged: (String? newValue) {
                        setState(() {
                          _alumnoSeleccionado = newValue;
                        });
                      },
                      // Usa getStudentNames() para obtener los nombres de los alumnos
                      items: _providerAlumno
                          .getStudentNames()
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                          ),
                        );
                      }).toList(),
                      hint: const Text('  Alumno que comete la incidencia',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _enviarDatos,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('Enviar'),
                    ),
                    ElevatedButton(
                      onPressed: _borrarTodo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Borrar Todo'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
