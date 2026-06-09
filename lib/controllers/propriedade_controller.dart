import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PropriedadeController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> adicionarPropriedade({
    required String nome,
    required String cidade,
    required String estado,
    required double tamanhoHectares,
    required String tipoSolo,
  }) async {
    try {
      // Obtém o usuário logado para manter o banco de dados separado (RF003)
      String uid = _auth.currentUser!.uid;

      // Inserção na coleção "propriedades" com 6 campos
      await _firestore.collection('propriedades').add({
        'userId': uid, // Vincula o documento exclusivamente a este usuário
        'nome': nome,
        'cidade': cidade,
        'estado': estado,
        'tamanhoHectares': tamanhoHectares,
        'tipoSolo': tipoSolo,
        'criadoEm': FieldValue.serverTimestamp(),
      });
      return null; // Sucesso
    } catch (e) {
      return 'Falha ao inserir propriedade: $e';
    }
  }
}