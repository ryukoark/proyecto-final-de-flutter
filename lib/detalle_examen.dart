import 'package:flutter/material.dart';
import 'gemini_service.dart';

class DetalleExamenView extends StatefulWidget {
  final String texto;
  final DateTime? timestamp;

  const DetalleExamenView({super.key, required this.texto, this.timestamp});

  @override
  State<DetalleExamenView> createState() => _DetalleExamenViewState();
}

class _DetalleExamenViewState extends State<DetalleExamenView> {
  late List<_Pregunta> preguntas;
  bool enviado = false;

  @override
  void initState() {
    super.initState();
    preguntas = _parsearPreguntas(widget.texto);
  }

  List<_Pregunta> _parsearPreguntas(String texto) {
    final lines = texto.split('\n');
    final List<_Pregunta> lista = [];
    _Pregunta? actual;

    for (final line in lines) {
      final trimmed = line.trim();

      if (RegExp(r'^\d+\..*').hasMatch(trimmed)) {
        if (actual != null) {
          if (actual.esVerdaderoFalso && actual.opciones.isEmpty) {
            actual.opciones.addAll(["a) Verdadero", "b) Falso"]);
          }
          lista.add(actual);
        }

        final isVF =
            trimmed.toLowerCase().contains("verdadero o falso") ||
            trimmed.toLowerCase().contains("verdadero/falso");

        actual = _Pregunta(
          numero: lista.length + 1,
          enunciado: trimmed,
          opciones: [],
          esVerdaderoFalso: isVF,
        );
      } else if (RegExp(r'^[a-dA-D]\)').hasMatch(trimmed) && actual != null) {
        actual.opciones.add(trimmed);
      }
    }

    if (actual != null) {
      if (actual.esVerdaderoFalso && actual.opciones.isEmpty) {
        actual.opciones.addAll(["a) Verdadero", "b) Falso"]);
      }
      lista.add(actual);
    }

    return lista;
  }

  Future<void> _calcularResultado() async {
    final sinResponder =
        preguntas.where((p) => p.respuestaSeleccionada == null).toList();

    if (sinResponder.isNotEmpty) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Faltan respuestas"),
              content: Text(
                "Debes responder todas las preguntas antes de enviar. Faltan ${sinResponder.length}.",
              ),
              actions: [
                TextButton(
                  child: const Text("Cerrar"),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
      );
      return;
    }

    final geminiService = GeminiService();

    final respuestasUsuario = preguntas
        .map((p) {
          final r = p.respuestaSeleccionada;

          if (r == null || r.isEmpty) {
            return "${p.numero}. [Sin respuesta]";
          }

          if (p.esVerdaderoFalso) {
            final index = p.opciones.indexWhere(
              (op) =>
                  r.trim().toLowerCase() ==
                  op.split(')').last.trim().toLowerCase(),
            );
            final letra = index == 0 ? 'a' : 'b';
            return "${p.numero}. $letra) ${r.trim()}";
          }

          return "${p.numero}. $r";
        })
        .join('\n');

    final promptEvaluacion = '''
Corrige el siguiente examen del usuario. Las preguntas son las siguientes:

${widget.texto}

Y estas son las respuestas del usuario:
$respuestasUsuario

Evalúa el examen. Indica:
1. Cuántas respuestas fueron correctas de 5.
2. Si el usuario aprueba (mínimo 4 correctas para aprobar).
3. Para cada pregunta, señala la opción correcta y si el usuario acertó o no.

Usa este formato exacto:

Resultado: X/5 correctas. ✅ Aprobado (o ❌ No aprobado)

Desglose:
1. ❌ Tu respuesta: b) — Correcta: d)
2. ✅ Tu respuesta: c) — Correcta: c)
...
''';

    setState(() => enviado = true);

    final resultado = await geminiService.getResponse(promptEvaluacion);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Resultado del examen"),
            content: Text(resultado),
            actions: [
              TextButton(
                child: const Text("Cerrar"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

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
            if (widget.timestamp != null)
              Text(
                "Generado el: ${widget.timestamp.toString()}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            const SizedBox(height: 16),
            const Text(
              "Contenido del examen:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: preguntas.length,
                itemBuilder: (context, index) {
                  final pregunta = preguntas[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    color: const Color(0xFFFFF3E0),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${pregunta.numero}. ${pregunta.enunciado}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...pregunta.opciones.map(
                            (op) => RadioListTile<String>(
                              title: Text(op),
                              value: op,
                              groupValue: pregunta.respuestaSeleccionada,
                              onChanged:
                                  enviado
                                      ? null
                                      : (val) {
                                        setState(() {
                                          pregunta.respuestaSeleccionada = val;
                                        });
                                      },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (!enviado)
              ElevatedButton(
                onPressed: _calcularResultado,
                child: const Text("Enviar respuestas"),
              ),
          ],
        ),
      ),
    );
  }
}

class _Pregunta {
  final int numero;
  final String enunciado;
  final List<String> opciones;
  final bool esVerdaderoFalso;
  String? respuestaSeleccionada;

  _Pregunta({
    required this.numero,
    required this.enunciado,
    required this.opciones,
    this.respuestaSeleccionada,
    this.esVerdaderoFalso = false,
  });
}
