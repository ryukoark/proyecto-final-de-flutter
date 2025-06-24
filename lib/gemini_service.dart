import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // Variable para guardar la instancia del modelo de Gemini
  GenerativeModel? _model;

  // Constructor que inicializa el servicio
  GeminiService() {
    _initialize();
  }

  // Método privado para configurar el modelo
  void _initialize() {
    // 1. Obtener la clave de API desde el archivo .env
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    // 2. Validar que la clave exista
    if (apiKey == null) {
      print('API Key no encontrada en .env');
      return;
    }

    // 3. Inicializa el modelo generativo
    _model = GenerativeModel(
      model: 'gemini-1.5-flash', // Modelo rápido y eficiente para chat
      apiKey: apiKey,
    );
  }

  // Método público para obtener una respuesta del modelo
  Future<String> getResponse(String prompt) async {
    // Verifica si el modelo fue inicializado
    if (_model == null) {
      return "Error: El servicio de IA no está inicializado.";
    }

    try {
      // Prepara el contenido y llama a la API
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      // Devuelve el texto de la respuesta
      return response.text ?? 'No se pudo obtener una respuesta.';
    } catch (e) {
      // Maneja cualquier error durante la llamada
      print('Ocurrió un error al contactar a Gemini: $e');
      return 'Error al procesar la solicitud. Inténtalo de nuevo.';
    }
  }
}
