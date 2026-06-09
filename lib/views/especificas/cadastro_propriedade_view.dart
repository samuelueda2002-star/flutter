import 'package:flutter/material.dart';
import '../../controllers/propriedade_controller.dart';

class CadastroPropriedadeView extends StatefulWidget {
  const CadastroPropriedadeView({super.key});

  @override
  State<CadastroPropriedadeView> createState() => _CadastroPropriedadeViewState();
}

class _CadastroPropriedadeViewState extends State<CadastroPropriedadeView> {
  final _nomeController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _tamanhoController = TextEditingController();
  final _tipoSoloController = TextEditingController();
  
  final PropriedadeController _propriedadeController = PropriedadeController();
  bool _isLoading = false;

  void _salvarPropriedade() async {
    if (_nomeController.text.isEmpty || _cidadeController.text.isEmpty || 
        _estadoController.text.isEmpty || _tamanhoController.text.isEmpty || 
        _tipoSoloController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? erro = await _propriedadeController.adicionarPropriedade(
      nome: _nomeController.text.trim(),
      cidade: _cidadeController.text.trim(),
      estado: _estadoController.text.trim(),
      tamanhoHectares: double.tryParse(_tamanhoController.text.trim()) ?? 0.0,
      tipoSolo: _tipoSoloController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    // RF003: Exibe mensagem de confirmação (Sucesso ou Falha)
    if (erro == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Propriedade inserida com sucesso no banco de dados!'), backgroundColor: Colors.green),
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
      appBar: AppBar(title: const Text('Nova Propriedade')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome da Fazenda', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _cidadeController, decoration: const InputDecoration(labelText: 'Cidade', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _estadoController, decoration: const InputDecoration(labelText: 'Estado (ex: SP)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _tamanhoController, decoration: const InputDecoration(labelText: 'Tamanho (Hectares)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: _tipoSoloController, decoration: const InputDecoration(labelText: 'Tipo de Solo (ex: Argiloso)', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            _isLoading 
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _salvarPropriedade,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Inserir Propriedade', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}