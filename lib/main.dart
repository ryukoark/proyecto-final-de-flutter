// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart'; // 👈 Importar Firebase
import 'inicio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 👈 Necesario para Firebase
  await dotenv.load(fileName: ".env"); // Cargar variables de entorno
  await Firebase.initializeApp(); // 👈 Inicializar Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Mi App',
      debugShowCheckedModeBanner: false,
      home: InicioPage(), // Tu pantalla de inicio
    );
  }
}
