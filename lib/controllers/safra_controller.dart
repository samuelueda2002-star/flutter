import 'package:flutter/material.dart';

class SafraController extends ChangeNotifier {
  
  final List<Map<String, String>> _safras = [
    {'talhao': 'Talhão 01', 'cultura': 'Soja', 'status': 'Em Crescimento'},
    {'talhao': 'Talhão 05', 'cultura': 'Milho', 'status': 'Pronto para Colheita'},
  ];

  List<Map<String, String>> get safras => _safras;

  void cadastrarSafra(String talhao, String cultura) {
    _safras.add({
      'talhao': talhao,
      'cultura': cultura,
      'status': 'Planejado',
    });
    notifyListeners(); 
  }
}