import 'package:flutter/material.dart';
import 'gemini_service.dart'; // Importamos el servicio que acabamos de crear

// Un modelo simple para darle estructura a cada mensaje en el chat
class ChatMessage {
  final String text;
  final bool isUser; // True si el mensaje es del usuario, false si es del bot

  ChatMessage({required this.text, required this.isUser});
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  final List<ChatMessage> _messages = []; // Lista para guardar la conversación
  bool _isLoading = false; // Estado para mostrar un indicador de carga

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Añadimos un mensaje de bienvenida del bot al iniciar la pantalla
    _messages.add(
      ChatMessage(
        text: "Hola, soy Estud-IA. ¿Qué necesitas saber hoy?",
        isUser: false,
      ),
    );
  }

  // Función principal para enviar el mensaje y obtener respuesta
  void _sendMessage() async {
    final text = _textController.text;
    if (text.isEmpty) return; // No hacer nada si el texto está vacío
    _textController.clear();

    // Actualiza la UI para mostrar el mensaje del usuario y el indicador de carga
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });

    _scrollToBottom();

    // Llama al servicio de Gemini para obtener la respuesta
    try {
      final response = await _geminiService.getResponse(text);
      // Actualiza la UI con la respuesta del bot
      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      // Maneja cualquier error
      setState(() {
        _messages.add(
          ChatMessage(text: "Lo siento, algo salió mal.", isUser: false),
        );
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    // Pequeño retraso para permitir que el ListView se actualice antes de hacer scroll
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Estud-IA"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Área donde se muestran los mensajes
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                // Usamos un widget separado para la burbuja de mensaje
                return _MessageBubble(message: message);
              },
            ),
          ),
          // Muestra el indicador de "escribiendo..."
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                children: [
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(width: 8),
                  Text("Estud-IA está pensando..."),
                ],
              ),
            ),
          // Área para escribir el mensaje
          _TextInputArea(
            controller: _textController,
            onSendMessage: _sendMessage,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}

// WIDGET PARA LA BURBUJA DE MENSAJE
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      // Alinear a la derecha si es del usuario, a la izquierda si es del bot
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}

// WIDGET PARA LA BARRA DE ESCRITURA
class _TextInputArea extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendMessage;
  final bool isLoading;

  const _TextInputArea({
    required this.controller,
    required this.onSendMessage,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration.collapsed(
                hintText: "Escribe tu pregunta...",
              ),
              // Permite enviar con el botón de "enter" en el teclado
              onSubmitted: isLoading ? null : (_) => onSendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            // Deshabilita el botón mientras se espera una respuesta
            onPressed: isLoading ? null : onSendMessage,
          ),
        ],
      ),
    );
  }
}
