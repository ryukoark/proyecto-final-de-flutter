import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> guardarMensajeFirestore({
  required String conversationId,
  required String texto,
  required String rol, // "usuario" o "ia"
}) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  final mensajesRef = FirebaseFirestore.instance
      .collection('chats')
      .doc(uid)
      .collection('conversaciones')
      .doc(conversationId)
      .collection('mensajes');

  // Guarda el mensaje en la subcolección
  await mensajesRef.add({
    'texto': texto,
    'rol': rol,
    'timestamp': FieldValue.serverTimestamp(),
  });

  // Actualiza el último mensaje en la conversación principal
  await FirebaseFirestore.instance
      .collection('chats')
      .doc(uid)
      .collection('conversaciones')
      .doc(conversationId)
      .set({
        'last_message': texto,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
}
