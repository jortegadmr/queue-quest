import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  String? _comercioId;
  bool _loading = true;
  List<Map<String, dynamic>> _ofertas = [];

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    final prefs = await SharedPreferences.getInstance();
    final colaId = prefs.getString('comercioId');

    if (colaId == null) {
      setState(() {
        _loading = false;
        _ofertas = [];
      });
      return;
    }

    final colaRef =
        FirebaseFirestore.instance.collection('colas').doc(colaId);
    final ofertasRef = colaRef.collection('ofertas');

    final snapshot = await ofertasRef.get();

    final ofertas = <Map<String, dynamic>>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data['activo'] == false) continue;

      ofertas.add({
        'id': doc.id,
        ...data,
      });
    }

    // orden: primero por 'orden', luego por 'titulo'
    ofertas.sort((a, b) {
      final ordA = (a['orden'] ?? 999) as int;
      final ordB = (b['orden'] ?? 999) as int;
      if (ordA != ordB) return ordA - ordB;
      return (a['titulo'] ?? '').toString().compareTo(
            (b['titulo'] ?? '').toString(),
          );
    });

    setState(() {
      _comercioId = colaId;
      _ofertas = ofertas;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ofertas del día'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _ofertas.isEmpty
                ? const Center(
                    child: Text(
                      'Hoy no hay ofertas activas en este local.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                : ListView.separated(
                    itemCount: _ofertas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final oferta = _ofertas[index];
                      final titulo = oferta['titulo'] ?? 'Oferta';
                      final descripcion = oferta['descripcion'] ?? '';
                      final precioAntes = oferta['precioAntes'];
                      final precioAhora = oferta['precioAhora'];

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                titulo.toString(),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if ((descripcion as String).isNotEmpty)
                                Text(
                                  descripcion,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              if (precioAntes != null && precioAhora != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${(precioAntes as num).toStringAsFixed(2)} €',
                                        style: const TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${(precioAhora as num).toStringAsFixed(2)} €',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
