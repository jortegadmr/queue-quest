import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QueueService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User> ensureAnonymousUser() async {
    final current = _auth.currentUser;
    if (current != null) return current;

    final cred = await _auth.signInAnonymously();
    return cred.user!;
  }

  Future<Map<String, String>> requestTicket(String comercioId) async {
    final user = await ensureAnonymousUser();

    final colaRef = _firestore.collection('colas').doc(comercioId);
    final colaSnap = await colaRef.get();

    if (!colaSnap.exists) {
      throw Exception('La cola no existe.');
    }

    final datosCola = colaSnap.data() as Map<String, dynamic>;
    final numeroActual = (datosCola['numeroActual'] ?? 0) as int;
    final tiempoMedio = (datosCola['tiempoMedioMinutos'] ?? 4) as int;

    final nuevoNumero = numeroActual + 1;

    final turnosRef = colaRef.collection('turnos');
    final nuevoTurnoRef = await turnosRef.add({
      'numero': nuevoNumero,
      'estado': 'en_cola',
      'creadoEn': FieldValue.serverTimestamp(),
      'eta': 0,
      'posicion': 0,
      'uid': user.uid,
    });

    final q = await turnosRef.where('estado', isEqualTo: 'en_cola').get();
    int personasDelante = 0;

    for (final docSnap in q.docs) {
      final t = docSnap.data();
      final num = (t['numero'] ?? 0) as int;
      if (num < nuevoNumero) {
        personasDelante++;
      }
    }

    final eta = personasDelante * tiempoMedio;

    await nuevoTurnoRef.update({
      'posicion': personasDelante,
      'eta': eta,
    });

    await colaRef.update({
      'numeroActual': nuevoNumero,
    });

    return {
      'comercioId': comercioId,
      'ticketId': nuevoTurnoRef.id,
    };
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> listenCola(String comercioId) {
    return _firestore.collection('colas').doc(comercioId).snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> listenTicket(
    String comercioId,
    String ticketId,
  ) {
    return _firestore
        .collection('colas')
        .doc(comercioId)
        .collection('turnos')
        .doc(ticketId)
        .snapshots();
  }
}
