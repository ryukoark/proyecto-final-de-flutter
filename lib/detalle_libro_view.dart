import 'package:flutter/material.dart';
import '../../models/libro.dart';

class DetalleLibroView extends StatelessWidget {
  final Libro libro;

  const DetalleLibroView({super.key, required this.libro});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(libro.titulo)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                libro.portadaUrl,
                height: 200,
                errorBuilder: (_, __, ___) => const Icon(Icons.book, size: 100),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              libro.titulo,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Autor(es): ${libro.autores.join(', ')}"),
            const SizedBox(height: 8),
            Text(
              "Año de publicación: ${libro.anio?.toString() ?? 'Desconocido'}",
            ),
          ],
        ),
      ),
    );
  }
}
