import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DespesasFirestoreController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> adicionarDespesa({
    required String descricao,
    required double valor,
    required String categoria,
    required String dataGasto,
    required String formaPagamento,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return 'Utilizador não autenticado no sistema.';

      String uid = user.uid;

      await _firestore.collection('despesas').add({
        'userId': uid,              
        'descricao': descricao,     
        'valor': valor,              
        'categoria': categoria,      
        'dataGasto': dataGasto,       
        'formaPagamento': formaPagamento, 
        'dataCriacao': FieldValue.serverTimestamp(), 
      });
      return null; 
    } on FirebaseException catch (e) {
      return 'Erro no Firestore [${e.code}]: ${e.message}';
    } catch (e) {
      return 'Erro inesperado: ${e.toString()}';
    }
  }

  Future<String?> atualizarDespesaDados(String docId, Map<String, dynamic> dadosAtualizados) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return 'Sessão expirada. Por favor, faça login novamente.';

      if (dadosAtualizados.containsKey('valor') && dadosAtualizados['valor'] < 0) {
        return 'Erro de validação: O valor da despesa não pode ser negativo.';
      }

      await _firestore.collection('despesas').doc(docId).update({
        ...dadosAtualizados,
        'ultimaModificacao': FieldValue.serverTimestamp(),
      });
      return null; 
    } on FirebaseException catch (e) {

      if (e.code == 'permission-denied') {
        return 'Acesso Negado: Não tem autorização para modificar esta despesa.';
      }
      return 'Falha na atualização [${e.code}]: ${e.message}';
    } catch (e) {
      return 'Erro inesperado ao modificar: ${e.toString()}';
    }
  }

  Stream<QuerySnapshot> listarDespesasDoUsuario() {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('Utilizador não autenticado.');
    }
    String uid = user.uid;

    return _firestore
        .collection('despesas')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }
}