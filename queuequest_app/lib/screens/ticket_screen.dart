import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/queue_service.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final _queueService = QueueService();
  String? _comercioId;
  String? _ticketId;
  bool _loadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _comercioId = prefs.getString('comercioId');
      _ticketId = prefs.getString('ticketId');
      _loadingPrefs = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingPrefs) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_comercioId == null || _ticketId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tu turno')),
        body: const Center(
          child: Text('No hay ningún turno activo en este dispositivo.'),
        ),
      );
    }

    final colaStream = _queueService.listenCola(_comercioId!);
    final ticketStream = _queueService.listenTicket(_comercioId!, _ticketId!);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: colaStream,
            // StreamBuilder de la cola
            builder: (context, colaSnapshot) {
              final colaData = colaSnapshot.data?.data();
              final nombreLocal = colaData?['nombreLocal'] ?? 'QueueQuest';
              final tiempoMedio = (colaData?['tiempoMedioMinutos'] ?? 2) as int;

              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: ticketStream,
                builder: (context, ticketSnapshot) {
                  final ticketData = ticketSnapshot.data?.data();

                  // Mientras carga el ticket, podemos enseñar un loader sencillo
                  if (ticketSnapshot.connectionState ==
                          ConnectionState.waiting &&
                      ticketData == null) {
                    return Column(
                      children: [
                        _buildHeader(nombreLocal),
                        const Expanded(
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ],
                    );
                  }

                  // Si el turno se ha borrado o aún no existe
                  if (ticketData == null) {
                    return Column(
                      children: [
                        _buildHeader(nombreLocal),
                        const Expanded(
                          child: Center(
                            child: Text('No se ha encontrado tu turno.'),
                          ),
                        ),
                      ],
                    );
                  }

                  // A PARTIR DE AQUÍ YA PODEMOS USAR ticketData
                  final miNumero = (ticketData['numero'] ?? 0) as int;
                  final estado = ticketData['estado'] ?? 'en_cola';

                  // Datos pre-calculados por la lógica de la web
                  final personasDelante = (ticketData['posicion'] ?? 0) as int;
                  final etaMinutos =
                      (ticketData['eta'] ?? (personasDelante * tiempoMedio))
                          as int;

                  return Column(
                    children: [
                      _buildHeader(nombreLocal),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // Tarjeta principal "Tu número"
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF22C55E),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            estado == 'llamado'
                                                ? 'Turno llamado'
                                                : 'Turno activo',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'TU NÚMERO',
                                        style: TextStyle(
                                          fontSize: 13,
                                          letterSpacing: 1.2,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        miNumero.toString().padLeft(3, '0'),
                                        style: const TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _InfoChip(
                                              label: 'PERSONAS DELANTE',
                                              value: personasDelante.toString(),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _InfoChip(
                                              label: 'TIEMPO ESTIMADO',
                                              value: '~ $etaMinutos min',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Tarjeta "Mientras esperas..."
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: const [
                                      Text(
                                        'Mientras esperas...',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Completa pequeñas misiones o descubre las ofertas del día sin perder tu turno.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Botones QueueQuest / Ofertas
                              Row(
                                children: [
                                  Expanded(
                                    child: Card(
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(24),
                                        onTap: () {
                                          // TODO: Navigator.pushNamed(context, '/missions');
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: const [
                                              Text(
                                                'QueueQuest',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Misiones rápidas para hacer la espera más llevadera.',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Card(
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(24),
                                        onTap: () {
                                          // TODO: Navigator.pushNamed(context, '/offers');
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: const [
                                              Text(
                                                'Ofertas del día',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Descuentos y sugerencias sólo por estar en la cola.',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String nombreLocal) {
    return Card(
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombreLocal,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Convierte la espera en experiencia',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.1,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
