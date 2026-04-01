import 'package:flutter/material.dart';

class CadastroView extends StatefulWidget {
  const CadastroView({super.key});

  @override
  State<CadastroView> createState() => _CadastroSafraViewState(); 
}

class _CadastroSafraViewState extends State<CadastroView> { 
  final _formKey = GlobalKey<FormState>();
  
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  void _realizarCadastro() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário cadastrado com sucesso!'), backgroundColor: Color(0xFF0A747C)),
      );
      Navigator.pop(context); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Criar Conta")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome Completo', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Informe seu nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || !v.contains('@')) ? 'E-mail inválido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(labelText: 'Telefone', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'Informe seu telefone' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder()),
                obscureText: true,
                validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmarSenhaController,
                decoration: const InputDecoration(labelText: 'Confirmar Senha', border: OutlineInputBorder()),
                obscureText: true,
                validator: (v) => v != _senhaController.text ? 'As senhas não coincidem' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _realizarCadastro,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A747C), foregroundColor: Colors.white),
                  child: const Text("Cadastrar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}