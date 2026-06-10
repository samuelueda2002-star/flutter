import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../home/home_view.dart';
import 'cadastro_view.dart';
import 'recuperacao_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final AuthController _authController = AuthController();
  bool _isLoading = false;

  void _fazerLogin() async {
    if (_emailController.text.isEmpty || _senhaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? erro = await _authController.login(
      _emailController.text,
      _senhaController.text,
    );

    setState(() => _isLoading = false);

    if (erro == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeView()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.agriculture,
              size: 90,
              color: Colors.green, // Cor verde para combinar com o tema
            ),
            const SizedBox(height: 12),
            const Text(
              'Agro App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 32),
            
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _senhaController,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            
            _isLoading 
              ? const CircularProgressIndicator()
              : SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _fazerLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'Entrar',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const RecuperacaoView())
              ),
              child: const Text('Esqueci minha senha'),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const CadastroView())
              ),
              child: const Text('Criar uma conta'),
            ),
          ],
        ),
      ),
    );
  }
}