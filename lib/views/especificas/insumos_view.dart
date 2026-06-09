import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/insumo_controller.dart';

class InsumosView extends StatefulWidget {
  const InsumosView({super.key});

  @override
  State<InsumosView> createState() => _InsumosViewState();
}

class _InsumosViewState extends State<InsumosView> {
  // Instanciação do controlador refatorado para o Firestore
  final InsumoFirestoreController _insumoController = InsumoFirestoreController();

  // Controladores de texto para capturar os 5 campos no formulário de inserção
  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _unidadeController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _fornecedorController = TextEditingController();

  @override
  void dispose() {
    // Descarta os controladores para prevenir vazamento de memória (Memory Leak)
    _nomeController.dispose();
    _quantidadeController.dispose();
    _unidadeController.dispose();
    _categoriaController.dispose();
    _fornecedorController.dispose();
    super.dispose();
  }

  /// RF003: Caixa de diálogo contendo o formulário para inserção e validação
  void _abrirDialogoCadastro() {
    _nomeController.clear();
    _quantidadeController.clear();
    _unidadeController.clear();
    _categoriaController.clear();
    _fornecedorController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cadastrar Novo Insumo"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nomeController, decoration: const InputDecoration(labelText: 'Nome do Insumo (Ex: NPK)')),
              TextField(controller: _quantidadeController, decoration: const InputDecoration(labelText: 'Quantidade Inicial'), keyboardType: TextInputType.number),
              TextField(controller: _unidadeController, decoration: const InputDecoration(labelText: 'Unidade de Medida (Ex: kg, saca)')),
              TextField(controller: _categoriaController, decoration: const InputDecoration(labelText: 'Categoria (Ex: Fertilizante)')),
              TextField(controller: _fornecedorController, decoration: const InputDecoration(labelText: 'Fornecedor Coletado')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (_nomeController.text.isEmpty || _quantidadeController.text.isEmpty ||
                  _unidadeController.text.isEmpty || _categoriaController.text.isEmpty ||
                  _fornecedorController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, preencha todos os campos obrigatórios.')),
                );
                return;
              }

              Navigator.pop(context); // Fecha a janela do formulário

              // Executa a inserção no banco Firestore
              String? erro = await _insumoController.adicionarInsumo(
                nome: _nomeController.text.trim(),
                quantidade: double.tryParse(_quantidadeController.text.trim()) ?? 0.0,
                unidade: _unidadeController.text.trim(),
                categoria: _categoriaController.text.trim(),
                fornecedor: _fornecedorController.text.trim(),
              );

              if (!mounted) return;

              // RF003: Emite feedback visual imediato e claro de confirmação ao usuário
              if (erro == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Insumo registrado com sucesso no Firestore!'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao salvar insumo: $erro'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  /// RF004: Caixa de diálogo para alteração de dados com exposição clara do motivo de falhas
  void _abrirDialogoAtualizacao(String docId, String nomeInsumo, double quantidadeAtual) {
    final editarQuantidadeController = TextEditingController(text: quantidadeAtual.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Ajustar Estoque: $nomeInsumo"),
        content: TextField(
          controller: editarQuantidadeController,
          decoration: const InputDecoration(labelText: 'Quantidade em Estoque Atualizada'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              double? novaQtd = double.tryParse(editarQuantidadeController.text.trim());
              if (novaQtd == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, insira um valor numérico válido.')),
                );
                return;
              }

              Navigator.pop(context); // Fecha a janela de edição

              // Invoca o método de atualização do controlador
              String? erro = await _insumoController.atualizarQuantidadeInsumo(docId, novaQtd);

              if (!mounted) return;

              // RF004: Feedback adequado indicando o exato motivo da falha se houver
              if (erro == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Estoque atualizado com sucesso!'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Não foi possível atualizar: $erro'), 
                    backgroundColor: Colors.red, 
                    duration: const Duration(seconds: 5)
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
    return Scaffold(
      appBar: AppBar(title: const Text("Estoque de Insumos")),
      body: StreamBuilder<QuerySnapshot>(
        // RF003: Consumo reativo e seguro direto da stream filtrada do banco de dados
        stream: _insumoController.listarInsumosDoUsuario(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro crítico ao ler banco de dados: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final listagemDocs = snapshot.data?.docs ?? [];

          if (listagemDocs.isEmpty) {
            return const Center(child: Text('Nenhum insumo localizado em seu estoque físico.'));
          }

          return ListView.separated(
            itemCount: listagemDocs.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final Map<String, dynamic> dados = listagemDocs[index].data() as Map<String, dynamic>;
              final String docId = listagemDocs[index].id;

              final String nome = dados['nome'] ?? 'Insumo Indefinido';
              final double quantidade = (dados['quantidade'] ?? 0.0).toDouble();
              final String unidade = dados['unidade'] ?? '';
              final String categoria = dados['categoria'] ?? 'Geral';

              return ListTile(
                leading: const Icon(Icons.inventory_2, color: Color(0xFF0A747C)),
                title: Text(nome),
                subtitle: Text("Categoria: $categoria"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "$quantidade $unidade",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      tooltip: 'Editar Estoque',
                      onPressed: () => _abrirDialogoAtualizacao(docId, nome, quantidade), // Gatilho do RF004
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirDialogoCadastro, // Gatilho do RF003
        backgroundColor: const Color(0xFF0A747C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}