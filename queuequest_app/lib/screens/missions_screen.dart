import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _misiones = [];
  Set<String> _completadas = {};
  int _puntosTotales = 0;
  int _puntosCompletados = 0;

  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  Future<String?> _claveMisionesLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final colaId = prefs.getString('comercioId');
    final ticketId = prefs.getString('ticketId');
    if (colaId == null || ticketId == null) return null;
    return 'misiones_${colaId}_$ticketId';
  }

  Future<Set<String>> _cargarMisionesCompletadasLocal() async {
    final key = await _claveMisionesLocal();
    if (key == null) return {};
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return {};
    try {
      final List<dynamic> arr = List<dynamic>.from(
        (raw.isEmpty ? [] : (raw as dynamic)) as dynamic,
      );
      return arr.map((e) => e.toString()).toSet();
    } catch (_) {
      // si hay problemas con el parseo, empezamos de cero
      return {};
    }
  }

  Future<void> _guardarMisionesCompletadasLocal(
      Set<String> ids) async {
    final key = await _claveMisionesLocal();
    if (key == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, ids.toList().toString());
  }

  Future<void> _loadMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final colaId = prefs.getString('comercioId');
    if (colaId == null) {
      setState(() {
        _loading = false;
        _misiones = [];
      });
      return;
    }

    final colaRef =
        FirebaseFirestore.instance.collection('colas').doc(colaId);
    final misionesRef = colaRef.collection('misiones');
    final snapshot = await misionesRef.get();

    final misiones = <Map<String, dynamic>>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data['activa'] == false) continue;
      misiones.add({
        'id': doc.id,
        ...data,
      });
    }

    misiones.sort((a, b) {
      final ordA = (a['orden'] ?? 999) as int;
      final ordB = (b['orden'] ?? 999) as int;
      if (ordA != ordB) return ordA - ordB;
      return (a['titulo'] ?? '').toString().compareTo(
            (b['titulo'] ?? '').toString(),
          );
    });

    final completadas = await _cargarMisionesCompletadasLocal();

    int puntosTotales = 0;
    int puntosCompletados = 0;

    for (final m in misiones) {
      final pts = (m['puntos'] ?? 0) as int;
      puntosTotales += pts;
      if (completadas.contains(m['id'])) {
        puntosCompletados += pts;
      }
    }

    setState(() {
      _misiones = misiones;
      _completadas = completadas;
      _puntosTotales = puntosTotales;
      _puntosCompletados = puntosCompletados;
      _loading = false;
    });
  }

  Future<void> _toggleMision(String id, int puntos) async {
    final newSet = Set<String>.from(_completadas);
    if (newSet.contains(id)) {
      newSet.remove(id);
      _puntosCompletados -= puntos;
    } else {
      newSet.add(id);
      _puntosCompletados += puntos;
    }
    _completadas = newSet;
    await _guardarMisionesCompletadasLocal(newSet);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final porcentaje = _puntosTotales > 0
        ? (_puntosCompletados * 100 ~/ _puntosTotales)
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('QueueQuest'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_puntosTotales > 0) ...[
                    Text(
                      'Progreso: $_puntosCompletados / $_puntosTotales puntos ($porcentaje%) en esta espera.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value:
                            _puntosTotales > 0 ? porcentaje / 100.0 : 0.0,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Expanded(
                    child: _misiones.isEmpty
                        ? const Center(
                            child: Text(
                              'Este comercio aún no tiene misiones configuradas.',
                              style:
                                  TextStyle(color: Colors.black54),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _misiones.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final m = _misiones[index];
                              final id = m['id'] as String;
                              final titulo =
                                  m['titulo'] ?? 'Misión';
                              final descripcion =
                                  m['descripcion'] ?? '';
                              final puntos =
                                  (m['puntos'] ?? 0) as int;
                              final yaCompletada =
                                  _completadas.contains(id);

                              return Card(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Text(
                                            titulo.toString(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight:
                                                  FontWeight.w600,
                                            ),
                                          ),
                                          if (puntos > 0)
                                            Text(
                                              '$puntos pts',
                                              style:
                                                  const TextStyle(
                                                fontSize: 12,
                                                color:
                                                    Colors.black54,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      if ((descripcion as String)
                                          .isNotEmpty)
                                        Text(
                                          descripcion,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 36,
                                        child: ElevatedButton(
                                          style: ElevatedButton
                                              .styleFrom(
                                            backgroundColor:
                                                yaCompletada
                                                    ? const Color(
                                                        0xFFDCFCE7)
                                                    : null,
                                          ),
                                          onPressed: () =>
                                              _toggleMision(
                                                  id, puntos),
                                          child: Text(
                                            yaCompletada
                                                ? 'Completada'
                                                : 'Marcar como completada',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: yaCompletada
                                                  ? const Color(
                                                      0xFF15803D)
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
