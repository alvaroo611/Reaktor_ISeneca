import 'package:dio/dio.dart';
//Utils
class Utilidades {

  static Future<String> getJsonData(String url) async {
    final dio = Dio();
    final response = await dio.get(url);
    return(response.data);
  }
  
}
