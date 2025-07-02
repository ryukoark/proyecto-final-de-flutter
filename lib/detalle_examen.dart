import 'package:flutter/material.dart';

class DetalleExamenView extends StatelessWidget {
  final String texto;
  final DateTime? timestamp;

  const DetalleExamenView({super.key, required this.texto, this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Examen completo"),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: const Color(0xFFF8F0F8),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (timestamp != null)
              Text(
                "Generado el: ${timestamp.toString()}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            const SizedBox(height: 16),
            const Text(
              "Contenido del examen:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0), // fondo similar al screenshot
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(texto, style: const TextStyle(fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
