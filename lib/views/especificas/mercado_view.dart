import 'package:flutter/material.dart';
import '../../controllers/mercado_controller.dart';

class MercadoView extends StatefulWidget {
  const MercadoView({super.key});

  @override
  State<MercadoView> createState() => _MercadoViewState();
}

class _MercadoViewState extends State<MercadoView> {
  final MercadoApiController _apiController = MercadoApiController();
  
  late Future<List<CotacaoModel>> _futureCotacoes;

  @override
  void initState() {
    super.initState();
    // Inicializa a chamada da API assim que a tela é construída
    _futureCotacoes = _apiController.buscarCotacoesAgro();
  }

  /// Método auxiliar para forçar a atualização manual dos dados obtidos da API
  void _atualizarIndicadores() {
    setState(() {
      _futureCotacoes = _apiController.buscarCotacoesAgro();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Atualizando cotações em tempo real...'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A747C); // Paleta padrão do app

    return Scaffold(
      appBar: AppBar(
        title: const Text("Indicadores de Mercado"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar Cotações',
            onPressed: _atualizarIndicadores,
          )
        ],
      ),
      body: FutureBuilder<List<CotacaoModel>>(
        future: _futureCotacoes,
        builder: (context, snapshot) {
          // Estado de Carregamento (Loading)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)),
                  SizedBox(height: 15),
                  Text("Buscando dados da API financeira...", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // Tratamento de Erros e Feedbacks claros (Error State)
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 60, color: Colors.redAccent),
                    const SizedBox(height: 15),
                    Text(
                      '${snapshot.error}'.replaceAll('Exception:', ''),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _atualizarIndicadores,
                      icon: const Icon(Icons.replay),
                      label: const Text("Tentar Novamente"),
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
                    )
                  ],
                ),
              ),
            );
          }

          final listaMoedas = snapshot.data ?? [];

          if (listaMoedas.isEmpty) {
            return const Center(child: Text("Nenhum dado financeiro retornado pela API."));
          }

          // Renderização dos dados obtidos com sucesso (Success State)
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listaMoedas.length,
            itemBuilder: (context, index) {
              final moeda = listaMoedas[index];
              final bool ehAlta = moeda.variacao >= 0;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              moeda.nome,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: ehAlta ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  ehAlta ? Icons.arrow_upward : Icons.arrow_downward,
                                  size: 16,
                                  color: ehAlta ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${ehAlta ? '+' : ''}${moeda.porcentagemAlteracao.toStringAsFixed(2)}%",
                                  style: TextStyle(color: ehAlta ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text("Compra", style: TextStyle(color: Colors.grey, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(
                                "R\$ ${moeda.valorCompra.toStringAsFixed(3)}",
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text("Venda", style: TextStyle(color: Colors.grey, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(
                                "R\$ ${moeda.valorVenda.toStringAsFixed(3)}",
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          "Ref: ${moeda.dataAtualizacao}",
                          style: const TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}