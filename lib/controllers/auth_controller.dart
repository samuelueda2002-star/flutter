import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> login(String email, String senha) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(), 
        password: senha.trim()
      );
      return null; 
    } on FirebaseAuthException catch (e) {
      return _traduzirErro(e.code);
    } catch (e) {
      return "Erro desconhecido ao fazer login.";
    }
  }

  Future<String?> registrar({
    required String nome,
    required String telefone,
    required String email,
    required String senha,
  }) async {
    try {
      UserCredential credencial = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha.trim(),
      );

      await _firestore.collection('usuarios').doc(credencial.user!.uid).set({
        'nome': nome.trim(),
        'telefone': telefone.trim(),
        'email': email.trim(),
        'criadoEm': FieldValue.serverTimestamp(),
      });

      return null; 
    } on FirebaseAuthException catch (e) {
      return _traduzirErro(e.code);
    } catch (e) {
      return "Erro ao registrar usuário.";
    }
  }

  Future<String?> recuperarSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _traduzirErro(e.code);
    }
  }

  Future<void> sair() async {
    await _auth.signOut();
  }

  String _traduzirErro(String codigo) {
    switch (codigo) {
      case 'user-not-found': return 'Usuário não encontrado.';
      case 'wrong-password': return 'Senha incorreta.';
      case 'invalid-email': return 'Formato de e-mail inválido.';
      case 'email-already-in-use': return 'Este e-mail já está cadastrado.';
      case 'weak-password': return 'A senha deve ter pelo menos 6 caracteres.';
      case 'invalid-credential': return 'Credenciais inválidas.';
      default: return 'Ocorreu um erro: $codigo';
    }
  }
}