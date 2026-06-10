import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/safra_controller.dart';

class PesquisaSafrasView extends StatefulWidget {
  const PesquisaSafrasView({super.key});

  @override
  State<PesquisaSafrasView> createState() => _PesquisaSafrasViewState();
}

class _PesquisaSafrasViewState extends State<PesquisaSafrasView> {
  final SafrasFirestoreController _safraController = SafrasFirestoreController();
  final _searchController = TextEditingController();
  
  String _termoPesquisa = "";
  String _criterioOrdenacao = "alfabetica"; 

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pesquisa de Dados (RF006)")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Escreva a identificação do Talhão para pesquisar...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _termoPesquisa.isNotEmpty 
                        ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); setState(() => _termoPesquisa = ""); })
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _termoPesquisa = val.trim();
                    });
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Critério de Ordenação:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                    DropdownButton<String>(
                      value: _criterioOrdenacao,
                      items: const [
                        DropdownMenuItem(value: 'alfabetica', child: Text('Ordem Alfabética (A-Z)')),
                        DropdownMenuItem(value: 'area', child: Text('Tamanho da Área (Maior)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _criterioOrdenacao = val);
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _safraController.listarSafrasDoUsuario(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Erro: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                List<QueryDocumentSnapshot> documentos = snapshot.data?.docs ?? [];

                if (_termoPesquisa.isNotEmpty) {
                  documentos = documentos.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final String talhao = (data['talhao'] ?? '').toString().toLowerCase();
                    return talhao.contains(_termoPesquisa.toLowerCase());
                  }).toList();
                }

                documentos.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;

                  if (_criterioOrdenacao == 'area') {
                    final double areaA = (dataA['area'] ?? 0.0).toDouble();
                    final double areaB = (dataB['area'] ?? 0.0).toDouble();
                    return areaB.compareTo(areaA);
                  } else {
                    final String talhaoA = (dataA['talhao'] ?? '').toString();
                    final String talhaoB = (dataB['talhao'] ?? '').toString();
                    return talhaoA.compareTo(talhaoB);
                  }
                });

                if (documentos.isEmpty) {
                  return const Center(child: Text('Nenhum resultado correspondente localizado.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: documentos.length,
                  itemBuilder: (context, index) {
                    final data = documentos[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.travel_explore, color: Colors.teal),
                        title: Text("Talhão: ${data['talhao'] ?? ''}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Cultura: ${data['cultura'] ?? ''} • Área: ${data['area'] ?? 0} ha"),
                        trailing: Text(data['status'] ?? '', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}