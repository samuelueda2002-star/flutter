import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/propriedade_controller.dart';

class PropriedadesView extends StatefulWidget {
  const PropriedadesView({super.key});

  @override
  State<PropriedadesView> createState() => _PropriedadesViewState();
}

class _PropriedadesViewState extends State<PropriedadesView> {
  final PropriedadeFirestoreController _propriedadeController = PropriedadeFirestoreController();

  final _nomeController = TextEditingController();
  final _areaController = TextEditingController();
  final _localizacaoController = TextEditingController();
  final _tipoSoloController = TextEditingController();
  final _statusController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _areaController.dispose();
    _localizacaoController.dispose();
    _tipoSoloController.dispose();
    _statusController.dispose();
    super.dispose();
  }

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
              TextField(controller: _tipoSoloController, decoration: const InputDecoration(labelText: 'Tipo de Solo (ex: Argiloso)')),
              TextField(controller: _statusController, decoration: const InputDecoration(labelText: 'Status (ex: Ativa, Inativa)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (_nomeController.text.trim().isEmpty || _areaController.text.trim().isEmpty ||
                  _localizacaoController.text.trim().isEmpty || _tipoSoloController.text.trim().isEmpty ||
                  _statusController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, preencha todos os campos obrigatórios.')),
                );
                return;
              }

              Navigator.pop(context); 

              String? erro = await _propriedadeController.adicionarPropriedade(
                nome: _nomeController.text.trim(),
                area: double.tryParse(_areaController.text.trim()) ?? 0.0,
                localizacao: _localizacaoController.text.trim(),
                tipoSolo: _tipoSoloController.text.trim(),
                status: _statusController.text.trim(),
              );

              if (!mounted) return;

              if (erro == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Propriedade registada com sucesso no Firestore!'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao salvar propriedade: $erro'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

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
              if (editarNomeController.text.trim().isEmpty || editarAreaController.text.trim().isEmpty) return;

              Navigator.pop(context); 

              String? erro = await _propriedadeController.atualizarPropriedadeDados(docId, {
                'nome': editarNomeController.text.trim(),
                'area': double.tryParse(editarAreaController.text.trim()) ?? 0.0,
              });

              if (!mounted) return;

              if (erro == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Propriedade atualizada com sucesso!'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Não foi possível modificar o registo: $erro'), 
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
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _propriedadeController.listarPropriedadesDoUsuario(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Erro ao carregar dados: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final documentos = snapshot.data?.docs ?? [];
          if (documentos.isEmpty) return const Center(child: Text('Nenhuma propriedade rural cadastrada.'));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: documentos.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final doc = documentos[index];
              final Map<String, dynamic> dados = doc.data() as Map<String, dynamic>;
              final String docId = doc.id;

              final String nome = dados['nome'] ?? 'Sem Nome';
              final double area = (dados['area'] ?? 0.0).toDouble();
              final String localizacao = dados['localizacao'] ?? 'Não informada';
              final String tipoSolo = dados['tipoSolo'] ?? 'Não informado';
              final String status = dados['status'] ?? 'Ativa';

              return Card(
                elevation: 1.5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE0F2F1),
                    child: Icon(Icons.landscape, color: primaryColor),
                  ),
                  title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "Localização: $localizacao • Área: $area ha\nSolo: $tipoSolo • Status: $status",
                      style: const TextStyle(height: 1.3, fontSize: 13),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange, size: 22),
                    tooltip: 'Editar Propriedade',
                    onPressed: () => _abrirDialogoEdicao(docId, nome, area), 
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirDialogoCadastro, // Gatilho RF003
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}