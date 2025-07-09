class Libro {
  final String titulo;
  final List<String> autores;
  final int? anio;
  final int? coverId;
  final int? ediciones;
  final List<String>? idiomas;
  final List<String>? temas;
  final String? descripcion;
  final String idOpenLibrary;

  Libro({
    required this.titulo,
    required this.autores,
    this.anio,
    this.coverId,
    this.ediciones,
    this.idiomas,
    this.temas,
    this.descripcion,
    required this.idOpenLibrary,
  });

  factory Libro.fromJson(Map<String, dynamic> json) {
    return Libro(
      titulo: json['title'] ?? 'Sin título',
      autores: List<String>.from(json['author_name'] ?? []),
      anio: json['first_publish_year'],
      coverId: json['cover_i'],
      ediciones: json['edition_count'],
      idiomas: (json['language'] as List?)?.map((e) => e.toString()).toList(),
      temas: (json['subject'] as List?)?.map((e) => e.toString()).toList(),
      descripcion:
          json['description'] is String
              ? json['description']
              : (json['description']?['value']), // soporta {value: "..."}
      idOpenLibrary: (json['key'] ?? '').toString().replaceAll('/works/', ''),
    );
  }

  String get portadaUrl =>
      coverId != null
          ? 'https://covers.openlibrary.org/b/id/$coverId-L.jpg'
          : 'https://via.placeholder.com/150';
}
