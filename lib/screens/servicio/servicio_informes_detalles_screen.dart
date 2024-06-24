import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iseneca/models/servicio_response.dart'; // Asegúrate de que esta importación sea correcta
import 'package:iseneca/providers/servicio_provider.dart';

class ServicioInformesDetallesScreen extends StatefulWidget {
  const ServicioInformesDetallesScreen({Key? key}) : super(key: key);

  @override
  _ServicioInformesDetallesScreenState createState() =>
      _ServicioInformesDetallesScreenState();
}

class _ServicioInformesDetallesScreenState
    extends State<ServicioInformesDetallesScreen> {
  List<Servicio> servicios =
      []; // Lista para almacenar los servicios del alumno
  bool isLoading = false; // Estado para indicar si se está cargando

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final nombreAlumno = ModalRoute.of(context)!.settings.arguments
        as String; // Obtener nombre del argumento
    final servicioProvider =
        Provider.of<ServicioProvider>(context, listen: false);

    setState(() {
      isLoading = true; // Marcar que se está cargando
    });

    try {
      // Cargar servicios del alumno
      servicios = await servicioProvider.getServiciosPorAlumno(nombreAlumno);

      servicios = servicios.reversed.toList();

      setState(() {
        // Actualizar el estado para mostrar los servicios
        isLoading = false; // Marcar que la carga ha terminado
      });
    } catch (e) {
      print('Error cargando servicios del alumno: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar servicios del alumno'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        isLoading =
            false; // Asegurarse de que isLoading se marque como falso en caso de error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombreAlumno = ModalRoute.of(context)!.settings.arguments
        as String; // Obtener nombre del argumento
    final size =
        MediaQuery.of(context).size; // Obtener el tamaño de la pantalla

    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Visitas - $nombreAlumno'),
        backgroundColor: Colors.blue, // Fondo azul en el AppBar
        titleTextStyle:
            TextStyle(color: Colors.white, fontSize: 20), // Texto en blanco
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : servicios.isEmpty
              ? Center(
                  child: Text('No hay servicios disponibles'),
                )
              : ListView.builder(
                  itemCount: servicios.length,
                  itemBuilder: (context, index) {
                    final servicio = servicios[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical:
                            size.height * 0.005, // Espaciado vertical dinámico
                        horizontal:
                            size.width * 0.03, // Espaciado horizontal dinámico
                      ),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical:
                                size.height * 0.01, // Padding vertical dinámico
                            horizontal: size.width *
                                0.04, // Padding horizontal dinámico
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: Colors.blueAccent,
                                      size: size.width * 0.04),
                                  SizedBox(
                                      width: size.width *
                                          0.02), // Espaciado horizontal dinámico
                                  Text(
                                    'Fecha: ${servicio.fechaEntrada}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: size.width * 0.035),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height: size.height *
                                      0.005), // Espaciado vertical dinámico
                              Row(
                                children: [
                                  Icon(Icons.access_time,
                                      color: Colors.blueAccent,
                                      size: size.width * 0.04),
                                  SizedBox(
                                      width: size.width *
                                          0.02), // Espaciado horizontal dinámico
                                  Text(
                                    'Hora Entrada: ${servicio.horaEntrada}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: size.width * 0.035),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height: size.height *
                                      0.005), // Espaciado vertical dinámico
                              Row(
                                children: [
                                  Icon(Icons.access_time_outlined,
                                      color: Colors.blueAccent,
                                      size: size.width * 0.04),
                                  SizedBox(
                                      width: size.width *
                                          0.02), // Espaciado horizontal dinámico
                                  Text(
                                    'Hora Salida: ${servicio.horaSalida}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: size.width * 0.035),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
