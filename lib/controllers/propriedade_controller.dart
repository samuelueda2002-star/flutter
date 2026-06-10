import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PropriedadeFirestoreController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> adicionarPropriedade({
    required String nome,
    required double area,
    required String localizacao,
    required String tipoSolo,
    required String status,
  }) async {
    try {
      final String? uid = _auth.currentUser?.uid;
      if (uid == null) return 'Utilizador não autenticado no sistema.';

      await _firestore.collection('propriedades').add({
        'userId': uid,              
        'nome': nome,               
        'area': area,                 
        'localizacao': localizacao,   
        'tipoSolo': tipoSolo,        
        'status': status,           
        'dataCadastro': FieldValue.serverTimestamp(), 
      });
      return null; 
    } on FirebaseException catch (e) {
      return 'Erro no banco de dados [${e.code}]: ${e.message}';
    } catch (e) {
      return 'Erro inesperado: ${e.toString()}';
    }
  }

  Future<String?> atualizarPropriedadeDados(String docId, Map<String, dynamic> dadosAtualizados) async {
    try {
      final String? uid = _auth.currentUser?.uid;
      if (uid == null) return 'Sessão expirada. Por favor, volte a autenticar-se.';

      await _firestore.collection('propriedades').doc(docId).update({
        ...dadosAtualizados,
        'ultimaModificacao': FieldValue.serverTimestamp(),
      });
      return null; 
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return 'Acesso negado: Não tem permissão para alterar esta propriedade.';
      }
      return 'Falha ao sincronizar as alterações [${e.code}]: ${e.message}';
    } catch (e) {
      return 'Erro inesperado ao atualizar: ${e.toString()}';
    }
  }

  Stream<QuerySnapshot> listarPropriedadesDoUsuario() {
    final String uid = _auth.currentUser?.uid ?? '';
    
    return _firestore
        .collection('propriedades')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }
}