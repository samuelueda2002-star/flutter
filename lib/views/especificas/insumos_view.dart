import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/insumo_controller.dart';

class InsumosView extends StatefulWidget {
  const InsumosView({super.key});

  @override
  State<InsumosView> createState() => _InsumosViewState();
}

class _InsumosViewState extends State<InsumosView> {
  final InsumoFirestoreController _insumoController = InsumoFirestoreController();

  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _unidadeController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _fornecedorController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    _unidadeController.dispose();
    _categoriaController.dispose();
    _fornecedorController.dispose();
    super.dispose();
  }

  void _abrirDialogoCadastro() {
    _nomeController.clear();
    _quantidadeController.clear();
    _unidadeController.clear();
    _categoriaController.clear();
    _fornecedorController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Novo Insumo"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome do Insumo')),
              TextField(controller: _quantidadeController, decoration: const InputDecoration(labelText: 'Quantidade Inicial'), keyboardType: TextInputType.number),
              TextField(controller: _unidadeController, decoration: const InputDecoration(labelText: 'Unidade (ex: kg, sacas)')),
              TextField(controller: _categoriaController, decoration: const InputDecoration(labelText: 'Categoria')),
              TextField(controller: _fornecedorController, decoration: const InputDecoration(labelText: 'Fornecedor')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (_nomeController.text.isEmpty || _quantidadeController.text.isEmpty || _unidadeController.text.isEmpty) return;

              Navigator.pop(context);
              String? erro = await _insumoController.adicionarInsumo(
                nome: _nomeController.text.trim(),
                quantidade: double.tryParse(_quantidadeController.text.trim()) ?? 0.0,
                unidade: _unidadeController.text.trim(),
                categoria: _categoriaController.text.trim(),
                fornecedor: _fornecedorController.text.trim(),
              );

              if (!mounted) return;
              if (erro == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Insumo adicionado com sucesso!'), backgroundColor: Colors.green));
              }
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  void _abrirDialogoAtualizacao(String docId, String nome, double qtdAtual) {
    final editarQtdController = TextEditingController(text: qtdAtual.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Editar Estoque: $nome"),
        content: TextField(controller: editarQtdController, decoration: const InputDecoration(labelText: 'Nova Quantidade'), keyboardType: TextInputType.number),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              double? novaQtd = double.tryParse(editarQtdController.text.trim());
              if (novaQtd == null) return;

              Navigator.pop(context);
              String? erro = await _insumoController.atualizarEstoqueInsumo(docId, novaQtd);
              
              if (!mounted) return;
              if (erro == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estoque atualizado!'), backgroundColor: Colors.green));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $erro'), backgroundColor: Colors.red));
              }
            },
            child: const Text("Atualizar"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Estoque de Insumos")),
      body: StreamBuilder<QuerySnapshot>(
        // RF005: Segunda coleção a utilizar StreamBuilder + ListView de forma isolada e síncrona
        stream: _insumoController.listarInsumosDoUsuario(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Erro: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text('Nenhum insumo em estoque.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String id = docs[index].id;

              final String nome = data['nome'] ?? '';
              final double qtd = (data['quantidade'] ?? 0.0).toDouble();
              final String unidade = data['unidade'] ?? '';

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.inventory_2, color: Colors.blueGrey),
                  title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Categoria: ${data['categoria'] ?? 'Geral'}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("$qtd $unidade", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _abrirDialogoAtualizacao(id, nome, qtd),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirDialogoCadastro,
        child: const Icon(Icons.add),
      ),
    );
  }
}