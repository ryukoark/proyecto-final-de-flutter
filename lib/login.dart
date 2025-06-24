import 'package:flutter/material.dart';
import 'dashboard.dart'; // Asegúrate de tener esta vista creada

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    // Credenciales de ejemplo
    if (email == "admin@gmail.com" && password == "123456") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Credenciales incorrectas')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'INICIAR SESIÓN',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Iniciar sesión'),
            ),
            const SizedBox(height: 24.0),
            const Text(
              'O iniciar sesión con:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: IconButton(
                iconSize: 60,
                icon: SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/IOS_Google_icon.png/640px-IOS_Google_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
                onPressed: () {
                  // Acción para iniciar sesión con Google
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
