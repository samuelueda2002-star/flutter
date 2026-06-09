import 'package:flutter/material.dart';
import '../../controllers/safra_controller.dart';

class CadastroSafraView extends StatefulWidget {
  const CadastroSafraView({super.key});

  @override
  State<CadastroSafraView> createState() => _CadastroSafraViewState();
}

class _CadastroSafraViewState extends State<CadastroSafraView> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para capturar e gerenciar os dados inseridos
  final _talhaoController = TextEditingController();
  final _areaController = TextEditingController();
  final _observacoesController = TextEditingController();
  
  String? _culturaSelecionada = 'Soja';
  String _statusSelecionado = 'Planejado';
  
  // Instanciação correta do controlador do Firestore
  final SafrasFirestoreController _safraController = SafrasFirestoreController();
  bool _isLoading = false;

  @override
  void dispose() {
    // Libera a memória eliminando os controladores ao fechar a View
    _talhaoController.dispose();
    _areaController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  void _salvarSafra() async {
    // Validação nativa do formulário antes de submeter os dados
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    // Conexão assíncrona com o controlador passando dados validados e tipados
    String? erro = await _safraController.adicionarSafra(
      talhao: _talhaoController.text.trim(),
      cultura: _culturaSelecionada ?? 'Outra',
      status: _statusSelecionado,
      area: double.tryParse(_areaController.text.trim()) ?? 0.0,
      observacoes: _observacoesController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    // RF003: Exibição de mensagens informativas de confirmação (Sucesso ou Falha)
    if (erro == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Safra inserida com sucesso no banco de dados!'), 
          backgroundColor: Colors.green
        ),
      );
      Navigator.pop(context); // Retorna de forma segura à tela anterior
    } else {
      // RF004: Fornece o feedback adequado indicando o exato motivo da falha
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha na inserção: $erro'), 
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Novo Plantio")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _talhaoController,
                decoration: const InputDecoration(labelText: 'Nome do Talhão', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira a identificação do talhão.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _culturaSelecionada,
                items: const [
                  DropdownMenuItem(value: 'Soja', child: Text('Soja')), 
                  DropdownMenuItem(value: 'Milho', child: Text('Milho')),
                  DropdownMenuItem(value: 'Trigo', child: Text('Trigo')),
                ],
                onChanged: (val) {
                  setState(() {
                    _culturaSelecionada = val;
                  });
                },
                decoration: const InputDecoration(labelText: 'Cultura', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(labelText: 'Área (Hectares)', border: OutlineInputBorder()), 
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, digite a área do plantio.';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Insira um valor numérico válido e maior que zero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _statusSelecionado,
                items: const [
                  DropdownMenuItem(value: 'Planejado', child: Text('Planejado')), 
                  DropdownMenuItem(value: 'Plantado', child: Text('Plantado')),
                  DropdownMenuItem(value: 'Em Colheita', child: Text('Em Colheita')),
                ],
                onChanged: (val) {
                  setState(() {
                    _statusSelecionado = val ?? 'Planejado';
                  });
                },
                decoration: const InputDecoration(labelText: 'Status do Plantio', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _observacoesController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Observações Adicionais', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 25),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _salvarSafra,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A747C), 
                        minimumSize: const Size(double.infinity, 50)
                      ),
                      child: const Text("Salvar Safra", style: TextStyle(color: Colors.white, fontSize: 16)),
                    )
            ],
          ),
        ),
      ),
    );
  }
}