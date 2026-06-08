import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _carregando = false;

  bool get carregando => _carregando;

  Future<String?> login(String email, String senha) async {
    _carregando = true;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
      _carregando = false;
      notifyListeners();
      return null; 
    } on FirebaseAuthException catch (e) {
      _carregando = false;
      notifyListeners();
      return e.message; 
    }
  }

  Future<String?> registrar(String nome, String email, String telefone, String senha) async {
    _carregando = true;
    notifyListeners();
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: senha);
      
      
      await _firestore.collection('usuarios').doc(credential.user!.uid).set({
        'nome': nome,
        'email': email,
        'telefone': telefone,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _carregando = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _carregando = false;
      notifyListeners();
      return e.message;
    }
  }

  Future<String?> recuperarSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}