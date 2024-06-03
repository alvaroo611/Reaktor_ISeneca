import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

class LogService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(),
  );

  static void logInfo(String message) {
    _logger.i(message);
    _sendToServer("INFO", message);
  }

  static void logError(String message,
      [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error, stackTrace);
    _sendToServer("ERROR", message, error, stackTrace);
  }

  static void logWarning(String message) {
    _logger.w(message);
    _sendToServer("WARNING", message);
  }

  static void logDebug(String message) {
    _logger.d(message);
    _sendToServer("DEBUG", message);
  }

  static Future<void> _sendToServer(String level, String message,
      [dynamic error, StackTrace? stackTrace]) async {
    // Aquí puedes implementar el envío de logs a un servidor
    final url = Uri.parse('https://microservices-iesjandula.duckdns.org');
    final response = await http.post(url, body: {
      'level': level,
      'message': message,
      'error': error?.toString(),
      'stackTrace': stackTrace?.toString(),
    });

    if (response.statusCode != 200) {
      _logger.w("Failed to send log to server: ${response.statusCode}");
    }
  }
}
