import 'package:flutter/material.dart';
import '../../models/libro.dart';
import '../../services/open_library_service.dart';
import 'detalle_libro_view.dart'; // Importa la nueva vista

class BibliotecaView extends StatefulWidget {
  const BibliotecaView({super.key});

  @override
  State<BibliotecaView> createState() => _BibliotecaViewState();
}

class _BibliotecaViewState extends State<BibliotecaView> {
  final TextEditingController _controller = TextEditingController();
  List<Libro> resultados = [];
  bool cargando = false;

  @override
  void initState() {
    super.initState();
    _buscarLibrosIniciales(); // Búsqueda inicial
  }

  void _buscarLibrosIniciales() async {
    setState(() => cargando = true);
    try {
      final libros = await buscarLibros("bestsellers");
      setState(() => resultados = libros.take(20).toList());
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => cargando = false);
    }
  }

  void _buscar() async {
    setState(() => cargando = true);
    try {
      final libros = await buscarLibros(_controller.text.trim());
      setState(() => resultados = libros.take(20).toList());
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Buscar libros...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _buscar,
                ),
              ),
              onSubmitted: (_) => _buscar(),
            ),
            const SizedBox(height: 20),
            if (cargando)
              const CircularProgressIndicator()
            else if (resultados.isEmpty)
              const Text('No hay resultados.')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: resultados.length,
                  itemBuilder: (_, i) {
                    final libro = resultados[i];
                    return Card(
                      child: ListTile(
                        leading: Image.network(
                          libro.portadaUrl,
                          width: 50,
                          errorBuilder: (_, __, ___) => const Icon(Icons.book),
                        ),
                        title: Text(libro.titulo),
                        subtitle: Text(libro.autores.join(', ')),
                        trailing: Text(libro.anio?.toString() ?? ''),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetalleLibroView(libro: libro),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
