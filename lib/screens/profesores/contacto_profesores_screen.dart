import 'package:flutter/material.dart';
import 'package:iseneca/models/credenciales_response.dart';
import 'package:iseneca/providers/credenciales_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactoProfesoresScreen extends StatefulWidget {
  const ContactoProfesoresScreen({Key? key}) : super(key: key);

  @override
  _ContactoProfesoresScreenState createState() =>
      _ContactoProfesoresScreenState();
}

class _ContactoProfesoresScreenState extends State<ContactoProfesoresScreen> {
  List<Credenciales> listaOrdenadaProfesores = [];
  List<Credenciales> profesoresFiltrados = [];

  bool isLoading = true;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final credencialesProvider =
          Provider.of<CredencialesProvider>(context, listen: false);
      _fetchProfesores(credencialesProvider);
    });
  }

  Future<void> _fetchProfesores(
      CredencialesProvider credencialesProvider) async {
    setState(() {
      isLoading = true;
    });

    try {
      await credencialesProvider.getCredencialesUsuario();
      if (credencialesProvider.listaCredenciales.isEmpty) {
        Future.delayed(const Duration(seconds: 2), () {
          _fetchProfesores(credencialesProvider);
        });
      }
      setState(() {
        listaOrdenadaProfesores = credencialesProvider.listaCredenciales;
        listaOrdenadaProfesores.sort((a, b) => a.nombre.compareTo(b.nombre));
        profesoresFiltrados = List.from(listaOrdenadaProfesores);
      });
    } catch (e) {
      Future.delayed(const Duration(seconds: 2), () {
        _fetchProfesores(credencialesProvider);
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterSearchResults(String query) {
    setState(() {
      if (query.isEmpty) {
        profesoresFiltrados = List.from(listaOrdenadaProfesores);
      } else {
        profesoresFiltrados = listaOrdenadaProfesores
            .where((profesor) => "${profesor.nombre} ${profesor.apellidos}"
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
              'CONTACTO',
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
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          "${profesoresFiltrados[index].nombre[0]}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        "${profesoresFiltrados[index].nombre} ${profesoresFiltrados[index].apellidos}",
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
      BuildContext context, int index, List<Credenciales> credenciales) {
    Credenciales profesor = credenciales[index];

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text("${profesor.nombre} ${profesor.apellidos}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContactInfoRow(Icons.mail, "Correo: ${profesor.usuario}",
                  () => _launchEmail(profesor.usuario)),
              SizedBox(height: 10),
              _buildContactInfoRow(
                  Icons.phone,
                  "Teléfono: ${profesor.telefono}",
                  () => _launchPhone(profesor.telefono)),
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

  Widget _buildContactInfoRow(
      IconData icon, String text, VoidCallback onPressed) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent),
        SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: onPressed,
            child: Text(
              text,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _launchEmail(String email) async {
    final Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    if (await canLaunch(_emailLaunchUri.toString())) {
      await launch(_emailLaunchUri.toString());
    } else {
      throw 'Could not launch $email';
    }
  }

  void _launchPhone(String phone) async {
    final Uri _phoneLaunchUri = Uri(
      scheme: 'tel',
      path: phone,
    );

    if (await canLaunch(_phoneLaunchUri.toString())) {
      await launch(_phoneLaunchUri.toString());
    } else {
      throw 'Could not launch $phone';
    }
  }
}
