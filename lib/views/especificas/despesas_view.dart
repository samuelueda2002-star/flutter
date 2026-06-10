import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/despesa_controller.dart';

class DespesasView extends StatefulWidget {
  const DespesasView({super.key});

  @override
  State<DespesasView> createState() => _DespesasViewState();
}

class _DespesasViewState extends State<DespesasView> {
  final DespesasFirestoreController _despesaController = DespesasFirestoreController();

  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _dataGastoController = TextEditingController();
  final _formaPagamentoController = TextEditingController();

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _categoriaController.dispose();
    _dataGastoController.dispose();
    _formaPagamentoController.dispose();
    super.dispose();
  }

  void _abrirDialogoCadastro() {
    _descricaoController.clear();
    _valorController.clear();
    _categoriaController.clear();
    _dataGastoController.clear();
    _formaPagamentoController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Registrar Nova Despesa"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _descricaoController, decoration: const InputDecoration(labelText: 'Descrição da Despesa')),
              TextField(controller: _valorController, decoration: const InputDecoration(labelText: 'Valor (R\$)'), keyboardType: TextInputType.number),
              TextField(controller: _categoriaController, decoration: const InputDecoration(labelText: 'Categoria (Ex: Combustível, Sementes)')),
              TextField(controller: _dataGastoController, decoration: const InputDecoration(labelText: 'Data do Gasto (Ex: 15/05/2026)')),
              TextField(controller: _formaPagamentoController, decoration: const InputDecoration(labelText: 'Forma de Pagamento')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (_descricaoController.text.isEmpty || _valorController.text.isEmpty ||
                  _categoriaController.text.isEmpty || _dataGastoController.text.isEmpty ||
                  _formaPagamentoController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preencha todos os campos obrigatórios.')),
                );
                return;
              }

              Navigator.pop(context); // Fecha o modal de inserção

              String? erro = await _despesaController.adicionarDespesa(
                descricao: _descricaoController.text.trim(),
                valor: double.tryParse(_valorController.text.trim()) ?? 0.0,
                categoria: _categoriaController.text.trim(),
                dataGasto: _dataGastoController.text.trim(),
                formaPagamento: _formaPagamentoController.text.trim(),
              );

              if (!mounted) return;

              if (erro == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Despesa lançada com sucesso no Firestore!'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro na inserção: $erro'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  void _abrirDialogoEdicao(String docId, String descricaoAtual, double valorAtual) {
    final editarDescricaoController = TextEditingController(text: descricaoAtual);
    final editarValorController = TextEditingController(text: valorAtual.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Lançamento"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: editarDescricaoController, decoration: const InputDecoration(labelText: 'Descrição')),
            TextField(controller: editarValorController, decoration: const InputDecoration(labelText: 'Valor (R\$)'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (editarDescricaoController.text.isEmpty || editarValorController.text.isEmpty) return;

              Navigator.pop(context); // Fecha o modal de edição

              String? erro = await _despesaController.atualizarDespesaDados(docId, {
                'descricao': editarDescricaoController.text.trim(),
                'valor': double.tryParse(editarValorController.text.trim()) ?? 0.0,
              });

              if (!mounted) return;

              if (erro == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Despesa atualizada com sucesso!'), backgroundColor: Colors.green),
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
        title: const Text("Controle de Despesas"), 
        backgroundColor: primaryColor, 
        foregroundColor: Colors.white
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _despesaController.listarDespesasDoUsuario(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar despesas: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final documentos = snapshot.data?.docs ?? [];

          if (documentos.isEmpty) {
            return const Center(child: Text('Nenhuma despesa registrada para o ciclo atual.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: documentos.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final Map<String, dynamic> dados = documentos[index].data() as Map<String, dynamic>;
              final String docId = documentos[index].id;

              final String descricao = dados['descricao'] ?? 'Sem Descrição';
              final double valor = (dados['valor'] ?? 0.0).toDouble();
              final String categoria = dados['categoria'] ?? 'Geral';
              final String dataGasto = dados['dataGasto'] ?? '';

              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.red,
                  child: Icon(Icons.money_off, color: Colors.red),
                ),
                title: Text(
                  descricao,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text("Categoria: $categoria • Data: $dataGasto"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "R\$ ${valor.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Colors.red, 
                        fontSize: 16
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      tooltip: 'Editar Lançamento',
                      onPressed: () => _abrirDialogoEdicao(docId, descricao, valor), 
                    ),
                  ],
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