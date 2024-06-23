import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iseneca/models/centro_response.dart';
import 'package:iseneca/models/horario_response.dart';
import 'package:iseneca/utils/utilidades.dart';

class CentroProvider extends ChangeNotifier {
  
  late HorarioResponse listaHorariosProfesores;
 

  CentroProvider() {
    debugPrint("Centro Provider inicializado");

    getHorario();
  }

  getHorario() async {
    const url =
        "https://script.google.com/macros/s/AKfycbyPsB_koj3MwkmRFn8IJU-k4sOP8nRfnHHKNNt9xov9INZ1VEsQbu96gDR8Seiz0oDGOQ/exec?spreadsheetId=11Y4M52bYFMCIa5uU52vKll2-OY0VtFiGK2PhMWShngg&sheet=Horarios";
    String jsonData = await Utilidades.getJsonData(url);
    jsonData = '{"results":$jsonData}';
    listaHorariosProfesores = HorarioResponse.fromJson(jsonData);

    notifyListeners();
  }
}
