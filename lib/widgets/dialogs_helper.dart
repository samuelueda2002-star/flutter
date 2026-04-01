import 'package:flutter/material.dart';

class DialogsHelper {
  static void showSnackBar(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: const Color(0xFF0A747C),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showAlert(BuildContext context, String titulo, String mensagem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Color(0xFF0A747C))),
          ),
        ],
      ),
    );
  }
}