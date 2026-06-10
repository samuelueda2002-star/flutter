import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InsumoFirestoreController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> adicionarInsumo({
    required String nome,
    required double quantidade,
    required String unidade,
    required String categoria,
    required String fornecedor,
  }) async {
    try {
      final String? uid = _auth.currentUser?.uid;
      if (uid == null) return 'Utilizador não autenticado.';

      await _firestore.collection('insumos').add({
        'userId': uid,
        'nome': nome,
        'quantidade': quantidade,
        'unidade': unidade,
        'categoria': categoria,
        'fornecedor': fornecedor,
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> atualizarEstoqueInsumo(String docId, double novaQuantidade) async {
    try {
      if (novaQuantidade < 0) return 'A quantidade não pode assumir valor negativo.';

      await _firestore.collection('insumos').doc(docId).update({
        'quantidade': novaQuantidade,
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
      return null;
    } on FirebaseException catch (e) {
      return 'Erro no Firestore [${e.code}]: ${e.message}';
    } catch (e) {
      return e.toString();
    }
  }

  Stream<QuerySnapshot> listarInsumosDoUsuario() {
    final String uid = _auth.currentUser?.uid ?? '';
    return _firestore
        .collection('insumos')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }
}