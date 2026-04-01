import 'package:flutter/material.dart';
import '../models/propriedade.dart';

class PropriedadeController extends ChangeNotifier {
  final List<Propriedade> _propriedades = [
    Propriedade(id: '1', nome: 'Fazenda Santa Luzia', area: 500.0),
    Propriedade(id: '2', nome: 'Sítio Novo Horizonte', area: 120.0),
  ];

  List<Propriedade> get propriedades => List.unmodifiable(_propriedades);

  void adicionarPropriedade(Propriedade p) {
    _propriedades.add(p);
    notifyListeners();
  }
}