import 'package:flutter/material.dart';
import '../../controllers/propriedade_controller.dart';

class CadastroPropriedadeView extends StatefulWidget {
  const CadastroPropriedadeView({super.key});

  @override
  State<CadastroPropriedadeView> createState() => _CadastroPropriedadeViewState();
}

class _CadastroPropriedadeViewState extends State<CadastroPropriedadeView> {
  final _nomeController = TextEditingController();
  final _areaController = TextEditingController();
  final _localizacaoController = TextEditingController();
  final _tipoSoloController = TextEditingController();
  final _statusController = TextEditingController(text: 'Ativa');

  final PropriedadeFirestoreController _propriedadeController = PropriedadeFirestoreController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _areaController.dispose();
    _localizacaoController.dispose();
    _tipoSoloController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  void _salvarPropriedade() async {
    if (_nomeController.text.trim().isEmpty || 
        _areaController.text.trim().isEmpty || 
        _localizacaoController.text.trim().isEmpty || 
        _tipoSoloController.text.trim().isEmpty || 
        _statusController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos obrigatórios.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? erro = await _propriedadeController.adicionarPropriedade(
      nome: _nomeController.text.trim(),
      area: double.tryParse(_areaController.text.trim()) ?? 0.0,
      localizacao: _localizacaoController.text.trim(),
      tipoSolo: _tipoSoloController.text.trim(),
      status: _statusController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);


    if (erro == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Propriedade rural registada com sucesso!'), 
          backgroundColor: Colors.green
        ),
      );
      Navigator.pop(context); 
    } else {
    
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao registar propriedade: $erro'), 
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A747C);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Propriedade Rural'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nomeController, 
              decoration: const InputDecoration(labelText: 'Nome da Fazenda / Sítio', border: OutlineInputBorder())
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _areaController, 
              decoration: const InputDecoration(labelText: 'Área Total em Hectares', border: OutlineInputBorder()), 
              keyboardType: TextInputType.number
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _localizacaoController, 
              decoration: const InputDecoration(labelText: 'Localização / Município', border: OutlineInputBorder())
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _tipoSoloController, 
              decoration: const InputDecoration(labelText: 'Tipo de Solo (ex: Argiloso, Arenoso)', border: OutlineInputBorder())
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _statusController, 
              decoration: const InputDecoration(labelText: 'Status Atual da Propriedade', border: OutlineInputBorder())
            ),
            const SizedBox(height: 28),
            _isLoading 
                ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor))
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _salvarPropriedade,
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                      child: const Text(
                        'Registar Propriedade', 
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}