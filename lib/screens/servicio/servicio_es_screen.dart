import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iseneca/providers/alumno_provider.dart';
import 'package:iseneca/models/Student.dart';
import 'package:http/http.dart' as http;

class ServicioESScreen extends StatefulWidget {
  const ServicioESScreen({Key? key}) : super(key: key);

  @override
  _ServicioESScreenState createState() => _ServicioESScreenState();
}

class _ServicioESScreenState extends State<ServicioESScreen> {
  late ProviderAlumno _providerAlumno;
  late List<Student> listadoAlumnos = [];
  late List<String> cursosUnicos = [];
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _providerAlumno = Provider.of<ProviderAlumno>(context, listen: false);
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final httpClient = http.Client();
    await _providerAlumno.fetchStudents(httpClient);
    setState(() {
      listadoAlumnos = _providerAlumno.students;
      cursosUnicos =
          listadoAlumnos.map((student) => student.course).toSet().toList();
    });
  }

  void filterSearchResults(String query) {
    setState(() {
      cursosUnicos = listadoAlumnos
          .where((student) =>
              student.course.toLowerCase().contains(query.toLowerCase()))
          .map((student) => student.course)
          .toSet()
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            const Text(
              'Cursos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 20),
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
                          hintText: 'Buscar curso...',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
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
      body: Center(
        child: listadoAlumnos.isEmpty
            ? const CircularProgressIndicator()
            : ListView.builder(
                itemCount: cursosUnicos.length,
                itemBuilder: (BuildContext context, int index) {
                  final curso = cursosUnicos[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        "servicio_es_alumnos_screen",
                        arguments: curso,
                      );
                    },
                    child: Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                        leading: const Icon(
                          Icons.school,
                          color: Colors.blue,
                          size: 30,
                        ),
                        title: Text(
                          curso,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
