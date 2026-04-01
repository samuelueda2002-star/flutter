import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  void _tentarLogin() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              const Icon(Icons.agriculture, size: 100, color: Color(0xFF0A747C)),
              const Text(
                "Gestão Rural",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0A747C)),
              ),
              const SizedBox(height: 40),
              
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe o e-mail';
                  if (!value.contains('@')) return 'E-mail inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe a senha';
                  if (value.length < 6) return 'A senha deve ter no mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _tentarLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A747C),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Entrar", style: TextStyle(fontSize: 18)),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/cadastro'),
                    child: const Text("Criar Conta"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/recuperar'),
                    child: const Text("Esqueceu a senha?"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}