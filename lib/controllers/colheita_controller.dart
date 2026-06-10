import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ColheitasFirestoreController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// RF003: Inserção de dados estruturada e eficiente no Cloud Firestore.
  /// Mapeia 7 campos preenchidos com tipos apropriados para consistência de dados.
  /// Retorna 'null' em caso de sucesso ou uma String amigável se houver falha.
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

      // Armazenamento estruturado de 7 campos para garantir integridade (RF003)
      await _firestore.collection('colheitas').add({
        'userId': uid,                     // Campo 1: Vínculo seguro de isolamento
        'talhao': talhao,                   // Campo 2: String
        'quantidadeColhida': quantidadeColhida, // Campo 3: Double (Numérico apropriado)
        'unidade': unidade,                 // Campo 4: String (Sacas, Toneladas, kg)
        'dataInicio': dataInicio,           // Campo 5: String
        'dataFim': dataFim,                 // Campo 6: String
        'destino': destino,                 // Campo 7: String (Silo, Cooperativa, Venda)
        'dataRegistro': FieldValue.serverTimestamp(), // Metadado nativo do banco
      });
      return null; // Sucesso total na inserção
    } on FirebaseException catch (e) {
      // Retorna o motivo estruturado gerado pelo servidor do Firebase
      return 'Erro no Firestore [${e.code}]: ${e.message}';
    } catch (e) {
      return 'Erro inesperado: ${e.toString()}';
    }
  }

  /// RF004: Atualização de informações no Firestore com feedback analítico do erro.
  Future<String?> atualizarColheitaDados(String docId, Map<String, dynamic> dadosAtualizados) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return 'Sessão expirada. Por favor, faça login novamente.';

      if (dadosAtualizados.containsKey('quantidadeColhida') && dadosAtualizados['quantidadeColhida'] < 0) {
        return 'Erro de validação: A quantidade colhida não pode ser menor que zero.';
      }

      // Executa a mutação no documento específico do Firestore
      await _firestore.collection('colheitas').doc(docId).update({
        ...dadosAtualizados,
        'ultimaModificacao': FieldValue.serverTimestamp(),
      });
      return null; // Sucesso na atualização
    } on FirebaseException catch (e) {
      // RF004: Captura o motivo específico da falha (Ex: sem permissão, documento inexistente)
      if (e.code == 'permission-denied') {
        return 'Acesso Negado: Não tem autorização para modificar este registro de colheita.';
      }
      return 'Falha na atualização [${e.code}]: ${e.message}';
    } catch (e) {
      return 'Erro inesperado ao modificar: ${e.toString()}';
    }
  }

  /// RF003: Leitura de dados reativa e totalmente segura.
  /// Retorna em tempo real apenas os registros pertencentes ao utilizador autenticado.
  Stream<QuerySnapshot> listarColheitasDoUsuario() {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('Utilizador não autenticado.');
    }
    String uid = user.uid;

    // Filtro de segurança obrigatório para isolamento e conformidade de privacidade
    return _firestore
        .collection('colheitas')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }
}