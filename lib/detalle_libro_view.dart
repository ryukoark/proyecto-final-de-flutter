import 'package:flutter/material.dart';
import '../../models/libro.dart';

class DetalleLibroView extends StatelessWidget {
  final Libro libro;

  const DetalleLibroView({super.key, required this.libro});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0F8), // Fondo rosado claro
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(libro.titulo, style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  libro.portadaUrl,
                  height: 220,
                  errorBuilder:
                      (_, __, ___) => const Icon(Icons.book, size: 100),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              libro.titulo,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            if (libro.autores.isNotEmpty)
              _infoRow("📚 Autor(es):", libro.autores.join(', ')),

            if (libro.anio != null)
              _infoRow("📅 Año de publicación:", libro.anio.toString()),

            if (libro.ediciones != null)
              _infoRow("📖 Ediciones:", libro.ediciones.toString()),

            if (libro.idiomas != null && libro.idiomas!.isNotEmpty)
              _infoRow("🌐 Idioma(s):", libro.idiomas!.join(', ')),

            if (libro.temas != null && libro.temas!.isNotEmpty)
              _infoRow("🏷️ Temas:", libro.temas!.join(', ')),

            if (libro.descripcion != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "📝 Sinopsis:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      libro.descripcion!,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),
            _infoRow("🔗 ID OpenLibrary:", libro.idOpenLibrary),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
