import 'package:flutter/material.dart';

class InsumoController extends ChangeNotifier {
  final List<Map<String, dynamic>> _estoque = [
    {'nome': 'Fertilizante NPK', 'quantidade': 500, 'unidade': 'kg'},
    {'nome': 'Semente Milho Híbrido', 'quantidade': 40, 'unidade': 'sacas'},
  ];

  List<Map<String, dynamic>> get estoque => _estoque;

  void baixarEstoque(int index, int quantidade) {
    if (_estoque[index]['quantidade'] >= quantidade) {
      _estoque[index]['quantidade'] -= quantidade;
      notifyListeners();
    }
  }
}