import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  bool _estaLogado = false;
  bool get estaLogado => _estaLogado;

 
  Future<bool> login(String email, String senha) async {
    
    if (email.isNotEmpty && senha.length >= 6) {
      _estaLogado = true;
      notifyListeners(); 
      return true;
    }
    return false;
  }

  
  Future<void> recuperarSenha(String email) async {
  
    await Future.delayed(const Duration(seconds: 1));
    print("E-mail de recuperação enviado para $email");
  }

  void logout() {
    _estaLogado = false;
    notifyListeners();
  }
}