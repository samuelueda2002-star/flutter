import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/propriedade_controller.dart';

class PropriedadesView extends StatefulWidget {
  const PropriedadesView({super.key});

  @override
  State<PropriedadesView> createState() => _PropriedadesViewState();
}

class _PropriedadesViewState extends State<PropriedadesView> {
  // Instanciação do controlador do Firestore refatorado
  final PropriedadeFirestoreController _propriedadeController = PropriedadeFirestoreController();

  // Controladores de formulário para capturar e validar as inserções de dados
  final _nomeController = TextEditingController();
  final _areaController = TextEditingController();
  final _localizacaoController = TextEditingController();
  final _tipoSoloController = TextEditingController();
  final _statusController = TextEditingController();

  @override
  void dispose() {
    // Elimina os controladores para evitar vazamentos de memória (Memory Leak)
    _nomeController.dispose();
    _areaController.dispose();
    _localizacaoController.dispose();
    _tipoSoloController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  /// RF003: Diálogo interativo para preenchimento, validação e inserção de novas propriedades
  void _abrirDialogoCadastro() {
    _nomeController.clear();
    _areaController.clear();
    _localizacaoController.clear();
    _tipoSoloController.clear();
    _statusController.text = 'Ativa';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nova Propriedade Rural"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome da Fazenda/Sítio')),
              TextField(controller: _areaController, decoration: const InputDecoration(labelText: 'Área Total (Hectares)'), keyboardType: TextInputType.number),
              TextField(controller: _localizacaoController, decoration: const InputDecoration(labelText: 'Localização/Município')),
              TextField(controller: _tipoSoloController, decoration: const InputDecoration(labelText: 'Tipo de Solo (Ex: Argiloso)')),
              TextField(controller: _statusController, decoration: const InputDecoration(labelText: 'Status da Propriedade')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (_nomeController.text.isEmpty || _areaController.text.isEmpty ||
                  _localizacaoController.text.isEmpty || _tipoSoloController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preencha todos os campos obrigatórios.')),
                );
                return;
              }

              Navigator.pop(context); // Fecha o modal de inserção

              // Processa a inserção tipada via controlador assíncrono
              String? erro = await _propriedadeController.adicionarPropriedade(
                nome: _nomeController.text.trim(),
                area: double.tryParse(_areaController.text.trim()) ?? 0.0,
                localizacao: _localizacaoController.text.trim(),
                tipoSolo: _tipoSoloController.text.trim(),
                status: _statusController.text.trim(),
              );

              if (!mounted) return;

              // RF003: Emissão de mensagem clara de confirmação (Sucesso ou Falha)
              if (erro == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Propriedade inserida com sucesso no Firestore!'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro na inserção: $erro'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Inserir"),
          ),
        ],
      ),
    );
  }

  /// RF004: Diálogo para atualização de informações com indicação clara do motivo de eventuais erros
  void _abrirDialogoEdicao(String docId, String nomeAtual, double areaAtual) {
    final editarNomeController = TextEditingController(text: nomeAtual);
    final editarAreaController = TextEditingController(text: areaAtual.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Propriedade"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: editarNomeController, decoration: const InputDecoration(labelText: 'Nome da Propriedade')),
            TextField(controller: editarAreaController, decoration: const InputDecoration(labelText: 'Área (Hectares)'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (editarNomeController.text.isEmpty || editarAreaController.text.isEmpty) return;

              Navigator.pop(context); // Fecha o modal de edição

              // Dispara a mutação de dados para o Firestore
              String? erro = await _propriedadeController.atualizarPropriedadeDados(docId, {
                'nome': editarNomeController.text.trim(),
                'area': double.tryParse(editarAreaController.text.trim()) ?? 0.0,
              });

              if (!mounted) return;

              // RF004: Fornece feedback adequado indicando o exato motivo da falha
              if (erro == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Propriedade atualizada com sucesso!'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Falha ao atualizar: $erro'), 
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            },
            child: const Text("Atualizar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A747C);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Minhas Propriedades"), 
        backgroundColor: primaryColor, 
        foregroundColor: Colors.white
      ),
      body: StreamBuilder<QuerySnapshot>(
        // RF003: Integração reativa e segura protegendo o acesso aos dados do utilizador
        stream: _propriedadeController.listarPropriedadesDoUsuario(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar propriedades: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final documentos = snapshot.data?.docs ?? [];

          if (documentos.isEmpty) {
            return const Center(child: Text('Nenhuma propriedade rural cadastrada no momento.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, 
              crossAxisSpacing: 12, 
              mainAxisSpacing: 12,
              childAspectRatio: 0.85
            ),
            itemCount: documentos.length,
            itemBuilder: (context, index) {
              final Map<String, dynamic> dados = documentos[index].data() as Map<String, dynamic>;
              final String docId = documentos[index].id;

              final String nome = dados['nome'] ?? 'Sem Nome';
              final double area = (dados['area'] ?? 0.0).toDouble();
              final String localizacao = dados['localizacao'] ?? 'Não informada';

              return Card(
                color: primaryColor.withOpacity(0.05),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.landscape, size: 40, color: primaryColor),
                      const SizedBox(height: 8),
                      Text(
                        nome, 
                        textAlign: TextAlign.center, 
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                      ),
                      Text("$area ha", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      Text(localizacao, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20, color: Colors.orange),
                        tooltip: 'Editar Propriedade',
                        onPressed: () => _abrirDialogoEdicao(docId, nome, area), // Ativação do RF004
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirDialogoCadastro, // Ativação do RF003
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}