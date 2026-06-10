import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SafrasFirestoreController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> adicionarSafra({
    required String talhao,
    required String cultura,
    required double area,
    required String status,
    required String dataPlantio,
    String observacoes = '',
  }) async {
    try {
      final String? uid = _auth.currentUser?.uid;
      if (uid == null) return 'Utilizador não autenticado no sistema.';

      await _firestore.collection('safras').add({
        'userId': uid,             
        'talhao': talhao,           
        'cultura': cultura,         
        'area': area,                
        'status': status,             
        'dataPlantio': dataPlantio,  
        'observacoes': observacoes,   
        'dataCriacao': FieldValue.serverTimestamp(), 
      });
      return null; 
    } on FirebaseException catch (e) {
      return 'Erro no banco de dados [${e.code}]: ${e.message}';
    } catch (e) {
      return 'Erro inesperado: ${e.toString()}';
    }
  }

  Future<String?> atualizarSafra(String docId, Map<String, dynamic> dadosAtualizados) async {
    try {
      final String? uid = _auth.currentUser?.uid;
      if (uid == null) return 'Sessão expirada. Por favor, volte a autenticar-se.';

      await _firestore.collection('safras').doc(docId).update({
        ...dadosAtualizados,
        'ultimaModificacao': FieldValue.serverTimestamp(),
      });
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return 'Acesso negado: Não tem permissão para alterar este registo.';
      }
      return 'Falha ao sincronizar as alterações [${e.code}]: ${e.message}';
    } catch (e) {
      return 'Erro inesperado: ${e.toString()}';
    }
  }

  Stream<QuerySnapshot> listarSafrasDoUsuario() {
    final String uid = _auth.currentUser?.uid ?? '';
    return _firestore
        .collection('safras')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }
}