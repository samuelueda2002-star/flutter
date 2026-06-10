import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/safra_controller.dart';
import 'cadastro_safra_view.dart';

class SafrasListView extends StatefulWidget {
  const SafrasListView({super.key});

  @override
  State<SafrasListView> createState() => _SafrasListViewState();
}

class _SafrasListViewState extends State<SafrasListView> {
  // Instanciação do controlador do Firestore alinhado
  final SafrasFirestoreController _safraController = SafrasFirestoreController();

  /// RF004: Abre uma caixa de diálogo para atualização dinâmica do status da safra 
  /// Exibe feedbacks e o motivo exato de qualquer falha gerada pelo servidor
  void _alterarStatusSafra(String docId, String talhaoNome, String statusAtual) {
    String statusSelecionado = statusAtual;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Atualizar Status: $talhaoNome"),
          content: DropdownButtonFormField<String>(
            value: statusSelecionado,
            items: const [
              DropdownMenuItem(value: 'Planejado', child: Text('Planejado')),
              DropdownMenuItem(value: 'Plantado', child: Text('Plantado')),
              DropdownMenuItem(value: 'Em Colheita', child: Text('Em Colheita')),
              DropdownMenuItem(value: 'Concluído', child: Text('Concluído')),
            ],
            onChanged: (val) {
              if (val != null) {
                setDialogState(() => statusSelecionado = val);
              }
            },
            decoration: const InputDecoration(labelText: 'Novo Status', border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Fecha o modal de diálogo

                // Executa a mutação enviando o mapa de alteração para o Firestore
                String? erro = await _safraController.atualizarSafra(docId, {
                  'status': statusSelecionado,
                });

                if (!mounted) return;

                // RF004: Feedback adequado indicando o sucesso ou o motivo exato da falha
                if (erro == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Status da safra atualizado com sucesso!'), backgroundColor: Colors.green),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Não foi possível atualizar o status: $erro'), 
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A747C);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Monitoramento de Safras"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // RF003: Integração reativa e segura protegendo o acesso aos dados do usuário (Filtro por UID)
        stream: _safraController.listarSafrasDoUsuario(),
        builder: (context, snapshot) {
          // Trata falhas de permissão ou conexão durante a escuta do banco
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Erro ao carregar safras: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          }

          // Exibe indicador visual de progresso enquanto os dados reais não são retornados
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)),
            );
          }

          final documentos = snapshot.data?.docs ?? [];

          // Feedback visual claro caso o usuário não tenha nenhuma safra inserida
          if (documentos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.eco_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'Nenhuma safra cadastrada.\nClique no botão abaixo para adicionar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ],
              ),
            );
          }

          // Renderização dinâmica dos dados vindos diretamente do banco de dados (Sem dados mofados)
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: documentos.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final Map<String, dynamic> dados = documentos[index].data() as Map<String, dynamic>;
              final String docId = documentos[index].id;

              // Coleta dos campos tipados mapeados no banco
              final String talhao = dados['talhao'] ?? 'Talhão Sem Nome';
              final String cultura = dados['cultura'] ?? 'Não Especificada';
              final double area = (dados['area'] ?? 0.0).toDouble();
              final String status = dados['status'] ?? 'Planejado';
              final String dataPlantio = dados['dataPlantio'] ?? 'Não Informada';

              return Card(
                elevation: 1.5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.grass, color: Colors.green),
                  ),
                  title: Text(
                    "Talhão: $talhao",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "Cultura: $cultura • Área: $area ha\nPlantio: $dataPlantio",
                      style: const TextStyle(height: 1.3, fontSize: 13),
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, 
                            color: Colors.green, 
                            fontSize: 12
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: IconButton(
                          icon: const Icon(Icons.edit, size: 18, color: Colors.orange),
                          tooltip: 'Alterar Status',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _alterarStatusSafra(docId, talhao, status), // Gatilho RF004
                        ),
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
        backgroundColor: primaryColor,
        onPressed: () {
          // Navegação direta para a tela de inserção de dados do formulário real
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CadastroSafraView()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}