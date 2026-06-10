import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DespesasFirestoreController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// RF003: Inserção eficiente de despesas no Cloud Firestore.
  /// Mapeia 7 campos estruturados com tipos de dados consistentes.
  /// Retorna 'null' em caso de sucesso ou uma String explicativa se falhar.
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

      // Armazenamento estruturado de 7 campos para garantir integridade e consistência (RF003)
      await _firestore.collection('despesas').add({
        'userId': uid,               // Campo 1: Vínculo seguro de privacidade
        'descricao': descricao,       // Campo 2: String
        'valor': valor,               // Campo 3: Double (Numérico apropriado)
        'categoria': categoria,       // Campo 4: String (Sementes, Combustível, Manutenção)
        'dataGasto': dataGasto,       // Campo 5: String (Data do evento de gasto)
        'formaPagamento': formaPagamento, // Campo 6: String (Dinheiro, Cartão, Pix)
        'dataCriacao': FieldValue.serverTimestamp(), // Campo 7: Timestamp nativo do servidor
      });
      return null; // Sucesso absoluto na inserção
    } on FirebaseException catch (e) {
      // RF003/RF004: Retorna o motivo estruturado gerado pelo servidor do Firebase
      return 'Erro no Firestore [${e.code}]: ${e.message}';
    } catch (e) {
      return 'Erro inesperado: ${e.toString()}';
    }
  }

  /// RF004: Atualização de informações no Firestore com feedback analítico do motivo da falha.
  Future<String?> atualizarDespesaDados(String docId, Map<String, dynamic> dadosAtualizados) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return 'Sessão expirada. Por favor, faça login novamente.';

      if (dadosAtualizados.containsKey('valor') && dadosAtualizados['valor'] < 0) {
        return 'Erro de validação: O valor da despesa não pode ser negativo.';
      }

      // Atualiza de forma isolada o documento no banco de dados
      await _firestore.collection('despesas').doc(docId).update({
        ...dadosAtualizados,
        'ultimaModificacao': FieldValue.serverTimestamp(),
      });
      return null; // Sucesso na atualização
    } on FirebaseException catch (e) {
      // RF004: Captura o motivo específico da falha (Ex: sem permissão, documento inexistente)
      if (e.code == 'permission-denied') {
        return 'Acesso Negado: Não tem autorização para modificar esta despesa.';
      }
      return 'Falha na atualização [${e.code}]: ${e.message}';
    } catch (e) {
      return 'Erro inesperado ao modificar: ${e.toString()}';
    }
  }

  /// RF003: Integração de leitura reativa e segura.
  /// Retorna em tempo real apenas as despesas pertencentes ao utilizador autenticado.
  Stream<QuerySnapshot> listarDespesasDoUsuario() {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('Utilizador não autenticado.');
    }
    String uid = user.uid;

    // Filtro imperativo de segurança para garantir o isolamento estrito dos dados financeiros
    return _firestore
        .collection('despesas')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }
}