import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QueueService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  /// Asegura que el usuario está autenticado de forma anónima
  Future<User> ensureAnonymousUser() async {
    final current = _auth.currentUser;
    if (current != null) return current;

    final cred = await _auth.signInAnonymously();
    return cred.user!;
  }

  /// Crea un turno en la cola de un comercio
  Future<Map<String, String>> requestTicket(String comercioId) async {
    final user = await ensureAnonymousUser();

    final colaRef = _firestore.collection('colas').doc(comercioId);
    final turnosRef = colaRef.collection('turnos');

    final doc = await turnosRef.add({
      'uid': user.uid,
      'estado': 'en_cola',
      'timestamp': FieldValue.serverTimestamp(),
      // Aquí luego añadimos 'numero' según tu lógica de la web
    });

    return {
      'comercioId': comercioId,
      'ticketId': doc.id,
    };
  }

  /// Doc del comercio
  Stream<DocumentSnapshot<Map<String, dynamic>>> listenCola(
    String comercioId,
  ) {
    return _firestore.collection('colas').doc(comercioId).snapshots();
  }

  /// Doc del turno concreto
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
