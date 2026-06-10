import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ColheitasFirestoreController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> adicionarColheita({
    required String talhao,
    required double quantidadeColhida,
    required String unidade,
    required String dataInicio,
    required String dataFim,
    required String destino,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return 'Utilizador não autenticado no sistema.';

      String uid = user.uid;

      await _firestore.collection('colheitas').add({
        'userId': uid,                   
        'talhao': talhao,                   
        'quantidadeColhida': quantidadeColhida, 
        'unidade': unidade,                 
        'dataInicio': dataInicio,         
        'dataFim': dataFim,               
        'destino': destino,                 
        'dataRegistro': FieldValue.serverTimestamp(), 
      });
      return null; 
    } on FirebaseException catch (e) {
      return 'Erro no Firestore [${e.code}]: ${e.message}';
    } catch (e) {
      return 'Erro inesperado: ${e.toString()}';
    }
  }

  Future<String?> atualizarColheitaDados(String docId, Map<String, dynamic> dadosAtualizados) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return 'Sessão expirada. Por favor, faça login novamente.';

      if (dadosAtualizados.containsKey('quantidadeColhida') && dadosAtualizados['quantidadeColhida'] < 0) {
        return 'Erro de validação: A quantidade colhida não pode ser menor que zero.';
      }

      await _firestore.collection('colheitas').doc(docId).update({
        ...dadosAtualizados,
        'ultimaModificacao': FieldValue.serverTimestamp(),
      });
      return null; 
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return 'Acesso Negado: Não tem autorização para modificar este registro de colheita.';
      }
      return 'Falha na atualização [${e.code}]: ${e.message}';
    } catch (e) {
      return 'Erro inesperado ao modificar: ${e.toString()}';
    }
  }

  Stream<QuerySnapshot> listarColheitasDoUsuario() {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('Utilizador não autenticado.');
    }
    String uid = user.uid;

    return _firestore
        .collection('colheitas')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }
}