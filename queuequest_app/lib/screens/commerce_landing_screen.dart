import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:queuequest_app/services/queue_service.dart';

class CommerceLandingScreen extends StatelessWidget {
  const CommerceLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final comercioId = ModalRoute.of(context)!.settings.arguments as String;
    final queueService = QueueService();

    final colaStream = queueService.listenCola(comercioId);

    Future<void> pedirNumero() async {
      final info = await queueService.requestTicket(comercioId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('comercioId', info['comercioId']!);
      await prefs.setString('ticketId', info['ticketId']!);

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/ticket');
      }
    }

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: colaStream,
          builder: (context, snapshot) {
            final data = snapshot.data?.data();
            final nombreLocal = data?['nombreLocal'] ?? 'Este comercio';
            final descripcionLocal =
                data?['descripcionLocal'] ?? 'Pide tu número y sigue tu turno desde aquí.';

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // cabecera igual que Home
                  Card(
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Q',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'QueueQuest',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Convierte la espera en experiencia',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Estás en',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              nombreLocal,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              descripcionLocal,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                onPressed: pedirNumero,
                                child: const Text(
                                  'Pedir número',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 48,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                onPressed: () =>
                                    Navigator.pop(context), // volver o login comercio
                                child: const Text('Volver'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
