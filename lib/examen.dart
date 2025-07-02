import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'detalle_examen.dart'; // Asegúrate de tener este archivo

class ExamenView extends StatelessWidget {
  const ExamenView({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("Usuario no autenticado")),
      );
    }

    final examenesStream =
        FirebaseFirestore.instance
            .collection('chats')
            .doc(uid)
            .collection('conversaciones')
            .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Exámenes'),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: const Color(0xFFF8F0F8), // fondo lila claro
      body: StreamBuilder<QuerySnapshot>(
        stream: examenesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final conversacionId = docs[i].id;

              return StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('chats')
                        .doc(uid)
                        .collection('conversaciones')
                        .doc(conversacionId)
                        .collection('mensajes')
                        .where('rol', isEqualTo: 'ia-examen')
                        .orderBy('timestamp')
                        .snapshots(),
                builder: (context, examSnapshot) {
                  if (!examSnapshot.hasData ||
                      examSnapshot.data!.docs.isEmpty) {
                    return const SizedBox();
                  }

                  final examenes = examSnapshot.data!.docs;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        examenes.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final texto = data['texto'] ?? '';
                          final timestamp = data['timestamp']?.toDate();

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => DetalleExamenView(
                                        texto: texto,
                                        timestamp: timestamp,
                                      ),
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              color: Colors.white,
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "📘 Examen generado:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      texto.length > 150
                                          ? '${texto.substring(0, 150)}...'
                                          : texto,
                                      maxLines: 5,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (timestamp != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Text(
                                          "Generado el: ${timestamp.toString()}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
