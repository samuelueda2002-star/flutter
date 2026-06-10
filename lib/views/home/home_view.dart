import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/views/especificas/cadastro_propriedade_view.dart';
import '../auth/login_view.dart';
import '../especificas/safras_list_view.dart';
import '../especificas/insumos_view.dart';
import '../especificas/propriedade_view.dart'; 
import '../especificas/despesas_view.dart';
import '../especificas/colheita_view.dart';
import '../especificas/mercado_view.dart';
import '../sobre/sobre_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _efetuarLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Encerrar Sessão"),
        content: const Text("Deseja realmente sair da sua conta administrativa?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // Fecha o diálogo
              await _auth.signOut();  // Desconecta do Firebase Auth
              
              if (!mounted) return;
              
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
                (route) => false,
              );
            },
            child: const Text("Sair", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A747C);
    final String userEmail = _auth.currentUser?.email ?? 'Produtor Rural';

    final List<Map<String, dynamic>> modulosHub = [
      {
        'titulo': 'Safras e Culturas',
        'subtitulo': 'Gerenciar ciclos e talhões',
        'icone': Icons.grass,
        'cor': Colors.green,
        'tela': const SafrasListView(), 
      },
      {
        'titulo': 'Estoque de Insumos',
        'subtitulo': 'Controle de NPK, defensivos e sementes',
        'icone': Icons.inventory,
        'cor': Colors.blueGrey,
        'tela': const InsumosView(),
      },
      {
        'titulo': 'Propriedades Rurais',
        'subtitulo': 'Fazendas e glebas registradas',
        'icone': Icons.landscape,
        'cor': Colors.brown,
        'tela': const PropriedadesView(),
      },
      {
        'titulo': 'Fluxo de Despesas',
        'subtitulo': 'Lançamentos financeiros operacionais',
        'icone': Icons.trending_down,
        'cor': Colors.redAccent,
        'tela': const DespesasView(),
      },
      {
        'titulo': 'Histórico de Colheitas',
        'subtitulo': 'Pesagem e destino da produção',
        'icone': Icons.agriculture,
        'cor': Colors.orange,
        'tela': const ColheitaView(),
      },
      {
        'titulo': 'Mercado (API)',
        'subtitulo': 'Cotações cambiais em tempo real',
        'icone': Icons.analytics,
        'cor': Colors.teal,
        'tela': const MercadoView(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("AgroGestão Dashboard"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Sobre o App',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SobreView()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair da Conta',
            onPressed: _efetuarLogout,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              border: const Border(bottom: BorderSide(color: Colors.black12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Olá, Bem-vindo de Volta!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
                ),
                const SizedBox(height: 4),
                Text(
                  "Acessado como: $userEmail",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.only(left: 20, top: 20, bottom: 10),
            child: Text(
              "Painel de Controle Operacional",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
          ),
          
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.1,
              ),
              itemCount: modulosHub.length,
              itemBuilder: (context, index) {
                final item = modulosHub[index];
                
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onFocusChange: null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => item['tela']),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: item['cor'].withOpacity(0.12),
                            radius: 22,
                            child: Icon(item['icone'], color: item['cor'], size: 24),
                          ),
                          const Spacer(),
                          Text(
                            item['titulo'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['subtitulo'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey, fontSize: 11, height: 1.2),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}