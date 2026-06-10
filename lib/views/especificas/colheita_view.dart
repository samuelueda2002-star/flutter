import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/colheita_controller.dart';

class ColheitaView extends StatefulWidget {
  const ColheitaView({super.key});

  @override
  State<ColheitaView> createState() => _ColheitaViewState();
}

class _ColheitaViewState extends State<ColheitaView> {
  // Instanciação do controlador do Firestore refatorado
  final ColheitasFirestoreController _colheitaController = ColheitasFirestoreController();

  // Controladores de formulário para capturar e validar as inserções de dados
  final _talhaoController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _unidadeController = TextEditingController();
  final _dataInicioController = TextEditingController();
  final _dataFimController = TextEditingController();
  final _destinoController = TextEditingController();

  @override
  void dispose() {
    // Elimina os controladores ao fechar a tela para evitar vazamentos de memória (Memory Leak)
    _talhaoController.dispose();
    _quantidadeController.dispose();
    _unidadeController.dispose();
    _dataInicioController.dispose();
    _dataFimController.dispose();
    _destinoController.dispose();
    super.dispose();
  }

  /// RF003: Diálogo contendo o formulário completo para inserção e validação
  void _abrirDialogoCadastro() {
    _talhaoController.clear();
    _quantidadeController.clear();
    _unidadeController.clear();
    _dataInicioController.clear();
    _dataFimController.clear();
    _destinoController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Registrar Nova Colheita"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _talhaoController, decoration: const InputDecoration(labelText: 'Identificação do Talhão (Ex: T02)')),
              TextField(controller: _quantidadeController, decoration: const InputDecoration(labelText: 'Quantidade Total Colhida'), keyboardType: TextInputType.number),
              TextField(controller: _unidadeController, decoration: const InputDecoration(labelText: 'Unidade (Ex: Sacas, Toneladas)')),
              TextField(controller: _dataInicioController, decoration: const InputDecoration(labelText: 'Data de Início (Ex: 01/06/2026)')),
              TextField(controller: _dataFimController, decoration: const InputDecoration(labelText: 'Data de Término (Ex: 05/06/2026)')),
              TextField(controller: _destinoController, decoration: const InputDecoration(labelText: 'Destino da Produção (Ex: Silo Sul)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (_talhaoController.text.isEmpty || _quantidadeController.text.isEmpty ||
                  _unidadeController.text.isEmpty || _dataInicioController.text.isEmpty ||
                  _dataFimController.text.isEmpty || _destinoController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, preencha todos os campos obrigatórios.')),
                );
                return;
              }

              Navigator.pop(context); // Fecha a janela do formulário

              // Executa a operação assíncrona gravando os dados reais no banco
              String? erro = await _colheitaController.adicionarColheita(
                talhao: _talhaoController.text.trim(),
                quantidadeColhida: double.tryParse(_quantidadeController.text.trim()) ?? 0.0,
                unidade: _unidadeController.text.trim(),
                dataInicio: _dataInicioController.text.trim(),
                dataFim: _dataFimController.text.trim(),
                destino: _destinoController.text.trim(),
              );

              if (!mounted) return;

              // RF003: Fornece mensagem informativa de confirmação na tela
              if (erro == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Colheita registrada com sucesso no banco de dados!'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Falha ao salvar colheita: $erro'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  /// RF004: Diálogo para atualização de dados com exibição transparente do motivo da falha
  void _abrirDialogoEdicao(String docId, String talhaoNome, double qtdAtual) {
    final editarQuantidadeController = TextEditingController(text: qtdAtual.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Atualizar Produção: $talhaoNome"),
        content: TextField(
          controller: editarQuantidadeController,
          decoration: const InputDecoration(labelText: 'Nova Quantidade Colhida'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              double? novaQtd = double.tryParse(editarQuantidadeController.text.trim());
              if (novaQtd == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, digite um número válido.')),
                );
                return;
              }

              Navigator.pop(context); // Fecha o modal de alteração

              // Executa a modificação enviando o mapa de dados
              String? erro = await _colheitaController.atualizarColheitaDados(docId, {
                'quantidadeColhida': novaQtd,
              });

              if (!mounted) return;

              // RF004: Feedback adequado exibindo o motivo detalhado de qualquer falha
              if (erro == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Volume de colheita atualizado com sucesso!'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Não foi possível modificar o registro: $erro'), 
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
        title: const Text("Histórico de Colheitas"), 
        backgroundColor: primaryColor, 
        foregroundColor: Colors.white
      ),
      body: StreamBuilder<QuerySnapshot>(
        // RF003: Integração reativa e segura protegendo o acesso aos dados rurais do usuário
        stream: _colheitaController.listarColheitasDoUsuario(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao buscar dados do servidor: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final documentos = snapshot.data?.docs ?? [];

          if (documentos.isEmpty) {
            return const Center(child: Text('Nenhum registro de colheita localizado.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: documentos.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final Map<String, dynamic> dados = documentos[index].data() as Map<String, dynamic>;
              final String docId = documentos[index].id;

              final String talhao = dados['talhao'] ?? 'Talhão Geral';
              final double quantidadeColhida = (dados['quantidadeColhida'] ?? 0.0).toDouble();
              final String unidade = dados['unidade'] ?? '';
              final String destino = dados['destino'] ?? 'Não Definido';
              final String dataFim = dados['dataFim'] ?? '';

              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE0F2F1),
                  child: Icon(Icons.agriculture, color: primaryColor),
                ),
                title: Text(
                  "Talhão: $talhao",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text("Destino: $destino • Concluído em: $dataFim"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "$quantidadeColhida $unidade",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Colors.green, 
                        fontSize: 16
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      tooltip: 'Modificar Quantidade',
                      onPressed: () => _abrirDialogoEdicao(docId, talhao, quantidadeColhida), // Ativação do RF004
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