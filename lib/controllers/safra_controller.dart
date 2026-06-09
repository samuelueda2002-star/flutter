import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SafrasFirestoreController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// RF003: Inserção de dados eficiente no Firebase Firestore.
  /// Composta por mais de 5 campos tipados apropriadamente.
  /// Retorna 'null' se for bem-sucedido ou a String com o motivo do erro se falhar.
  Future<String?> adicionarSafra({
    required String talhao,
    required String cultura,
    required String status,
    required double area,
    required String observacoes,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return 'Usuário não autenticado no sistema.';

      String uid = user.uid; 
      
      // Armazenamento estruturado de 7 campos com tipos apropriados
      await _firestore.collection('safras').add({
        'userId': uid,               // Campo 1: Identificador de Segurança
        'talhao': talhao,             // Campo 2: String
        'cultura': cultura,           // Campo 3: String
        'status': status,             // Campo 4: String
        'area': area,                 // Campo 5: Double (Numérico apropriado)
        'observacoes': observacoes,   // Campo 6: String
        'dataCriacao': FieldValue.serverTimestamp(), // Campo 7: Timestamp do servidor
      });
      return null; // Retornar nulo significa sucesso total
    } on FirebaseException catch (e) {
      // RF003/RF004: Captura o código e o motivo exato enviado pelo servidor Firebase
      return 'Erro no banco de dados [${e.code}]: ${e.message}';
    } catch (e) {
      return 'Erro inesperado: ${e.toString()}';
    }
  }

  /// RF004: Atualização de informações com tratamento e feedback contextual de erro.
  Future<String?> atualizarSafra(String docId, Map<String, dynamic> dadosAtualizados) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return 'Sessão expirada. Por favor, autentique-se novamente.';

      await _firestore.collection('safras').doc(docId).update({
        ...dadosAtualizados,
        'ultimaModificacao': FieldValue.serverTimestamp(),
      });
      return null; // Sucesso na atualização
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return 'Acesso negado: Você não tem permissão para modificar esta safra.';
      }
      return 'Falha ao atualizar registro [${e.code}]: ${e.message}';
    } catch (e) {
      return 'Erro inesperado ao atualizar: ${e.toString()}';
    }
  }

  /// RF003: Integração segura garantindo que apenas o usuário autorizado acesse seus dados.
  Stream<QuerySnapshot> listarSafrasDoUsuario() {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('Nenhum usuário autenticado encontrado.');
    }
    String uid = user.uid;
    
    // Filtro de isolamento de segurança reativado e corrigido usando a sintaxe nativa 'isEqualTo'
    return _firestore
        .collection('safras')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }
}