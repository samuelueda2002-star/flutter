import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PropriedadeFirestoreController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// RF003: Inserção eficiente de dados no Cloud Firestore.
  /// Mapeia mais de 5 campos estruturados com tipos primitivos consistentes.
  /// Retorna 'null' em caso de sucesso ou uma String explicativa se falhar.
  Future<String?> adicionarPropriedade({
    required String nome,
    required double area,
    required String localizacao,
    required String tipoSolo,
    required String status,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return 'Utilizador não autenticado no sistema.';

      String uid = user.uid;

      // Armazenamento estruturado de 7 campos para garantir integridade (RF003)
      await _firestore.collection('propriedades').add({
        'userId': uid,               // Campo 1: Vínculo seguro de privacidade
        'nome': nome,                 // Campo 2: String
        'area': area,                 // Campo 3: Double (Numérico apropriado)
        'localizacao': localizacao,   // Campo 4: String
        'tipoSolo': tipoSolo,         // Campo 5: String
        'status': status,             // Campo 6: String (Ex: Ativa, Inativa)
        'dataCadastro': FieldValue.serverTimestamp(), // Campo 7: Timestamp nativo
      });
      return null; // Sucesso absoluto na inserção
    } on FirebaseException catch (e) {
      // Retorna o motivo estruturado gerado pelo servidor do Firebase
      return 'Erro no Firestore [${e.code}]: ${e.message}';
    } catch (e) {
      return 'Erro inesperado: ${e.toString()}';
    }
  }

  /// RF004: Atualização de informações no Firestore com feedback analítico do motivo da falha.
  Future<String?> atualizarPropriedadeDados(String docId, Map<String, dynamic> dadosAtualizados) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return 'Sessão expirada. Por favor, faça login novamente.';

      // Atualiza de forma isolada o documento no banco de dados
      await _firestore.collection('propriedades').doc(docId).update({
        ...dadosAtualizados,
        'ultimaModificacao': FieldValue.serverTimestamp(),
      });
      return null; // Sucesso na atualização
    } on FirebaseException catch (e) {
      // RF004: Captura o motivo específico da falha (Ex: sem permissão, documento inexistente)
      if (e.code == 'permission-denied') {
        return 'Acesso Negado: Não tem autorização para modificar esta propriedade.';
      }
      return 'Falha na atualização [${e.code}]: ${e.message}';
    } catch (e) {
      return 'Erro inesperado ao modificar: ${e.toString()}';
    }
  }

  /// RF003: Integração de leitura eficiente e segura.
  /// Retorna em tempo real apenas as propriedades pertencentes ao utilizador autenticado.
  Stream<QuerySnapshot> listarPropriedadesDoUsuario() {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('Utilizador não autenticado.');
    }
    String uid = user.uid;

    // Filtro imperativo de segurança para garantir a privacidade dos dados rurais
    return _firestore
        .collection('propriedades')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }
}