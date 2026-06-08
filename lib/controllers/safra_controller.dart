import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SafrasFirestoreController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  
  Future<bool> adicionarSafra({
    required String talhao,
    required String cultura,
    required String status,
    required double area,
    required String observacoes,
  }) async {
    try {
      String uid = _auth.currentUser!.uid; 
      await _firestore.collection('safras').add({
        'userId': uid, // Campo de controle de dono
        'talhao': talhao,
        'cultura': cultura,
        'status': status,
        'area': area,
        'observacoes': observacoes,
        'dataCriacao': FieldValue.serverTimestamp(),
      });
      return true; 
    } catch (e) {
      return false; 
    }
  }

  
  Future<bool> atualizarSafra(String docId, Map<String, dynamic> dadosAtualizados) async {
    try {
      await _firestore.collection('safras').doc(docId).update(dadosAtualizados);
      return true;
    } catch (e) {
      return false; 
    }
  }

 Stream<QuerySnapshot> listarSafrasDoUsuario() {
    String uid = _auth.currentUser!.uid;
    return _firestore
        .collection('safras')
        .where('userId', ==: uid) // Filtro isolado
        .snapshots();
  }
}