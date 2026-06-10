import 'package:flutter/material.dart';
import '../../controllers/mercado_controller.dart';

class MercadoView extends StatefulWidget {
  const MercadoView({super.key});

  @override
  State<MercadoView> createState() => _MercadoViewState();
}

class _MercadoViewState extends State<MercadoView> {
  final MercadoApiController _apiController = MercadoApiController();
  late Future<List<CotacaoAgroModel>> _futureCotacoes;

  @override
  void initState() {
    super.initState();
    _futureCotacoes = _apiController.buscarCotacoesMercado();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cotações Cambiais"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() { _futureCotacoes = _apiController.buscarCotacoesMercado(); }),
          )
        ],
      ),
      body: FutureBuilder<List<CotacaoAgroModel>>(
        future: _futureCotacoes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('${snapshot.error}', textAlign: TextAlign.center)));

          final cotacoes = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cotacoes.length,
            itemBuilder: (context, index) {
              final item = cotacoes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Color(0xFFE0F2F1), child: Icon(Icons.monetization_on, color: Colors.teal)),
                  title: Text(item.moeda, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Sincronizado em: ${item.dataSincronizacao}", style: const TextStyle(fontSize: 12)),
                  trailing: Text("R\$ ${item.valorCompra.toStringAsFixed(3)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}