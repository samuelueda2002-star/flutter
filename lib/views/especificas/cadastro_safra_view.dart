import 'package:flutter/material.dart';
import '../../controllers/safra_controller.dart';

class CadastroSafraView extends StatefulWidget {
  const CadastroSafraView({super.key});

  @override
  State<CadastroSafraView> createState() => _CadastroSafraViewState();
}

class _CadastroSafraViewState extends State<CadastroSafraView> {
  final _talhaoController = TextEditingController();
  final _culturaController = TextEditingController();
  final _areaController = TextEditingController();
  final _statusController = TextEditingController();
  final _dataPlantioController = TextEditingController();
  
  final SafraController _safraController = SafraController();
  bool _isLoading = false;

  void _salvarSafra() async {
    // Validação para não enviar campos vazios
    if (_talhaoController.text.isEmpty || _culturaController.text.isEmpty || 
        _areaController.text.isEmpty || _statusController.text.isEmpty || 
        _dataPlantioController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Chama o controlador para salvar no Firebase
    String? erro = await _safraController.adicionarSafra(
      talhao: _talhaoController.text.trim(),
      cultura: _culturaController.text.trim(),
      area: double.tryParse(_areaController.text.trim()) ?? 0.0,
      status: _statusController.text.trim(),
      dataPlantio: _dataPlantioController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    // RF003: Exibe mensagem de confirmação (Sucesso ou Falha)
    if (erro == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Safra inserida com sucesso no banco de dados!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Volta para a tela principal
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Safra')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _talhaoController, decoration: const InputDecoration(labelText: 'Identificação do Talhão (ex: T01)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _culturaController, decoration: const InputDecoration(labelText: 'Cultura (ex: Soja, Milho)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _areaController, decoration: const InputDecoration(labelText: 'Área em Hectares', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: _statusController, decoration: const InputDecoration(labelText: 'Status (ex: Plantado, Em Colheita)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _dataPlantioController, decoration: const InputDecoration(labelText: 'Data de Plantio', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            _isLoading 
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _salvarSafra,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Inserir Safra', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}