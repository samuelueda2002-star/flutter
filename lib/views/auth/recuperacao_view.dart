import 'package:flutter/material.dart';

class RecuperacaoView extends StatefulWidget {
  const RecuperacaoView({super.key});

  @override
  State<RecuperacaoView> createState() => _RecuperacaoViewState();
}

class _RecuperacaoViewState extends State<RecuperacaoView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  void _recuperarSenha() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Sucesso"),
          content: Text("Instruções enviadas para ${_emailController.text}"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recuperar Senha")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text("Informe seu e-mail cadastrado para receber as instruções de recuperação."),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()),
                validator: (v) => (v == null || !v.contains('@')) ? 'E-mail inválido' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _recuperarSenha,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A747C), foregroundColor: Colors.white),
                  child: const Text("Enviar E-mail"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}