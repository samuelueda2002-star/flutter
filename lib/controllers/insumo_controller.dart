import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InsumoFirestoreController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// RF003: Inserção de dados eficiente e tipada no Firebase Firestore.
  /// Composta por pelo menos 5 campos estruturados com tipos apropriados.
  /// Retorna 'null' se a inserção for um sucesso ou uma String com o motivo do erro se falhar.
  Future<String?> adicionarInsumo({
    required String nome,
    required double quantidade,
    required String unidade,
    required String categoria,
    required String fornecedor,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return 'Usuário não autenticado no sistema.';

      String uid = user.uid;

      // Armazenamento de 7 campos estruturados (Garante integridade e consistência)
      await _firestore.collection('insumos').add({
        'userId': uid,               // Campo 1: Identificador de Segurança (Isolamento)
        'nome': nome,                 // Campo 2: String
        'quantidade': quantidade,     // Campo 3: Double (Tipo numérico apropriado)
        'unidade': unidade,           // Campo 4: String (kg, sacas, litros)
        'categoria': categoria,       // Campo 5: String (Fertilizante, Semente)
        'fornecedor': fornecedor,     // Campo 6: String
        'ultimaAtualizacao': FieldValue.serverTimestamp(), // Campo 7: Timestamp nativo do servidor
      });
      return null; // Retorno nulo indica sucesso total na operação
    } on FirebaseException catch (e) {
      // Captura o erro específico lançado pelas regras do Firestore
      return 'Erro no banco de dados [${e.code}]: ${e.message}';
    } catch (e) {
      return 'Erro inesperado ao salvar: ${e.toString()}';
    }
  }

  /// RF004: Atualização de informações no Firestore (Segunda coleção do sistema)
  /// Fornece o feedback adequado indicando o motivo da falha.
  Future<String?> atualizarQuantidadeInsumo(String docId, double novaQuantidade) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return 'Sessão expirada. reconecte-se ao sistema.';
      if (novaQuantidade < 0) return 'Validação local: A quantidade em estoque não pode ser negativa.';

      // Executa a atualização focada no documento correspondente
      await _firestore.collection('insumos').doc(docId).update({
        'quantidade': novaQuantidade,
        'ultimaAtualizacao': FieldValue.serverTimestamp(),
      });
      return null; // Sucesso na mutação
    } on FirebaseException catch (e) {
      // RF004: Trata o motivo específico enviado pelo Firebase (Ex: Sem internet, Permissão negada)
      if (e.code == 'permission-denied') {
        return 'Acesso negado: Você não tem permissão para alterar este insumo.';
      }
      return 'Falha na sincronização do estoque [${e.code}]: ${e.message}';
    } catch (e) {
      return 'Erro inesperado ao atualizar: ${e.toString()}';
    }
  }

  /// RF003: Integração de leitura eficiente e segura.
  /// Retorna em tempo real apenas os registros pertencentes ao usuário autenticado.
  Stream<QuerySnapshot> listarInsumosDoUsuario() {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('Nenhum usuário autenticado encontrado.');
    }
    String uid = user.uid;

    // Filtro de isolamento imperativo para garantir que um produtor não acesse insumos de outro
    return _firestore
        .collection('insumos')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }
}