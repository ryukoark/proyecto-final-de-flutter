import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'gemini_service.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  const ChatPage({super.key, required this.conversationId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _geminiService = GeminiService();

  bool _isLoading = false;
  final uid = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _guardarMensajeFirestore(String texto, String rol) async {
    if (uid == null) return;

    final mensajesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(uid)
        .collection('conversaciones')
        .doc(widget.conversationId)
        .collection('mensajes');

    await mensajesRef.add({
      'texto': texto,
      'rol': rol,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(uid)
        .collection('conversaciones')
        .doc(widget.conversationId)
        .update({
          'last_message': texto,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    setState(() => _isLoading = true);
    await _guardarMensajeFirestore(text, 'usuario');

    try {
      // Respuesta normal de la IA
      final response = await _geminiService.getResponse(text);
      await _guardarMensajeFirestore(response, 'ia');

      // Generar examen basado en la respuesta
      final promptExamen = '''
Basado en el siguiente contenido:
"$response"

Genera exactamente 5 preguntas de repaso tipo examen, combinando opción múltiple y verdadero/falso.
Usa el siguiente formato **estrictamente**, sin explicación adicional ni repeticiones:

1. Verdadero/Falso: [enunciado]
a) Verdadero
b) Falso

2. Opción Múltiple: [enunciado]
a) ...
b) ...
c) ...
d) ...

El texto debe contener solo las 5 preguntas, claramente enumeradas, con opciones en formato "a)", "b)", etc.
No incluyas respuestas correctas ni explicaciones.
''';

      final examen = await _geminiService.getResponse(promptExamen);
      await _guardarMensajeFirestore(examen, 'ia-examen');
    } catch (_) {
      await _guardarMensajeFirestore("Lo siento, ocurrió un error.", 'ia');
    }

    setState(() => _isLoading = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('No autenticado')));
    }

    final mensajesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(uid)
        .collection('conversaciones')
        .doc(widget.conversationId)
        .collection('mensajes')
        .orderBy('timestamp');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estud-IA'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: mensajesRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final mensajes = snapshot.data?.docs ?? [];

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: mensajes.length,
                  itemBuilder: (context, index) {
                    final data = mensajes[index].data() as Map<String, dynamic>;
                    final text = data['texto'] ?? '';
                    final rol = data['rol'];
                    if (rol == 'ia-examen') return const SizedBox.shrink();
                    final isUser = rol == 'usuario';
                    final isExam = rol == 'ia-examen';

                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              isUser
                                  ? Colors.blue
                                  : isExam
                                  ? Colors.orange[100]
                                  : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isExam)
                              const Text(
                                "📘 Preguntas de repaso:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            if (isExam) const SizedBox(height: 6),
                            Text(
                              text,
                              style: TextStyle(
                                color: isUser ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 8),
                  Text("Estud-IA está pensando..."),
                ],
              ),
            ),
          _TextInputArea(
            controller: _controller,
            onSend: _sendMessage,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}

class _TextInputArea extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;

  const _TextInputArea({
    required this.controller,
    required this.onSend,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration.collapsed(
                hintText: "Escribe tu mensaje...",
              ),
              onSubmitted: isLoading ? null : (_) => onSend(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: isLoading ? null : onSend,
          ),
        ],
      ),
    );
  }
}
