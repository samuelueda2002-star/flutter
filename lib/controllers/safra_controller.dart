import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SafraController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> adicionarSafra({
    required String talhao,
    required String cultura,
    required double area,
    required String status,
    required String dataPlantio,
  }) async {
    try {
      // Garante a separação por usuário capturando o ID de quem está logado (RF003)
      String uid = _auth.currentUser!.uid;

      // Inserção na coleção "safras" com 6 campos (Atende a exigência de ter pelo menos 5)
      await _firestore.collection('safras').add({
        'userId': uid, // Vincula o documento exclusivamente a este usuário
        'talhao': talhao,
        'cultura': cultura,
        'area': area,
        'status': status,
        'dataPlantio': dataPlantio,
        'criadoEm': FieldValue.serverTimestamp(),
      });
      return null; // Sucesso
    } catch (e) {
      return 'Falha ao inserir safra: $e'; // Retorna o erro
    }
  }
}