import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/libro.dart';

Future<List<Libro>> buscarLibros(String query) async {
  final url = Uri.parse('https://openlibrary.org/search.json?q=$query');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final docs = data['docs'] as List;
    return docs.map((json) => Libro.fromJson(json)).toList();
  } else {
    throw Exception('Error al buscar libros');
  }
}
