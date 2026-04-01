import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final Color cor;

  const CustomButton({
    super.key,
    required this.texto,
    required this.onPressed,
    this.cor = const Color(0xFF0A747C),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: cor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(texto, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}