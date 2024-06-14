import 'dart:math';
import 'package:flutter/material.dart';
import 'package:iseneca/models/profesor.dart';
import 'package:iseneca/providers/profesores_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:http/http.dart' as http;

class ContactoProfesoresScreen extends StatefulWidget {
  const ContactoProfesoresScreen({Key? key}) : super(key: key);

  @override
  _ContactoProfesoresScreenState createState() =>
      _ContactoProfesoresScreenState();
}

class _ContactoProfesoresScreenState extends State<ContactoProfesoresScreen> {
  List<Profesor> listaOrdenadaProfesores = [];
  List<Profesor> profesoresFiltrados = [];
  bool isLoading = true;
  TextEditingController _controller = TextEditingController();

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
              'Contacto profesor',
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
                    _mostrarAlert(context, index, profesoresFiltrados);
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
                          profesoresFiltrados[index].nombreCompleto[
                              0], // Muestra la primera letra del nombre
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
}
