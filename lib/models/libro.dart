class Libro {
  final String titulo;
  final List<String> autores;
  final int? anio;
  final int? coverId;

  Libro({required this.titulo, required this.autores, this.anio, this.coverId});

  factory Libro.fromJson(Map<String, dynamic> json) {
    return Libro(
      titulo: json['title'] ?? 'Sin título',
      autores: List<String>.from(json['author_name'] ?? []),
      anio: json['first_publish_year'],
      coverId: json['cover_i'],
    );
  }

  String get portadaUrl =>
      coverId != null
          ? 'https://covers.openlibrary.org/b/id/$coverId-L.jpg'
          : 'https://via.placeholder.com/150';
}
