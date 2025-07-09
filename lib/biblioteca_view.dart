import 'package:flutter/material.dart';
import '../../models/libro.dart';
import '../../services/open_library_service.dart';
import 'detalle_libro_view.dart';

class BibliotecaView extends StatefulWidget {
  const BibliotecaView({super.key});

  @override
  State<BibliotecaView> createState() => _BibliotecaViewState();
}

class _BibliotecaViewState extends State<BibliotecaView> {
  final TextEditingController _controller = TextEditingController();
  List<Libro> resultados = [];
  bool cargando = false;

  final Map<String, String> categorias = {
    'Fantasía': 'fantasy',
    'Ciencia Ficción': 'science_fiction',
    'Romance': 'romance',
    'Historia': 'history',
    'Aventura': 'adventure',
    'Ciencia': 'science',
    'Ficción': 'fiction',
    'Arte': 'art',
    'Misterio': 'mystery',
    'Biografía': 'biography',
  };

  @override
  void initState() {
    super.initState();
    _buscarLibrosIniciales();
  }

  void _buscarLibrosIniciales() async {
    setState(() => cargando = true);
    try {
      final libros = await buscarLibros("bestsellers");
      setState(() => resultados = libros.take(20).toList());
    } catch (e) {
      _mostrarError(e);
    } finally {
      setState(() => cargando = false);
    }
  }

  void _buscarTexto() async {
    setState(() => cargando = true);
    try {
      final libros = await buscarLibros(_controller.text.trim());
      setState(() => resultados = libros.take(20).toList());
    } catch (e) {
      _mostrarError(e);
    } finally {
      setState(() => cargando = false);
    }
  }

  void _buscarPorCategoria(String subject) async {
    setState(() => cargando = true);
    try {
      final libros = await buscarLibros('subject:$subject');
      setState(() => resultados = libros.take(20).toList());
    } catch (e) {
      _mostrarError(e);
    } finally {
      setState(() => cargando = false);
    }
  }

  void _mostrarError(dynamic e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
  }

  void _mostrarSelectorCategorias() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => ListView(
            shrinkWrap: true,
            children:
                categorias.entries.map((entry) {
                  return ListTile(
                    leading: const Icon(Icons.category),
                    title: Text(entry.key),
                    onTap: () {
                      Navigator.pop(context);
                      _buscarPorCategoria(entry.value);
                    },
                  );
                }).toList(),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0F8),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Biblioteca', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarSelectorCategorias,
        backgroundColor: const Color(0xFFADD8FF),
        child: const Icon(Icons.search, color: Colors.deepPurple),
        tooltip: "Filtrar por categoría",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Buscar libros...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _buscarTexto,
                ),
              ),
              onSubmitted: (_) => _buscarTexto(),
            ),
            const SizedBox(height: 20),
            if (cargando)
              const CircularProgressIndicator()
            else if (resultados.isEmpty)
              const Text(
                'No hay resultados.',
                style: TextStyle(color: Colors.black54),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: resultados.length,
                  itemBuilder: (_, i) {
                    final libro = resultados[i];
                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            libro.portadaUrl,
                            width: 50,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) =>
                                    const Icon(Icons.book, size: 50),
                          ),
                        ),
                        title: Text(
                          libro.titulo,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
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
