import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';

class RecuperacaoView extends StatefulWidget {
  const RecuperacaoView({super.key});

  @override
  State<RecuperacaoView> createState() => _RecuperacaoViewState();
}

class _RecuperacaoViewState extends State<RecuperacaoView> {
  final _emailController = TextEditingController();
  final AuthController _authController = AuthController();
  bool _isLoading = false;

  void _enviarRecuperacao() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe seu e-mail.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    String? erro = await _authController.recuperarSenha(_emailController.text);
    setState(() => _isLoading = false);

    if (erro == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail de recuperação enviado! Verifique sua caixa de entrada.'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Senha')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Informe seu e-mail para enviarmos um link de redefinição de senha.', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'E-mail'), keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 24),
            _isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _enviarRecuperacao,
                  child: const Text('Enviar E-mail'),
                ),
          ],
        ),
      ),
    );
  }
}