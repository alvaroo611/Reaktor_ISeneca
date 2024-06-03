import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:iseneca/loggers/log.dart';

class XmlProvider extends ChangeNotifier {
  final Dio _dio = Dio();

  Future<void> loadXmlDataFromFile(http.Client client) async {
    try {
      // Leer el archivo XML desde los activos
      ByteData xmlBytes = await rootBundle.load('assets/horario.xml');
      List<int> xmlList = xmlBytes.buffer.asUint8List();

      // Crear un objeto FormData con el archivo XML
      FormData formData = FormData.fromMap({
        'xmlFile': MultipartFile.fromBytes(
          xmlList,
          filename: 'horario.xml',
          contentType: MediaType('application', 'xml'),
        ),
      });

      // Enviar la solicitud HTTP con Dio
      Response response = await _dio.post(
        'https://microservices-iesjandula.duckdns.org:8088/horarios/send/xml',
        data: formData,
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        print("Datos cargados correctamente");
        LogService.logInfo("Datos cargados correctamente ");
        notifyListeners();
      } else {
        print("Error al cargar los datos");

        throw Exception('Failed to load XML data');
      }
    } catch (error) {
      print('Error al cargar el archivo XML: $error');
      LogService.logError('Error al cargar los datos', error);
      throw error;
    }
  }
}
