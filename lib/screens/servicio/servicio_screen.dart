import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ServicioScreen extends StatelessWidget {
  const ServicioScreen({Key? key}) : super(key: key);
  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "BAÑO",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, "servicio_es_screen"),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: FaIcon(FontAwesomeIcons.doorOpen,
                    color: Color.fromARGB(255, 96, 153, 199)),
                title: Text(
                  'Entrada/Salida',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                trailing:
                    const Icon(Icons.arrow_forward_ios, color: Colors.blue),
              ),
            ),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, "servicio_informes_screen"),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const FaIcon(FontAwesomeIcons.solidFolder,
                    color: Color.fromARGB(255, 96, 153, 199)),
                title: const Text(
                  'Informes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                trailing:
                    const Icon(Icons.arrow_forward_ios, color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
