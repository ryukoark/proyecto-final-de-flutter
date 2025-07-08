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
  int puntaje = 0;

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
        if (actual != null) lista.add(actual);
        final isVF = trimmed.toLowerCase().contains("verdadero o falso");
        actual = _Pregunta(
          numero: lista.length + 1,
          enunciado: trimmed,
          opciones: isVF ? ["Verdadero", "Falso"] : [],
          esVerdaderoFalso: isVF,
        );
      } else if (RegExp(r'^[a-dA-D]\)').hasMatch(trimmed) &&
          actual != null &&
          !actual.esVerdaderoFalso) {
        actual.opciones.add(trimmed);
      }
    }

    if (actual != null) lista.add(actual);
    return lista;
  }

  Future<void> _calcularResultado() async {
    final geminiService = GeminiService();

    final respuestasUsuario = preguntas
        .map((p) {
          final r = p.respuestaSeleccionada ?? '';
          return "${p.numero}. $r";
        })
        .join('\n');

    final promptEvaluacion = '''
Corrige el siguiente examen del usuario. Las preguntas son las siguientes:

${widget.texto}

Y estas son las respuestas del usuario:
$respuestasUsuario

Evalúa el examen, indica cuántas respuestas fueron correctas de 5 y si el usuario aprueba (mínimo 4 correctas para aprobar).
Sé breve, responde así:
"Resultado: X/5 correctas. ✅ Aprobado" o "Resultado: X/5 correctas. ❌ No aprobado"
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
