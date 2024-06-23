import 'package:flutter/material.dart';
import 'package:iseneca/models/credenciales_response.dart';
import 'package:provider/provider.dart';
import 'package:iseneca/providers/providers.dart';

class HorarioProfesoresScreen extends StatefulWidget {
  const HorarioProfesoresScreen({Key? key}) : super(key: key);

  @override
  _HorarioProfesoresScreenState createState() =>
      _HorarioProfesoresScreenState();
}

class _HorarioProfesoresScreenState extends State<HorarioProfesoresScreen> {
  List<Credenciales> listaOrdenadaProfesores = [];
  List<Credenciales> profesoresFiltrados = [];
  bool isLoading = true;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
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
        // No actualizar profesores si la lista está vacía
        setState(() {
          isLoading = false;
        });
        return;
      }

      setState(() {
        listaOrdenadaProfesores = credencialesProvider.listaCredenciales;
        // Actualizar profesoresFiltrados solo si no está vacía
        if (_controller.text.isNotEmpty) {
          filterSearchResults(_controller.text);
        } else {
          listaOrdenadaProfesores.sort((a, b) => a.nombre.compareTo(b.nombre));
          profesoresFiltrados = List.from(listaOrdenadaProfesores);
        }
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
              'HORARIO',
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
              itemCount: profesoresFiltrados.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      "horario_profesores_detalles_screen",
                      arguments: profesoresFiltrados[index],
                    );
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
                          profesoresFiltrados[index].nombre[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        '${profesoresFiltrados[index].nombre} ${profesoresFiltrados[index].apellidos}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
