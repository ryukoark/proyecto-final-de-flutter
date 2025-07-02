// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart'; // 👈 Importar Firebase
import 'profile.dart';
import 'inicio.dart';
import 'examen.dart';

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
    return MaterialApp(
      title: 'Mi App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Ruta inicial
      routes: {
        '/': (context) => const InicioPage(),
        '/profile': (context) => const ProfilePage(),
        '/examenes': (_) => const ExamenView(), // 👈 Ruta añadida
      },
    );
  }
}
