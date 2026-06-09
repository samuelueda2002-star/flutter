import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../home/home_view.dart';

class CadastroView extends StatefulWidget {
  const CadastroView({super.key});

  @override
  State<CadastroView> createState() => _CadastroViewState();
}

class _CadastroViewState extends State<CadastroView> {
  // Controladores dos campos de texto
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  final AuthController _authController = AuthController();
  bool _isLoading = false;

  // Função auxiliar para exibir mensagens de erro na interface
  void _exibirMensagem(String mensagem, {bool ehErro = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: ehErro ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Executa todas as validações locais antes de enviar ao Firebase
  bool _validarFormulario() {
  final nome = _nomeController.text.trim();
  final email = _emailController.text.trim();
  final telefone = _telefoneController.text.trim();
  final senha = _senhaController.text;
  final confirmarSenha = _confirmarSenhaController.text;

  if (nome.isEmpty || email.isEmpty || telefone.isEmpty || senha.isEmpty) {
    _exibirMensagem('Todos os campos são obrigatórios.');
    return false;
  }

  // Validação de E-mail
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(email)) {
    _exibirMensagem('Por favor, insira um e-mail válido.');
    return false;
  }

  // REFAZENDO A VALIDAÇÃO DA SENHA SEGUNDO OS CRITÉRIOS DO REQUISITO:
  // Exige: Mínimo 6 caracteres, 1 Letra Maiúscula, 1 Minúscula, 1 Número e 1 Caractere Especial (@$!%*?&)
  final senhaRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$');
  
  if (!senhaRegex.hasMatch(senha)) {
    _exibirMensagem(
      'Senha fraca! A senha deve conter no mínimo 6 caracteres, incluindo letras maiúsculas, minúsculas, números e caracteres especiais.',
      ehErro: true
    );
    return false;
  }

  if (senha != confirmarSenha) {
    _exibirMensagem('As senhas não coincidem.');
    return false;
  }

  return true;
  }

  void _executarCadastro() async {
    if (!_validarFormulario()) return;

    setState(() => _isLoading = true);

    // Envia os dados para salvar no Firebase Auth e Firestore através do Controller
    String? erroFirebase = await _authController.registrar(
      nome: _nomeController.text.trim(),
      telefone: _telefoneController.text.trim(),
      email: _emailController.text.trim(),
      senha: _senhaController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (erroFirebase == null) {
      _exibirMensagem('Conta criada com sucesso!', ehErro: false);
      
      // Após o preenchimento correto e validação, permite o acesso imediato à Home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeView()),
        (route) => false,
      );
    } else {
      // Caso a validação do Firebase falhe (ex: e-mail já existente), exibe o erro retornado
      _exibirMensagem(erroFirebase);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_add_alt_1_outlined,
                size: 70,
                color: Colors.green,
              ),
              const SizedBox(height: 8),
              const Text(
                'Preencha seus dados para começar',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              
              // Campo: Nome do Usuário
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              
              // Campo: E-mail
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
              ),
              const SizedBox(height: 16),
              
              // Campo: Número de Telefone
              TextField(
                controller: _telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Número de Telefone',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                  hintText: '(00) 00000-0000',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              
              // Campo: Senha
              TextField(
                controller: _senhaController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              
              // Campo: Confirmação de Senha
              TextField(
                controller: _confirmarSenhaController,
                decoration: const InputDecoration(
                  labelText: 'Confirmação de Senha',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 32),
              
              // Botão de Confirmação com Feedback de Progresso
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.green)
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _executarCadastro,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Criar conta',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}