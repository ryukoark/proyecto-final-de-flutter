import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Contacto', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Quejas o Sugerencias'),
            const SizedBox(height: 10.0),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(20.0),
              ),
              padding: const EdgeInsets.all(10.0),
              child: const TextField(
                maxLines: null,
                expands: true,
                decoration: InputDecoration.collapsed(
                  hintText: 'Escribe tu mensaje...',
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                onPressed: () {
                  // Acción de enviar
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 12.0,
                  ),
                  child: Text('Enviar', style: TextStyle(color: Colors.black)),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.blue,
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text('Búscanos en:', style: TextStyle(color: Colors.white)),
            IconButton(
              icon: const Icon(Icons.facebook, color: Colors.white),
              onPressed: () {},
            ),
            const Icon(Icons.clear, color: Colors.white), // X icon placeholder
            const Icon(
              Icons.camera_alt,
              color: Colors.pinkAccent,
            ), // Instagram placeholder
          ],
        ),
      ),
    );
  }
}
