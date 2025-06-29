import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat.dart';
import 'sidebar_drawer.dart'; // Asegúrate de tener este archivo creado

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    return Scaffold(
      drawer: SidebarDrawer(
        onItemSelected: (index) {
          // Aquí podrías manejar la navegación si es necesario
          // index 0 = Inicio, index 1 = Mis conversaciones, index 2 = Perfil
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Mis conversaciones'),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('chats')
                .doc(uid)
                .collection('conversaciones')
                .orderBy('timestamp', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final conversaciones = snapshot.data!.docs;

          return ListView.builder(
            itemCount: conversaciones.length,
            itemBuilder: (context, index) {
              final doc = conversaciones[index];
              return ListTile(
                title: Text(
                  doc['last_message'] ?? 'Sin mensaje',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  (doc['timestamp'] as Timestamp?)?.toDate().toString() ?? '',
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(conversationId: doc.id),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            title: const Text('¿Eliminar conversación?'),
                            content: const Text(
                              'Esta acción no se puede deshacer.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                    );

                    if (confirm == true) {
                      final conversationRef = FirebaseFirestore.instance
                          .collection('chats')
                          .doc(uid)
                          .collection('conversaciones')
                          .doc(doc.id);

                      final mensajes =
                          await conversationRef.collection('mensajes').get();
                      for (var m in mensajes.docs) {
                        await m.reference.delete();
                      }
                      await conversationRef.delete();
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onPressed: () async {
          // Crear nueva conversación
          final newDoc = await FirebaseFirestore.instance
              .collection('chats')
              .doc(uid)
              .collection('conversaciones')
              .add({
                'last_message': 'Hola, soy Estud-IA. ¿Qué necesitas saber hoy?',
                'timestamp': FieldValue.serverTimestamp(),
              });

          // Insertar primer mensaje en la subcolección 'mensajes'
          await newDoc.collection('mensajes').add({
            'rol': 'ia',
            'texto': 'Hola, soy Estud-IA. ¿Qué necesitas saber hoy?',
            'timestamp': FieldValue.serverTimestamp(),
          });

          // Navegar a la pantalla de chat
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(conversationId: newDoc.id),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
