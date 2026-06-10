import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/safra_controller.dart';
import 'cadastro_safra_view.dart';
import 'pesquisa_safras_view.dart';

class SafrasListView extends StatefulWidget {
  const SafrasListView({super.key});

  @override
  State<SafrasListView> createState() => _SafrasListViewState();
}

class _SafrasListViewState extends State<SafrasListView> {
  final SafrasFirestoreController _safraController = SafrasFirestoreController();

  void _atualizarStatusDialog(String docId, String talhao, String statusAtual) {
    String novoStatus = statusAtual;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Editar Status: $talhao"),
        content: DropdownButtonFormField<String>(
          value: statusAtual,
          items: const [
            DropdownMenuItem(value: 'Planejado', child: Text('Planejado')),
            DropdownMenuItem(value: 'Plantado', child: Text('Plantado')),
            DropdownMenuItem(value: 'Em Colheita', child: Text('Em Colheita')),
            DropdownMenuItem(value: 'Concluído', child: Text('Concluído')),
          ],
          onChanged: (val) => novoStatus = val ?? statusAtual,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              String? erro = await _safraController.atualizarSafra(docId, {'status': novoStatus});
              if (!mounted) return;
              
              if (erro == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Status atualizado com sucesso!'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Falha na atualização: $erro'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Salvar"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Monitoramento de Safras"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Pesquisa Avançada',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PesquisaSafrasView()),
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _safraController.listarSafrasDoUsuario(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Erro: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final documentos = snapshot.data?.docs ?? [];
          if (documentos.isEmpty) return const Center(child: Text('Nenhuma safra localizada em seu perfil.'));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: documentos.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final doc = documentos[index];
              final data = doc.data() as Map<String, dynamic>;

              final String talhao = data['talhao'] ?? '';
              final String cultura = data['cultura'] ?? '';
              final double area = (data['area'] ?? 0.0).toDouble();
              final String status = data['status'] ?? 'Planejado';
              final String dataPlantio = data['dataPlantio'] ?? '';

              return Card(
                elevation: 1.5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.grass, color: Colors.green)),
                  title: Text("Talhão: $talhao", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Cultura: $cultura • Área: $area ha\nPlantio: $dataPlantio"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(label: Text(status, style: const TextStyle(fontSize: 12))),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
                        onPressed: () => _atualizarStatusDialog(doc.id, talhao, status),
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
        backgroundColor: const Color(0xFF0A747C),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CadastroSafraView())),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}